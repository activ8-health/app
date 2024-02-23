import requests
import json
from dateutil import parser

# API: OpenMeteo API
# API call: https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current_weather=true
# Weather code to weather conversion given in documentation
# WEATHER_CODE_CONVERSION = {0: 'Clear Sky',
#                  1: 'Mainly Clear',
#                  2: 'Partly Cloudy',
#                  3: 'Overcast',
#                  45: 'Foggy',
#                  48: 'Rime Fog',
#                  51: 'Light Drizzle',
#                  53: 'Moderate Drizzle',
#                  55: 'Dense Drizzle',
#                  56: 'Light Freezing Drizzle',
#                  57: 'Dense Freezing Drizzle',
#                  61: 'Slight Rain',
#                  63: 'Moderate Rain',
#                  65: 'Heavy Rain',
#                  66: 'Light Freezing Rain',
#                  67: 'Heavy Freezing Rain',
#                  71: 'Slight Snow',
#                  73: 'Moderate Snow',
#                  75: 'Heavy Snow',
#                  77: 'Snow Grains',
#                  80: 'Slight Rain Showers',
#                  81: 'Moderate Rain Showers',
#                  82: 'Violent Rain Showers',
#                  85: 'Slight Snow Showers',
#                  86: 'Heavy Snow Showers',
#                  95: 'Thunderstorm',
#                  96: 'Thunderstorm with Slight Hail',
#                  99: 'Thunderstorm with Heavy Hail'
#                  }
API_URL = 'https://api.open-meteo.com/v1/forecast'

# pace to speed conversion (default is average)
SPEED_CONV = {'slow': 0.9, 'average': 1.34, 'fast': 1.79} # m/s
# pace to MET conversion (default is average)
MET_CONV = {'slow': 2.8, 'average': 3.5, 'fast': 5.0}

def get_weather_code(lat: float, lon: float)-> int:
    '''
    lat: latitude
    lon: longitude
    calls the OpenMeteo API and returns the weather code for that location if possible, if error return -1
    '''
    res = requests.get(f'{API_URL}?latitude={lat}&longitude={lon}&current_weather=true')
    if res.status_code != 200:
        # there is an error with the response (location doesnt exist, etc)
        return -1
    res = res.json()
    return res['current_weather']['weathercode']

def calc_calories_burned(height: float, weight: float, steps: int, pace: str='average') -> float:
    '''
    height: user's height in cm
    weight: user's weight in kg
    steps: the amount of steps the user has taken
    pace: user's pace required to determine speed and MET (this is defaulted to average)
    returns the calories burned in kcal based on given input

    Calculations
    Required: weight(kg), height(m), steps, pace(m/s)
    Slow - 0.9 m/s (2.8 MET)
    Average - 1.34 m/s (3.5 MET) DEFAULT
    Fast - 1.79 m/s (5 MET)

    stride = height * 0.414
    walked distance = stride * steps
    walking time = distance/speed

    calories = time * MET * 3.5 * weight/(200 * 60) in kcal

    Calculations obtained from the source below
    Source: https://www.omnicalculator.com/sports/steps-to-calories 
    '''
    speed = SPEED_CONV[pace] # get the speed in m/s based on pace given
    met = MET_CONV[pace] # get the MET based on the pace given
    stride = (height / 100) * 0.414
    dist = stride * steps
    time = dist / speed
    cals = time * met * 3.5 * weight / (200 * 60)
    return cals

def get_user_data(email: str) -> dict:
    '''
    email: email of the user to retrieve user data from
    returns necessary user data

    opens and loads the user data from json file 
    retrieves the user's exercise data, location data, and user profile data
    '''
    user_file = open('./data/user_profile.json', 'r')
    user_data = json.load(user_file)
    exercise = user_data[email]['exercise']
    location = user_data[email]['location']
    user_profile = user_data[email]['user_profile']
    return {'user_profile': user_profile, 'exercise': exercise, 'location': location}

def get_steps_by_day(exercise_data: dict, date: str) -> int:
    '''
    exercise_data: dictionary of the user's steps data for each day
    date: the date (string in iso format) to get the steps data for
    returns the steps data for that particular date

    the date string is parsed to get only the date to return the correct steps data
    '''
    date_string = str(parser.isoparse(date).date())

    return exercise_data['step_data'].get(date_string, 0)

