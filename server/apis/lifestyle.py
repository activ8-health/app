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
    sleep_score = (avg_sleep_time / sleep.IDEAL_SLEEP_RANGE_IN_MINS)
    return min(sleep_score, 1)

def calc_exercise_score(exercise_data):
    step_goal = exercise_data['step_goal']
    step_data = exercise_data['step_data']
    avg_steps = 0
    for i in range(7):
        avg_steps += step_data[list(step_data.keys())[i]]
    avg_steps /= 7
    exercise_score = avg_steps / step_goal
    return min(exercise_score, 1)

def calc_food_score(food_data):
    food_log = food_data['food_log']
    food_goal = food_data['weight_goal']
    avg_cals = 0
    # for i in range(7):
    #     avg_cals += food_log[list(food_log.keys())[i]]
    # avg_cals /= 7
    ideal_cals = 2500
    avg_cals = 1000
    food_score = 0 #1 - (((avg_cals - ideal_cals) / 600) ** 2)
    return food_score, (avg_cals < ideal_cals)

def get_lifestyle_score(email):
    user_data = get_user_data(email)
    sleep_score = calc_sleep_score(user_data['sleep'])
    print('sleep_score:', sleep_score)
    exercise_score = calc_exercise_score(user_data['exercise'])
    print('exercise_score:', exercise_score)
    food_score, cals_check = calc_food_score(user_data['food'])
    print('food_score:', food_score)
    lifestyle_score = (sleep_score + exercise_score + food_score) / 3
    print('lifestyle_score:', lifestyle_score)
    if sleep_score < exercise_score and sleep_score < food_score:
        return {'fitness_score': round(lifestyle_score * 100), 'message': 'You should sleep more.'}
    elif exercise_score < sleep_score and exercise_score < food_score:
        return {'fitness_score': round(lifestyle_score * 100), 'message': 'You should exercise more.'}
    else:
        if cals_check:
            return {'fitness_score': round(lifestyle_score * 100), 'message': 'You should eat more.'}
        else:
            return {'fitness_score': round(lifestyle_score * 100), 'message': 'You should eat less.'}


print('result:', get_lifestyle_score('5'))