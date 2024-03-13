# API Reference

- [API Reference](#api-reference)
  - [Authentication](#authentication)
    - [`/v1/register`](#v1register)
    - [`/v1/signIn`](#v1signin)
  - [Home Page](#home-page)
    - [`/v1/getHomeView`](#v1gethomeview)
  - [Sleep](#sleep)
    - [`/v1/getSleepRecommendation`](#v1getsleeprecommendation)
  - [Food](#food)
    - [`/v1/getFoodRecommendation`](#v1getfoodrecommendation)
    - [`/v1/addFoodLogEntry`](#v1addfoodlogentry)
    - [`/v1/removeFoodLogEntry`](#v1removefoodlogentry)
  - [Exercise](#exercise)
    - [`/v1/getActivityRecommendation`](#v1getactivityrecommendation)
  - [Background](#background)
    - [`/v1/updateHealthData`](#v1updatehealthdata)
- [Structures](#structures)
  - [`UserProfile`](#userprofile)
  - [`HealthData`](#healthdata)
    - [`SleepDataPoint`](#sleepdatapoint)
    - [`StepDataPoint`](#stepdatapoint)


## Authentication

### `/v1/register`

- POST request
- Auth (Basic): `user` (email address) and `pass`
- Input (Body, JSON)
    - `user_profile`: [`UserProfile`](#userprofile) object
    - `health_data`: [`HealthData`](#healthdata) object
    - `sleep_preferences`
        - `core_hours`
            - `start`: time of day (int minutes since 12:00 AM)
            - `end`: time of day (int minutes since 12:00 AM)
    - `food_preferences`
        - `dietary`
            - `vegan`: bool
            - `vegetarian`: bool
            - `kosher`: bool
            - `halal`: bool
            - `pescetarian`: bool
            - `sesame_free`: bool
            - `soy_free`: bool
            - `gluten_free`: bool
            - `lactose_intolerant`: bool
            - `nut_allergy`: bool
            - `peanut_allergy`: bool
            - `shellfish_allergy`: bool
            - `wheat_allergy`: bool
        - `weight_goal`: int 0-2 (0: maintain weight, 1: lose weight, 2: gain weight)
    - `exercise_preferences`
        - `reminder_time`: time of day (int minutes since 12:00 AM)
        - `step_goal`: int
    - `location`: (nullable) tuple of coordinates
    - TODO: this should also include the following, but since that was not specified at the time of writing, we can leave it off for now
    - `food_log`
        - list, each item contains:
            - `entry_id`: UUIDv4
            - `food_id`: ID
            - `date`: ISO 8601 date
            - `portion_eaten`: float, multiplier of serving size
            - `rating`: integer 1-5
            - `location`: (nullable) tuple of coordinates
- Output (JSON)
    - 200 if success
        - N/A
    - 409 if email is already in use
        - `error_message`: the error message to show the user
    - 400 if the request was malformed
        - `error_message`: the error message to show the user

### `/v1/signIn`

- POST request
- Auth (Basic): `user` (email address) and `pass`
- Input (Body, JSON)
    - `health_data`: [`HealthData`](#healthdata) object
    - `location`: (nullable) tuple of coordinates
- Output (JSON)
    - 200 if success
        - `user_profile`: [`UserProfile`](#userprofile) object
        - `sleep_preferences`
            - `core_hours`
                - `start`: time of day (int minutes since 12:00 AM)
                - `end`: time of day (int minutes since 12:00 AM)
        - `food_preferences`
            - `dietary`
                - `vegan`: bool
                - `vegetarian`: bool
                - `kosher`: bool
                - `halal`: bool
                - `pescetarian`: bool
                - `sesame_allergy`: bool
                - `soy_allergy`: bool
                - `gluten_sensitive`: bool
                - `lactose_intolerant`: bool
                - `nut_allergy`: bool
                - `peanut_allergy`: bool
                - `shellfish_allergy`: bool
                - `wheat_allergy`: bool
            - `weight_goal`: int 0-2 (0: maintain weight, 1: lose weight, 2: gain weight)
        - `exercise_preferences`
            - `reminder_time`: time of day (int minutes since 12:00 AM)
            - `step_goal`: int
    - 401 if email is invalid OR password is incorrect
        - `error_message`: the error message to show the user
    - 400 if the request was malformed
        - `error_message`: the error message to show the user

## Home Page

### `/v1/getHomeView`

- GET request
- Auth (Basic): `user` (email address) and `pass`
- Input (URL search parameter, which means these are float-convertible strings)
    - `location_lat`: (nullable) latitude
    - `location_lon`: (nullable) longitude
- Output (JSON)
    - 200 if success
        - `fitness_score`: int between 0 and 100 (inclusive)
        - `message`: string (some motivational message)
    - 401 authentication error  (if email is invalid OR password is incorrect)
        - `error_message`: the error message to show the user
- Notes
    - Calculating this should honestly not take too long
    - If it does, we can move to preprocessing

## Sleep

### `/v1/getSleepRecommendation`

- GET request
- Auth (Basic): `user` (email address) and `pass`
- Input (URL search parameter, which means these are float-convertible strings)
    - `location_lat`: (nullable) latitude
    - `location_lon`: (nullable) longitude
    - `date`: (nullable) ISO 8601 date
- Output (JSON)
    - 200 if success
        - `ideal_sleep_range`
            - `start`: time of day (int minutes since 12:00 AM)
            - `end`: time of day (int minutes since 12:00 AM)
        - `message`: string (some motivational message about sleep)
            - @jennifer Quach I’m thinking of removing this, unless you have ideas of what messages to tell the user
    - 401 authentication error  (if email is invalid OR password is incorrect)
        - `error_message`: the error message to show the user
- Notes
    - Calculating this should honestly not take too long
    - If it does, we can move to preprocessing

## Food

### `/v1/getFoodRecommendation`

- GET request
- Auth (Basic): `user` (email address) and `pass`
- Input (URL search parameter, which means these are float-convertible strings)
    - `location_lat`: (nullable) latitude
    - `location_lon`: (nullable) longitude
    - `date`: (nullable) ISO 8601 date
- Output (JSON)
    - 200 if success
        - `calories`
            - `daily_target`: int
            - `consumed_today`:  int
        - `food_recommendations`
            - list containing 0-3 string Food IDs
        - `message`: string (message about how much the user is eating)
    - 401 authentication error  (if email is invalid OR password is incorrect)
        - `error_message`: the error message to show the user
- Notes
    - For now, we can try running the ML on query time and see where it takes us
    - If it takes too long, we can move to preprocessing

### `/v1/addFoodLogEntry`

- POST request
- Auth (Basic): `user` (email address) and `pass`
- Input (Body, JSON)
    - `entry_id`: UUIDv4
    - `food_id`: ID
    - `date`: ISO 8601 date
    - `portion_eaten`: float, multiplier of serving size
    - `rating`: integer 1-5
    - `location`: (nullable) tuple of coordinates
- Output (JSON)
    - 200 if success
        - N/A
    - 409 if the entry already exists
        - `error_message`: the error message to show the user
    - 401 authentication error  (if email is invalid OR password is incorrect)
        - `error_message`: the error message to show the user
    - 400 if the request was malformed
        - `error_message`: the error message to show the user
- Notes
    - Should trigger a rebuild in food recommendations

### `/v1/removeFoodLogEntry`

- POST request
- Auth (Basic): `user` (email address) and `pass`
- Input (Body, JSON)
    - `entry_id`: UUIDv4
    - `date`: ISO 8601 date of entry
    - `location`: (nullable) tuple of coordinates
- Output (JSON)
    - 200 if success
        - N/A
    - 404 if the entry does not exists
        - `error_message`: the error message to show the user
    - 401 authentication error  (if email is invalid OR password is incorrect)
        - `error_message`: the error message to show the user
    - 400 if the request was malformed
        - `error_message`: the error message to show the user
- Notes
    - Should trigger a rebuild in food recommendations

## Exercise

### `/v1/getActivityRecommendation`

- GET request
- Auth (Basic): `user` (email address) and `pass`
- Input (URL search parameter, which means these are float-convertible strings)
    - `location_lat`: (nullable) latitude
    - `location_lon`: (nullable) longitude
- Output (JSON)
    - 200 if success
        - `calories_burned`: int
        - `steps`
            - `daily_target`: int
            - `progress_today`:  int
        - `message`: string (message about the user’s progress based on Weather data)
    - 401 authentication error  (if email is invalid OR password is incorrect)
        - `error_message`: the error message to show the user
- Notes
    - I believe most calculates can be done on the fly
        - Weather data might take longer (expect ~400ms delay)
    - Stretch goal
        - Maybe we can cache weather data and only re-fetch if the weather if the location changed a lot OR weather is older than like 12 hours

## Background

### `/v1/updateHealthData`

- POST request
- Auth (Basic): `user` (email address) and `pass`
- Input (Body, JSON)
    - `health_data`: [`HealthData`](#healthdata) object
    - `location`: (nullable) tuple of coordinates
- Output (JSON)
    - 200 if success
        - N/A
    - 401 authentication error  (if email is invalid OR password is incorrect)
        - `error_message`: the error message to show the user
    - 400 if the request was malformed
        - `error_message`: the error message to show the user
- Notes
    - This **replaces** all of the datapoints we keep for the user in the backend
    - Should trigger a rebuild in sleep recommendations
    - Should trigger a rebuild in food recommendations (calorie limit updates)
    - Should trigger a rebuild in exercise recommendations (calorie goal updates)

# Structures

These structures are just for organization and so I don’t have to repeat myself

The names don’t mean anything and won’t show up in the request

## `UserProfile`

- `name`: string
- `age`: int
- `height`: double, cm
- `weight`: double, kg
- `sex`: integer 0-2 (0: male, 1: female, 2: indeterminate)

## `HealthData`

- `step_data`: list of step points
    - list containing [`StepDataPoint`](#stepdatapoint) objects
- `sleep_data`: list of sleep points
    - list containing [`SleepDataPoint`](#sleepdatapoint) objects

### `SleepDataPoint`

- `date_from`: ISO 8601 date
- `date_to`: ISO 8601 date

### `StepDataPoint`

- `dateFrom`: ISO 8601 date
- `dateTo`: ISO 8601 date
- `steps`: int