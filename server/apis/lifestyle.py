import json
import sleep
from dateutil import parser


def get_user_data(email: str) -> dict:
    '''
    email: email of the user to retrieve user data from
    returns necessary user data

    opens and loads the user data from json file 
    retrieves the user's exercise data, sleep data, and food data to use for calculations
    '''
    user_file = open('./data/user_profile.json', 'r')
    user_data = json.load(user_file)
    user_file.close()
    exercise = user_data[email]['exercise']
    sleep = user_data[email]['sleep']['sleep_data']
    food = user_data[email]['food']
    return {'sleep': sleep, 'exercise': exercise, 'food': food}

def calc_sleep_score(sleep_data: dict) -> int:
    '''
    sleep_data: a dictionary for list of sleep data points for each day of the week
    returns the user's sleep score

    a user's sleep score is calculated by getting the average sleep time for 7 days 
    (if there are less than 7, take however many there are)
    divided by the ideal sleep range
    the score is maxed at 1
    '''
    days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    avg_sleep_time = 0
    num_days = 0
    for day in days:
        # if there are data points that within 30 mins of each other, they are combined
        # other than those cases, only one data point should be taken from each day
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
        num_days += 1
        avg_sleep_time += sleep.calculate_sleeptime(sleep.convert_to_time_of_day(date['date_from']), sleep.convert_to_time_of_day(date['date_to']))
    avg_sleep_time /= num_days
    sleep_score = (avg_sleep_time / sleep.IDEAL_SLEEP_RANGE_IN_MINS)
    return min(sleep_score, 1.0)

def calc_exercise_score(exercise_data: dict) -> int:
    '''
    exercise_data: a dictionary including the user's step data for each day and their step goal
    returns the user's exercise score

    a user's exercise score is calculated by getting the first 7 step data 
    (if there are less than 7, take however many there are)
    and averaging them before dividing them by the step goal
    the score is maxed at 1
    '''
    step_goal = exercise_data['step_goal']
    step_data = exercise_data['step_data']
    total_steps = 0
    step_data_dates = list(step_data.keys())
    i = 0
    while i < 7 and i < len(step_data_dates):
        total_steps += step_data[step_data_dates[i]]
        i += 1
    avg_steps = total_steps / min(len(step_data_dates), 7)
    exercise_score = avg_steps / step_goal
    return min(exercise_score, 1.0)

def calc_food_score(food_data: dict) -> tuple[int, bool]:
    '''
    food data: a dictionary including the user's food log and weight goal
    returns the user's food score

    the user's average calorie is calculated for the first 7 food data (if there are less than 7, just take however many there are)
    then this equation is used to calculate the score: 1 - min((((average calories - ideal calories goal) / (30% of ideal calories goal))^ 2), 1.0)
    if the user goes over or under their ideal calories goal by 30%, their food score is automatically 0
    '''
    # food_log = food_data['food_log']
    # total_cals = 0
    # food_log_dates = list(food_log.keys())
    # i = 0
    # while i < 7 and i < len(food_log_dates):
    #     food_log_dict = food_log[food_log_dates[i]]
    #     for key in list(food_log_dict.keys()):
    #         total_cals += food_log_dict[key]['total_calories']
    #     i += 1
    # avg_cals = total_cals / min(len(food_log_dates), 7)
    ideal_cals = 2000 # will be replaced by cal func in food files
    avg_cals = 1900
    food_score = 1 - min((((avg_cals - ideal_cals) / (ideal_cals * 0.3)) ** 2), 1.0)
    return food_score, (avg_cals < ideal_cals)

def get_lifestyle_score(email: str) -> dict:
    '''
    email: email of the user to retrieve user data from
    returns an object containing the user's lifestyle score and some advice to improve their lowest scoring category

    calculates the sleep, exercise, and food score before average all of them
    then converts the score to be out of 100 and returns a message based on the category with the lowest score
    the food score related message changes based on whether the user exceeds their calorie goal or fails to meet it
    '''
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