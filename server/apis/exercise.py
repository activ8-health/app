import requests
import json
from dateutil import parser

# Using OpenMateo API
# WMO Weather interpretation codes (WW)
# Code	Description
# 0	Clear sky
# 1, 2, 3	Mainly clear, partly cloudy, and overcast
# 45, 48	Fog and depositing rime fog
# 51, 53, 55	Drizzle: Light, moderate, and dense intensity
# 56, 57	Freezing Drizzle: Light and dense intensity
# 61, 63, 65	Rain: Slight, moderate and heavy intensity
# 66, 67	Freezing Rain: Light and heavy intensity
# 71, 73, 75	Snow fall: Slight, moderate, and heavy intensity
# 77	Snow grains
# 80, 81, 82	Rain showers: Slight, moderate, and violent
# 85, 86	Snow showers slight and heavy
# 95 *	Thunderstorm: Slight or moderate
# 96, 99 *	Thunderstorm with slight and heavy hail

WEATHER_CODE_CONVERSION = {0: 'Clear Sky',
                 1: 'Mainly Clear',
                 2: 'Partly Cloudy',
                 3: 'Overcast',
                 45: 'Foggy',
                 48: 'Rime Fog',
                 51: 'Light Drizzle',
                 53: 'Moderate Drizzle',
                 55: 'Dense Drizzle',
                 56: 'Light Freezing Drizzle',
                 57: 'Dense Freezing Drizzle',
                 61: 'Slight Rain',
                 63: 'Moderate Rain',
                 65: 'Heavy Rain',
                 66: 'Light Freezing Rain',
                 67: 'Heavy Freezing Rain',
                 71: 'Slight Snow',
                 73: 'Moderate Snow',
                 75: 'Heavy Snow',
                 77: 'Snow Grains',
                 80: 'Slight Rain Showers',
                 81: 'Moderate Rain Showers',
                 82: 'Violent Rain Showers',
                 85: 'Slight Snow Showers',
                 86: 'Heavy Snow Showers',
                 95: 'Thunderstorm',
                 96: 'Thunderstorm with Slight Hail',
                 99: 'Thunderstorm with Heavy Hail'
                 }

# API call: https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current_weather=true
API_URL = 'https://api.open-meteo.com/v1/forecast'

SPEED_CONV = {'slow': 0.9, 'average': 1.34, 'fast': 1.79} # m/s
MET_CONV = {'slow': 2.8, 'average': 3.5, 'fast': 5.0}

def get_weather_code(lat: float, lon: float)-> int:
    res = requests.get(f'{API_URL}?latitude={lat}&longitude={lon}&current_weather=true')
    res = res.json()
    return res['current_weather']['weathercode']

def get_weather_code_conv(weather_code: int) -> str:
    return WEATHER_CODE_CONVERSION[weather_code]

def calc_calories_burned(height: float, weight: float, steps: int, pace: str='average'):
    # Source: https://www.omnicalculator.com/sports/steps-to-calories 
    # Calculations
    # Required: weight(kg), height(m), steps, pace(m/s)
    # Slow - 0.9 m/s (2.8 MET)
    # Average - 1,34 m/s (3.5 MET) DEFAULT TO AVERAGE
    # Fast - 1,79 m/s (5 MET)

    # stride = height × 0.414
    # walked distance = stride × steps
    # walking time = distance/speed

    # calories = time × MET × 3.5 × weight/(200 × 60) in kcal

    speed = SPEED_CONV[pace]
    met = MET_CONV[pace]
    stride = (height / 100) * 0.414
    dist = stride * steps
    time = dist / speed
    cals = time * met * 3.5 * weight / (200 * 60)
    return cals

def get_user_data(email: str) -> dict:
    user_file = open('./data/user_profile.json', 'r')
    user_data = json.load(user_file)
    exercise = user_data[email]['exercise']
    location = user_data[email]['location']
    user_profile = user_data[email]['user_profile']
    return {user_profile, exercise, location}

def get_steps_by_day(exercise_data: str, date: str):
    date = parser.isoparse(date).date()
    return exercise_data['steps_data'][date]

def get_exercise_message(steps: int, step_goal: int, location: dict) -> str:
    lat, lon = location['lat'], location['lon']
    weather = get_weather_code_conv(get_weather_code(lat, lon))
    if steps >= step_goal:
        return f'reached goal'
    steps_left = step_goal - steps
    # come up with diff messages based on how many steps left and weather
    return f'{steps_left} steps left till goal'

def get_activity_recommendation(email:str, date:str) -> dict:
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
            'steps': {'goal': step_goal,
                      'steps': steps},
            'message': message}

print(get_weather_code(40.7128,74.0060))
print(get_weather_code_conv(get_weather_code(33.6897734, -117.82164237)))
print(calc_calories_burned(144.0, 15.875732950000002, 11524))