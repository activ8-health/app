import sys
if sys.path[0].endswith('/apis'):
    sys.path[0] = sys.path[0][0:-(len('/apis'))]

import datetime
import json
from apis import sleep, food
from dateutil import parser

def get_user_data(email: str) -> dict:
    '''
    email: email of the user to retrieve user data from
    returns necessary user data

    opens and loads the user data from json file 
    retrieves the necessary data for exercise score, sleep score, and food score calculations
    '''
    user_file = open('./data/user_profile.json', 'r')
    user_data = json.load(user_file)
    user_file.close()
    exercise = user_data[email]['exercise']
    sleep = user_data[email]['sleep']['sleep_data']
    food = user_data[email]
    return {'sleep': sleep, 'exercise': exercise, 'food': food}

def calc_sleep_score(sleep_data: dict, date: str) -> float:
    '''
    sleep_data: a dictionary for list of sleep data points for each day of the week
    date: date string in iso format
    returns the user's sleep score

    a user's sleep score is calculated by getting the average sleep time for the past 7 days 
    divided by the ideal sleep range
    the score is maxed at 1
    '''
    days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    total_sleep_time = 0
    num_days = 0
    today = parser.isoparse(date).date()

    for day in days:
        try:
            sleep_log_date = sleep_data[day][0]
            date_from = parser.isoparse(sleep_log_date['date_from']).date()
            # if the date is within ~1 week from the date given, it will be counted in the calculation
            # if the date is not, it is assumed that a date is missing and will be counted as 0 sleep for said day
            if date_from <= today and date_from >= (today - datetime.timedelta(days=8)):
                total_sleep_time += sleep.calculate_sleeptime(sleep.convert_to_time_of_day(sleep_log_date['date_from']), 
                                                            sleep.convert_to_time_of_day(sleep_log_date['date_to']))
            num_days += 1
        except IndexError:
            # if there is no sleep data for a day, continue to next day
            continue
    if num_days == 0:
        # this is to prevent division by zero error
        num_days = 1

    avg_sleep_time = total_sleep_time / num_days
    sleep_score = (avg_sleep_time / sleep.IDEAL_SLEEP_RANGE_IN_MINS)
    return min(sleep_score, 1.0)

def calc_exercise_score(exercise_data: dict, date: str) -> float:
    '''
    exercise_data: a dictionary including the user's step data for each day and their step goal
    date: date string in iso format
    returns the user's exercise score

    a user's exercise score is calculated by getting the first 7 step data excluding data from the date given
    (if there are less than 7, take however many there are)
    and averaging them before dividing them by the step goal
    the score is maxed at 1
    '''
    step_goal = exercise_data['step_goal']
    step_data = exercise_data['step_data']
    total_steps = 0
    step_data_dates = list(step_data.keys())
    today = parser.isoparse(date).date()
    date_str = today.strftime('%Y-%m-%d')
    num_step_data_dates = len(step_data_dates)
    i = 0
    k = 7
    if date_str == step_data_dates[0]:
        # if the first data is for the date given, skip it and shift everything down
        # only consider data for the first 7 dates after the date given
        num_step_data_dates -= 1
        i = 1
        k = 8

    while i < k and i < len(step_data_dates):
        total_steps += step_data[step_data_dates[i]]
        i += 1

    avg_steps = total_steps / min(num_step_data_dates, 7)
    exercise_score = avg_steps / step_goal
    return min(exercise_score, 1.0)

def calc_food_score(food_data: dict, date: str) -> tuple[float, bool]:
    '''
    food data: a dictionary including the user's food log and weight goal
    date: date string in iso format
    returns the user's food score

    the user's average calorie is calculated for food data for the past 7 days
    if there are less than 7 days worth of food log data, the day differences between the dates will be looked at
    if each date is within a day of each other, it is assumed that they are a new user and their average will only be taken with what's available
    if that is not the case, the missing dates will be counted as 0's in the total calories count
    ex 1: date: 3/5 food log: 3/4, 3/1, 2/27, 2/26 -> (3/4 + 0 (3/3) + 0(3/2) + 3/1 + 0(2/29) + 0(2/28) + 2/27) / 7
    ex 2: date: 3/5 food log: 3/4, 3/3, 3/2, 3/1-> (3/4 + 3/3 + 3/2 + 3/1) / 4
    ex 3: date: 3/5 food log: 3/3, 3/1 -> (0(3/4) + 3/3 + 0(3/2) + 3/1)  / 4
    then this equation is used to calculate the score: 1 - min((((average calories - ideal calories goal) / (30% of ideal calories goal))^ 2), 1.0)
    if the user goes over or under their ideal calories goal by 30%, their food score is automatically 0
    '''
    food_log = food_data['food']['food_log']
    total_cals = 0
    food_log_dates = list(food_log.keys())
    today = parser.isoparse(date).date()
    date_str = today.strftime('%Y-%m-%d')
    num_days = 0

    # check if there are 7 days worth of food data excluding data for the date given
    if date_str == food_log_dates[0]:
        not_enough_data = (len(food_log_dates) - 1) < 7
    else:
        not_enough_data = len(food_log_dates) < 7

    if not not_enough_data:
        for i in range(1,8):
            total_cals += food.get_calories_consumed_today(food_data, (today - datetime.timedelta(days=i)))
        num_days = 7
    else:
        prev_date = today
        for food_log_key in food_log_dates:
            food_log_date = datetime.datetime.strptime(food_log_key, '%Y-%m-%d').date()
            if food_log_date == today:
                # if date of food log is the date given, skip
                continue
            day_diff = (prev_date - food_log_date).days
            if day_diff > 1:
                # if day difference is greater than 1, count missing days as 0
                num_days += (day_diff - 1)
                if num_days >= 7:
                    # break from loop once 7 days worth of data is used
                    num_days = 7
                    break
            elif day_diff < 0:
                continue
            food_log_dict = food_log[food_log_key]
            for key in list(food_log_dict.keys()):
                total_cals += food_log_dict[key]['total_calories']
            num_days += 1
            if num_days == 7:
                # break from loop once 7 days worth of data is used
                break
            prev_date = food_log_date
    if num_days == 0:
        # this is to prevent division by zero error
        num_days = 1

    avg_cals = total_cals / num_days
    ideal_cals = food.get_daily_target(food_data)
    food_score = 1 - min((((avg_cals - ideal_cals) / (ideal_cals * 0.3)) ** 2), 1.0)
    return food_score, (avg_cals < ideal_cals)

