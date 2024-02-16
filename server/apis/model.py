from dataclasses import dataclass
from datetime import datetime
from enum import Enum


class Sex(Enum):
    Male = 0
    Female = 1
    Indeterminate = 2


class Weekdays(Enum):
    Monday = 0
    Tuesday = 1
    Wednesday = 2
    Thursday = 3
    Friday = 4
    Saturday = 5
    Sunday = 6


class WeightGoal(Enum):
    Maintain = 0
    Lose = 1
    Gain = 2


def format_sleep_data(sleep_data):  # ignore 2 hours naps
    sleep_data_points = dict()
    for date in sleep_data:
        date_from = datetime.fromisoformat(date['date_from'])
        date_to = datetime.fromisoformat(date['date_to'])
        if (date_to - date_from).seconds / 3600 > 2:
            date_of_week = date_to.weekday() - 1
            if date_of_week < 0:
                date_of_week = Weekdays(6).name
            else:
                date_of_week = Weekdays(date_of_week).name

            if date_of_week in sleep_data_points:
                sleep_data_points[date_of_week].append(date)
            else:
                sleep_data_points[date_of_week] = [date]
    return sleep_data_points


def format_step_data(step_data):  # ignore 2 hours naps
    step_data_points = dict()
    for data in step_data:
        date = datetime.fromisoformat(data['date_to'])
        date_format = date.strftime('%Y-%m-%d')
        if date_format in step_data_points:
            step_data_points[date_format] += data['steps']
        else:
            step_data_points[date_format] = data['steps']
    return step_data_points


@dataclass
class LoginInfo:
    email: str
    password: str


@dataclass
class User:
    name: str
    age: int
    height: float
    weight: float
    sex: str

    def __post_init__(self):
        if not isinstance(self.name, str):
            raise ValueError('Invalid name')

        if not isinstance(self.age, int):
            raise ValueError('Invalid age')

        self.height = float(self.height)
        self.weight = float(self.weight)

        if not isinstance(self.sex, str):
            raise ValueError('Invalid sex')


@dataclass
class Food:
    weight_goal: str
    dietary: list
    food_log: list

    def __post_init__(self):
        if not isinstance(self.weight_goal, str):
            raise ValueError('Invalid weight goal')


@dataclass
class Exercise:
    step_data: list
    reminder_time: int
    step_goal: int

    def __post_init__(self):
        if not isinstance(self.reminder_time, int):
            raise ValueError('Invalid step reminder time')

        if not isinstance(self.step_goal, int):
            raise ValueError('Invalid step goal')


@dataclass
class Sleep:
    sleep_data: list
    core_hours: dict


@dataclass
class UserProfile:
    login: LoginInfo
    user: User
    food: Food
    exercise: Exercise
    sleep: Sleep

    location: dict

    def __init__(self, email, password, data):
        self.login = LoginInfo(email=email, password=password)

        try:
            self.user = User(name=data['user_profile']['name'],
                             age=data['user_profile']['age'],
                             height=data['user_profile']['height'],
                             weight=data['user_profile']['weight'],
                             sex=Sex(data['user_profile']['sex']).name)
        except ValueError as e:
            raise ValueError('Invalid user data: ' + str(e))

        try:
            diet = set(diet for diet, value in data['food_preferences']['dietary'].items() if value)
            self.food = Food(weight_goal=WeightGoal(data['food_preferences']['weight_goal']).name,
                             dietary=list(diet if diet else None),
                             food_log=None)
        except ValueError as e:
            raise ValueError('Invalid food data: ' + str(e))

        self.exercise = Exercise(step_data=format_step_data(data['health_data']['step_data']),
                                 reminder_time=data['exercise_preferences']['reminder_time'],
                                 step_goal=data['exercise_preferences']['step_goal'])

        self.sleep = Sleep(sleep_data=format_sleep_data(data['health_data']['sleep_data']),
                           core_hours=data['sleep_preferences']['core_hours'])

        location = data['location']
        self.location = {'lat': location[0], 'long': location[1]}

    def update_sleep_data(self, sleep_data):
        pass

    def update_step_data(self, step_data):
        pass

    def update_food_data(self, food_data):
        pass

    def update_location(self, location_data):
        pass

    def serialize(self):
        return ({
                    self.login.email: {
                        'password': self.login.password}
                },
                {
                    self.login.email: {
                        'user_profile': {
                            'name': self.user.name,
                            'age': self.user.age,
                            'height': self.user.height,
                            'weight': self.user.weight,
                            'sex': self.user.sex,
                        },
                        'food': {
                            'weight_goal': self.food.weight_goal,
                            'dietary': self.food.dietary,
                            'food_log': self.food.food_log
                        },
                        'exercise': {
                            'step_data': self.exercise.step_data,
                            'reminder_time': self.exercise.reminder_time,
                            'step_goal': self.exercise.step_goal
                        },
                        'sleep': {
                            'sleep_data': self.sleep.sleep_data,
                            'core_hours': self.sleep.core_hours
                        },
                        'location': self.location
                    }
                })