def get_step_progress_message(steps_left: int, step_goal: int) -> str:
    '''
    steps_left: the number of steps a user has left until they reach their step goal
    step_goal: the daily step goal that the user set
    returns a message based on the user's step progress

    a message is constructed based on the percentage left until the user completes their step goal
    '''
    percent_left = steps_left / step_goal
    if percent_left == 0.5:
        # the user has complete exactly 50% of their steps
        return f"You're halfway to your step goal, only {steps_left} steps left!"
    elif percent_left < 0.2: 
        # the user has completed more than 80% of their steps
        return f"You're almost at your step goal, only {steps_left} steps left!"
    elif percent_left < 0.5:
        # the user has completed more than 50% of their steps
        return f"You're more than halfway to your step goal, only {steps_left} steps left!"
    else:
        return f"Remember to get in your steps today. You still have {steps_left} steps left until you reach your step goal."
    
def get_weather_suggestion_message(location: dict) -> str:
    '''
    location: a dictionary containing the latitude and longitude of the user's location
    returns an exercise recommendation based on weather at the given location
    
    calls the OpenMeteo API to get a weather code that will be used to decide which recommendation is given
    good weather will recommend the user to go for a run
    chilly weather will recommend the same but give advice to wear more
    slighlty bad weather will tell the user to be careful outside/go to the gym
    bad weather will recommend the user to exercise indoors/take a break
    if the location data is null or if the weather api runs into an error,
    a default recommendation of running outside or exercising indoors is given
    '''
    if location == None:
        # location was not provided so a default message is given as a recommendation
        return "You can either go for a run outside or exercise indoors."
    
    lat, lon = location['lat'], location['long']
    weather_code = get_weather_code(lat, lon)
    
    if weather_code == -1:
        # API returned an error so a default message is given as a recommendation
        return "You can either go for a run outside or exercise indoors."
    elif weather_code == 0 or weather_code == 1:
        # for clear sky, mainly clear
        return "The weather looks great today, so go for a run outside."
    elif weather_code == 2 or weather_code == 3:
        # for partly cloudy, overcast
        return "It might be chilly today, so make sure to wear more when going for a run outside."
    elif weather_code == 45 or (weather_code >= 51 and weather_code <= 55) or weather_code == 71:
        # for foggy, any drizzle (not including freezing drizzle), slight snow
        return "The weather is starting to get bad, so make sure to be careful outside or go to the gym."
    else:
        # for rime fog, freezing drizzles, rain showers, rain, moderate and above snow, snow showers, thunderstorms
        return "But the weather isn't great today, so either exercise indoors or take it easy for today."

def get_exercise_message(steps: int, step_goal: int, location: dict) -> str:
    '''
    steps: the amount of steps the user taken 
    step_goal: the daily step goal set by the user
    location: a dictionary containing the latitude and longitude of the user's location
    returns an exercise message about steps progress and an exercise recommendation if needed

    if the user met the step goal already, a default congrats message is given
    if user still have steps left, the message will consist of the user's step progress 
    and an exercise recommendation based on the weather if possible
    '''
    if steps >= step_goal:
        return "Congratulations, you've met your step goal for the day!"
    
    # if there are steps left separate message into two parts
    # first part the step progress part which contains different messages based on
    # the percentage of steps the user still has to complete
    steps_left = step_goal - steps
    message = get_step_progress_message(steps_left, step_goal)

    # second part of the message is a basic exercise recommendation based on the weather at the user's location
    return message + " " + get_weather_suggestion_message(location)


def get_activity_recommendation(email: str, date: str) -> dict:
    '''
    email: email of the user to retrieve user data from
    date: date string in iso format
    returns calories burned based on steps taken today, steps data, message with progress/recommendations

    gets the user data for the email given and the exercise data for the date given
    gets an exercise message that gives current progress towards step goal and any recommendations
    based on the weather at the user's current location if the user hasn't met step goal
    calculates the calories burned based on the amount of the steps taken using the user's height and weight
    '''
    user_data = get_user_data(email)
    exercise_data = user_data['exercise']
    user_profile = user_data['user_profile']

    steps = get_steps_by_day(exercise_data, date)
    step_goal = exercise_data['step_goal']
    location = user_data['location']

    message = get_exercise_message(steps, step_goal, location)

    height, weight = user_profile['height'], user_profile['weight']
    cals_burned = calc_calories_burned(height, weight, steps)

    return {'calories_burned': cals_burned,
            'steps': {'daily_target': step_goal,
                      'progress_today': steps},
            'message': message}

# testing
# print(get_weather_code(40.7128,74.0060))
# print(calc_calories_burned(144.0, 15.875732950000002, 11524))
# print(get_exercise_message(11524,23000,{'lat': 33.6897734, 'long': -117.82164237}))
# print(get_exercise_message(11524,23000,{'lat': 40.7128, 'long': 74.0060}))
# print(parser.isoparse('2024-01-30T02:00:37.000').date())
# print(get_activity_recommendation('5', '2024-01-22T02:00:37.000'))