def get_lifestyle_message(sleep_score: float, exercise_score: float, food_score: float, not_eating_enough: bool) -> str:
    '''
    sleep_score: user's sleep score for the past week
    exercise_score: user's exercise score for the past week
    food_score: user's food score for the past week if applicable
    not_eating_enough: boolean to determine whether user's average calorie is less than their daily calorie target or not
    returns a message on advice to improve in specific categories if needed
    '''
    message = ''
    if sleep_score == exercise_score and sleep_score == food_score and sleep_score == 1.0:
        # user is excelling in all categories
        message += "You're doing a good job! Keep up the good work!"
    elif sleep_score < exercise_score and sleep_score < food_score:
        # lowest category is sleep
        message += "It looks like you haven't been sleeping enough lately. Try to sleep more if possible."
    elif exercise_score < sleep_score and exercise_score < food_score:
        # lowest category is exercise
        message += "It looks like you haven't been meeting your daily step goal lately."
        message += " Remember to set aside some time to get your steps in."
    elif food_score < exercise_score and food_score < sleep_score:
        # lowest category is food
        if not_eating_enough:
            # average calorie is less than ideal calorie goal
            message += "It looks like you haven't been meeting your daily calorie target lately."
            message += " Remember to take breaks to get food and make sure to keep your food log up to date."
        else:
            # average calorie is greater than ideal calorie goal
            message += "It looks like you have been exceeding your daily calorie target lately." 
            message += " Try to eat less."
    elif sleep_score == exercise_score and sleep_score < food_score:
        # both sleep and exercise are equally low
        message += "It looks like you haven't been sleeping enough nor meeting your daily step goal lately." 
        message += " Remember to set aside some time to get your steps in and try to sleep more if possible."
    elif sleep_score == food_score and sleep_score < exercise_score:
        # both sleep and food are equally low
        message += "It looks like you haven't been sleeping enough"
        if not_eating_enough:
            message += " nor meeting your daily calorie target lately."
            message += " Try to sleep more if possible and remember to take breaks to get food. Also, make sure to keep your food log up to date."
        else:
            message += " and have been exceeding your daily calorie target lately."
            message += " Try to sleep more if possible and eat less."
    elif exercise_score == food_score and exercise_score < sleep_score:
        # both exercise and food are equally low
        message += "It looks like you haven't been meeting your daily step goal"
        if not_eating_enough:
            message += " nor your daily calorie target lately."
            message += " Remember to set aside some time to get your steps in and to take breaks to get food. Also, make sure to keep your food log up to date."
        else:
            message += " and have been exceeding your daily calorie target lately."
            message += " Remember to set aside some time to get your steps in and try to eat less."
    else:
        # all categories are equally low
        if not_eating_enough:
            message += "Remember to set aside some time to get your steps in and to eat. Make sure to keep your food log updated and try to sleep more if possible."
        else:
            message += "Remember to set aside some time to get your steps in. Try to sleep more if possible and eat less."
    
    return message


def get_home_view(email: str, date: str) -> dict:
    '''
    email: email of the user to retrieve user data from
    date: date string in iso format
    returns an object containing the user's lifestyle score and some advice to improve their lowest scoring category

    calculates the sleep, exercise, and food score before averaging all of them
    then converts the score to be out of 100 and returns a message based on the category with the lowest score
    the food score related message changes based on whether the user exceeds their calorie goal or fails to meet it
    '''
    user_data = get_user_data(email)
    sleep_score = calc_sleep_score(user_data['sleep'], date)
    # print('sleep_score:', sleep_score)
    exercise_score = calc_exercise_score(user_data['exercise'], date)
    # print('exercise_score:', exercise_score)
    food_score, not_eating_enough = calc_food_score(user_data['food'], date)
    # print('food_score:', food_score)
    lifestyle_score = (sleep_score + exercise_score + food_score) / 3
    # print('lifestyle_score:', lifestyle_score)

    message = get_lifestyle_message(sleep_score, exercise_score, food_score, not_eating_enough)

    return {'fitness_score': round(lifestyle_score * 100), 'message': message}

print('result:', get_home_view('2', '2024-02-19T00:07:30.929870'))
print()
print('result:', get_home_view('4', '2024-03-02T00:07:30.929870'))
print()
print('result:', get_home_view('2', datetime.datetime.now().isoformat()))