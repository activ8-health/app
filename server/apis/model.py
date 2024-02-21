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


def format_food_preferences(dietary):
    food_preferences = {}
    preferences = {'vegan', 'vegetarian', 'kosher', 'halal', 'pescetarian', 'sesame_free',
                   'soy_free', 'gluten_free', 'lactose_intolerance', 'nut_allergy',
                   'peanut_allergy', 'shellfish_allergy', 'wheat_allergy'}
    for food in preferences:
        if food not in dietary:
            food_preferences[food] = False
        else:
            food_preferences[food] = True
    return food_preferences


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

        preferences = {'vegan', 'vegetarian', 'kosher', 'halal', 'pescetarian', 'sesame_free',
                       'soy_free', 'gluten_free', 'lactose_intolerance', 'nut_allergy',
                       'peanut_allergy', 'shellfish_allergy', 'wheat_allergy'}

        if isinstance(self.dietary, dict):
            dietary = []
            if len(self.dietary) == len(preferences):
                for diet, value in self.dietary.items():
                    if (diet not in preferences) or (not isinstance(value, bool) and value is not None):
                        raise ValueError('Invalid dietary preferences')
                    if value:
                        dietary.append(diet)
                self.dietary = dietary
            else:
                raise ValueError('Invalid dietary preferences')


@dataclass
class Exercise:
    step_data: list
    reminder_time: int
    step_goal: int

    def __post_init__(self):
        reminder_time = int(self.reminder_time)
        if reminder_time == self.reminder_time and (0 < self.reminder_time < 1439):
            self.reminder_time = reminder_time
        else:
            raise ValueError('Invalid step reminder time')

        step_goal = int(self.step_goal)
        if step_goal == self.step_goal and self.step_goal > 0:
            self.step_goal = step_goal
        else:
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

    def __init__(self, email, password, user_data, health_data,
                 food_data, exercise_data, sleep_data, location_data, flag=0):
        self.login = LoginInfo(email=email, password=password)

        try:
            self.user = User(name=user_data['name'],
                             age=user_data['age'],
                             height=user_data['height'],
                             weight=user_data['weight'],
                             sex=user_data['sex'] if flag else Sex(user_data['sex']).name)
        except ValueError as e:
            raise ValueError('Invalid user data: ' + str(e))

        try:
            self.food = Food(weight_goal=(food_data['weight_goal'] if flag
                                          else WeightGoal(food_data['weight_goal']).name),
                             dietary=food_data['dietary'],
                             food_log=food_data['food_log'] if flag else None)
        except ValueError as e:
            raise ValueError('Invalid food data: ' + str(e))

        self.exercise = Exercise(step_data=(exercise_data['step_data'] if flag
                                            else format_step_data(health_data['step_data'])),
                                 reminder_time=exercise_data['reminder_time'],
                                 step_goal=exercise_data['step_goal'])

        self.sleep = Sleep(
            sleep_data=sleep_data['sleep_data'] if flag else format_sleep_data(health_data['sleep_data']),
            core_hours=sleep_data['core_hours'])

        location = location_data
        try:
            self.location = location_data if flag else {'lat': float(location[0]), 'long': float(location[1])}
        except ValueError as e:
            raise ValueError('Invalid location data: ' + str(e))

    def update_sleep_data(self, sleep_data) -> None:
        self.sleep.sleep_data = format_sleep_data(sleep_data)

    def update_step_data(self, step_data) -> None:
        self.exercise.step_data = format_step_data(step_data)

    def update_food_data(self, food_data):
        pass

    def update_location(self, location_data) -> None:
        self.location = {'lat': location_data[0], 'long': location_data[1]}

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

    def serialize_return(self):
        return ({
            self.login.email: {
                'user_profile': {
                    'name': self.user.name,
                    'age': self.user.age,
                    'height': self.user.height,
                    'weight': self.user.weight,
                    'sex': Sex[self.user.sex].value,
                },
                'food_preferences': {
                    'weight_goal': WeightGoal[self.food.weight_goal].value,
                    'dietary': format_food_preferences(self.food.dietary),
                },
                'exercise_preferences': {
                    'reminder_time': self.exercise.reminder_time,
                    'step_goal': self.exercise.step_goal
                },
                'sleep_preferences': {
                    'core_hours': self.sleep.core_hours
                }
            }
        })
