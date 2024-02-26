import json
import sleep
from dateutil import parser


def get_user_data(email):
    user_file = open('./data/user_profile.json', 'r')
    user_data = json.load(user_file)
    exercise = user_data[email]['exercise']
    sleep = user_data[email]['sleep']['sleep_data']
    food = user_data[email]['food']
    return {'sleep': sleep, 'exercise': exercise, 'food': food}

def calc_sleep_score(sleep_data):
    days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    avg_sleep_time = 0
    for day in days:
        i = 1
        date = sleep_data[day][0]
        while i < len(sleep_data[day]):
            next_date = sleep_data[day][i]
            date_from = parser.isoparse(date['date_from'])
            date_to = parser.isoparse(sleep_data[day][i]['date_to'])
            diff = date_from - date_to
            if (diff.total_seconds() / 60) <= 30:
                date['date_from'] = next_date['date_from']
            else:
                break
            i+=1
        avg_sleep_time += sleep.calculate_sleeptime(sleep.convert_to_time_of_day(date['date_from']), sleep.convert_to_time_of_day(date['date_to']))
    avg_sleep_time /= 7
    return avg_sleep_time / sleep.IDEAL_SLEEP_RANGE_IN_MINS

def calc_exercise_score(exercise_data):
    step_goal = exercise_data['step_goal']
    step_data = exercise_data['step_data']
    avg_steps = 0
    for i in range(7):
        avg_steps += step_data[list(step_data.keys())[i]]
    avg_steps /= 7
    return avg_steps / step_goal

def calc_food_score(food_data):
    return

def get_lifestyle_score(email):
    user_data = get_user_data(email)
    sleep_score = calc_sleep_score(user_data['sleep'])
    exercise_score = calc_exercise_score(user_data['exercise'])
    food_score = calc_food_score(user_data['food'])

get_lifestyle_score('5')