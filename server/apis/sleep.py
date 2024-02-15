import datetime
from typing import List
from dateutil import parser
import json

IDEAL_SLEEP_RANGE_IN_MINS = 8 * 60
DAY_OF_WEEK_CONVERT = {1: 'Monday',
                       2: 'Tuesday',
                       3: 'Wednesday',
                       4: 'Thursday',
                       5: 'Friday', 
                       6: 'Saturday',
                       7: 'Sunday'}

# data = {'core_hours': {"start": 12*60, "end": 15*60}} # for testing purposes

def get_data() -> dict:
    '''
    opens and loads the user data from the json file to return the user's sleep data
    (may be changed in the future depending on how the data would be stored)
    '''
    user_file = open('user_profile.json', 'r')
    user_data = json.load(user_file)
    return user_data['sleep']

def get_core_hours(user_data: dict) -> dict:
    '''
    user_data: dictionary containing all of the user's sleep data
    returns the user's core hours based on the user data
    '''
    return user_data['core_hours']

def get_day_of_week_data(date: str, user_data: dict) -> List[dict]:
    '''
    date: string of the date in iso format
    user_data: dictionary containing all of the user's sleep data
    returns a list of the sleep data points for a day of the week associated with the date given

    note: sleep data points are objects/dicts consisting of a date_from (essentially start sleep time) 
    and a date_to (essentially end sleep time)

    the date string is converted to a datetime object so a day of the week integer can be obtained
    that int will be converted to its associated key (1 = Monday, 2 = Tuesday, etc)
    it will then find and return the sleep data associated that key (day of the week)
    '''
    day_of_week = parser.isoparse(date).isoweekday()
    return user_data['sleep_data'][DAY_OF_WEEK_CONVERT[day_of_week]]

def convert_to_time_of_day(date: str) -> int:
    '''
    date: string of the date in iso format
    returns the time of day (mins since midnight) for the date given
    '''
    time = parser.isoparse(date).time()
    hour = time.hour
    mins = time.minute
    return hour * 60 + mins

def avg(times: List[int]) -> int:
    '''
    times: list of sleep data points that were converted to time of day
    returns the average time based on those points in time of day
    '''
    return sum(times) // len(times)

def calculate_sleeptime(start_time: int, end_time: int) -> int:
    '''
    start_time: start sleep time in time of day
    end_time: end sleep time in time of day
    returns the sleep time in time of day

    the sleep time is calculed by subtracting the end_time by start_time
    in the case in which start_time is greater than end_time, it would be adjusted
    by adding a day difference (adding 24 hours to the end time) so the correct sleep
    time will be calculated
    '''
    if start_time > end_time:
        return end_time + (24 * 60) - start_time
    
    return end_time - start_time

def convert_to_hours(time: int) -> float:
    '''
    time: some time of day
    returns hour of day

    helper function to convert time of day back to hours for testing
    '''
    return time / 60

def get_day_diff(date1: str, date2: str) -> int:
    '''
    date1: string of the date in iso format (start date)
    date2: string of the date in iso format (end time)
    returns the day difference between these two dates
    '''
    datetime1 = parser.isoparse(date1).date()
    datetime2 = parser.isoparse(date2).date()
    diff = datetime2 - datetime1
    return diff.days

def remove_one_day_diff(time: int) -> int:
    '''
    time: time of day
    returns time of day with one day difference removed from it
    '''
    return time - (24 * 60)

def remove_all_day_diff(time: int) -> int:
    '''
    time: time of day
    returns time of day with all day difference removed from it
    '''
    while time >= (24 * 60):
        time = remove_one_day_diff(time)
    
    return time

def get_avg_sleep_times(sleep_data: List[dict]) -> tuple[int, int]:
    '''
    sleep_data: list of sleep data points
    returns the avg start and end sleep times in time of day

    goes through the list of sleep data points and separate them into a start sleep time list and a end sleep time list
    then calculated the average sleep time based on those lists
    '''
    start_data = []
    end_data = []

    for i in range(len(sleep_data)):
        start_date = sleep_data[i]['date_from']
        end_date = sleep_data[i]['date_to']
        day_diff = get_day_diff(start_date, end_date)
        start = convert_to_time_of_day(start_date)
        end = convert_to_time_of_day(end_date)
        end += (day_diff*24*60)
        start_data.append(start)
        end_data.append(end)
    
    avg_start = avg(start_data)
    avg_end = avg(end_data)

    return avg_start, avg_end

def start_time_less_than_adjustment(avg_start: int, sleep_time: int) -> tuple[int, int]:
    '''
    avg_start: average start sleep time in time of day
    sleep_time: calculated sleep time in minutes
    returns the adjusted average start sleep time to fit ideal sleep range

    calculates the difference between the ideal sleep range and current sleep time
    adjusts the start sleeping time to add in extra sleep time
    also handles case in which start time ends up passing midnight or 
    so the correct time is returned
    '''
    diff = IDEAL_SLEEP_RANGE_IN_MINS - sleep_time
    avg_start -= diff

    if avg_start < 0:
        avg_start = (24 * 60) + avg_start
    
    return avg_start

def start_time_greater_than_adjustment(avg_start: int, avg_end: int, sleep_time: int) -> tuple[int, int]:
    '''
    avg_start: average start sleep time in time of day
    avg_end: average end sleep time in time of day
    sleep_time: calculated sleep time in minutes
    returns the adjusted average start sleep time and average end sleep time to fit ideal sleep range

    calculates the difference between current sleep time and the ideal sleep range
    adjusts the start sleeping time to remove extra sleep time
    also handles case in which start time ends up passing midnight (start time now on same day as end time) 
    by removing a day difference from both start and end time so the correct time is returned
    '''
    diff = sleep_time - IDEAL_SLEEP_RANGE_IN_MINS
    avg_start += diff

    # avg_start and avg_end now on same day remove day difference
    if avg_start >= (24 * 60):
        avg_start -= (24 * 60)
        avg_end = remove_one_day_diff(avg_end)

    return avg_start, avg_end

def end_time_greater_than_adjustment(avg_end: int, sleep_time: int) -> int:
    '''
    avg_end: average end sleep time in time of day
    sleep_time: calculated sleep time in minutes
    returns the adjusted average end sleep time

    calculates the difference between sleep time and ideal sleep range
    adjusts average end sleep time to remove extra sleep time
    also handles case in which end time ends up passing midnight
    so the correct time is returned
    '''
    diff = sleep_time - IDEAL_SLEEP_RANGE_IN_MINS
    avg_end -= diff

    if avg_end < 0:
        avg_end = (24 * 60) + avg_end

    return avg_end

def end_time_less_than_adjustment(avg_start: int, avg_end: int, core_start: int, sleep_time: int) -> int:
    '''
    avg_start: average start sleep time in time of day
    avg_end: average end sleep time in time of day
    core_start: user core hour start in time of day
    sleep_time: calculated sleep time in minutes
    returns the adjusted average end sleep time

    calculates the difference between the ideal sleep range and current sleep time
    adjusts the end sleeping time to add in extra sleep time if permitted
    core hours will be checked so it does not end up conflicting
    if after adjustment the average end sleep time is less than the average start sleep time, 
    it will be adjusted properly
    '''
    diff = IDEAL_SLEEP_RANGE_IN_MINS - sleep_time
    avg_end += diff 

    # if conflicts with core hours, adjust
    if remove_all_day_diff(avg_end) > core_start:
        avg_end = core_start

    if avg_start > avg_end:
        avg_end += (24*60)
    
    return avg_end

def core_hours_check(avg_start: int, avg_end: int, core_start: int, core_end: int) -> tuple[int, int]:
    '''
    avg_start: average start sleep time in time of day
    avg_end: average end sleep time in time of day
    core_start: user core hour start in time of day
    core_end: user core hour end in time of day
    returns adjusted average start sleep time and end sleep time that does not conflict with core hours

    if no conflicts are found between core hours and the calculated average sleep times, nothing will be changed
    if there are conflicts, (only possible for avg_start since it was adjusted to accommodate the ideal sleep range and
    avg_end was already check before adjustment for sleep range) avg_start will be adjusted to be outside core hours
    the new sleep time will be calculated and checked to see if it meets the ideal sleep range
    adjustments will now be made to avg_end if sleep time is over or under ideal sleep range
    if the ideal sleep range cannot be reached, the maximum possible sleep time will be returned
    '''
    # if avg_start conflicts with core hours, adjust
    if avg_start < core_end and avg_start > core_start:
        avg_start = remove_all_day_diff(core_end)

    sleep_time = calculate_sleeptime(avg_start, avg_end)

    if sleep_time == IDEAL_SLEEP_RANGE_IN_MINS:
        return avg_start, remove_all_day_diff(avg_end)
    
    elif sleep_time > IDEAL_SLEEP_RANGE_IN_MINS:
        # adjust avg_end to decrease sleep time
        avg_end = end_time_greater_than_adjustment(avg_end, sleep_time)

    elif sleep_time < IDEAL_SLEEP_RANGE_IN_MINS:
        # adjust avg_end to increase sleep time if possible
        avg_end = end_time_less_than_adjustment(avg_start, avg_end, core_start, sleep_time)

    return avg_start, avg_end

def get_recommended_sleep_time(avg_start: int, avg_end: int, core_hours: dict) -> tuple[int, int]:
    '''
    avg_start: average start sleep time in time of day
    avg_end: average end sleep time in time of day (assumes day difference is already added to avg_end)
    core_hours: dictionary containing the start core hour and end core hour for the user
    returns the recommended start sleep time and end sleep time

    taking into consideration the average start sleep time, average end sleep time, and core hours of the user,
    it makes calculates the recommended start and end sleep time for the user as close to the ideal sleep range as possible
    if the user sleeps too little on average, it will adjust their sleep time for them to sleep more if there are no core hours conflicts
    if the user sleeps to much on average, it will adjust their sleep tiem for them to sleep less and avoid core hours conflicts
    if the user's average sleep time in the past conflicts with current core hours, it will be adjust appropriately
    '''

    # properly set core start and core end based on core hours info
    # if core end is less than core start, a day difference is added
    if core_hours['start'] > core_hours['end']:
        core_end = core_hours['end'] + (24 * 60)
        core_start = core_hours['start']
    else:
        core_start = core_hours['start']
        core_end = core_hours['end']

    # make sure avg_start is not within the range of core hours
    # if it is adjust so it is out of range 
    if avg_start < core_end and avg_start > core_start:
        avg_start = remove_all_day_diff(core_end)

    # make sure avg_end is not within the range of core hours
    # if it is adjust so it is out of range 
    if remove_all_day_diff(avg_end) > core_start:
        avg_end = core_start
        if avg_start > avg_end:
            avg_end += (24*60)

    sleep_time = calculate_sleeptime(avg_start, avg_end)

    if sleep_time == IDEAL_SLEEP_RANGE_IN_MINS:
        # sleep time is ideal so it is returned and does not conflict with core hours
        return avg_start, remove_all_day_diff(avg_end)
    

    elif sleep_time < IDEAL_SLEEP_RANGE_IN_MINS:
        if avg_start == remove_all_day_diff(core_end) and remove_all_day_diff(avg_end) == core_start:
            # sleep time cannot be increased anymore because it will conflict with core hours
            return avg_start, remove_all_day_diff(avg_end)

        # adjust avg_start to increase sleep time
        avg_start = start_time_less_than_adjustment(avg_start, sleep_time)

        # check with core hours for conflicts
        # if there are conflicts adjust avg_start and avg_end
        avg_start, avg_end = core_hours_check(avg_start, avg_end, core_start, core_end)

    elif sleep_time > IDEAL_SLEEP_RANGE_IN_MINS:
        # adjust avg_start to decrease sleep time
        avg_start, avg_end = start_time_greater_than_adjustment(avg_start, avg_end, sleep_time)

        sleep_time = calculate_sleeptime(avg_start, avg_end)

        # check with core hours for conflicts
        # if there are conflicts adjust avg_start and avg_end
        avg_start, avg_end = core_hours_check(avg_start, avg_end, core_start, core_end)

    return avg_start, remove_all_day_diff(avg_end)

def get_sleep_recommendation(date: str) -> dict:
    '''
    date: string of the date in iso format
    returns the recommended start and end sleep time in a dictionary

    retrieves the user data and calculates a recommended sleep time that best fits their schedule and the ideal sleep range
    '''
    user_data = get_data()
    core_hours = get_core_hours(user_data)
    sleep_data = get_day_of_week_data(date, user_data)
    avg_start, avg_end = get_avg_sleep_times(sleep_data)
    rec_start, rec_end = get_recommended_sleep_time(avg_start, avg_end, core_hours)

    return {'start': rec_start, 'end': rec_end}


# some testing
# test = '2022-09-27T23:00:00.000'
# test2 = '2022-09-28T11:00:00.000'
# day_diff = get_day_diff(test, test2)
# print('day diff', day_diff)
# print('sleep time in hrs before adjustment', convert_to_hours(calculate_sleeptime(convert_to_time_of_day(test), ((day_diff*24*60)+convert_to_time_of_day(test2)))))
# print('core hours')
# print('core start', convert_to_hours(get_core_hours(data)['start']))
# print('core end' ,convert_to_hours(get_core_hours(data)['end']))
# print('getting recommended sleep time')
# start, end = get_recommended_sleep_time(convert_to_time_of_day(test),((day_diff*24*60)+convert_to_time_of_day(test2)), data['core_hours'])
# print('rec start', start)
# print('rec start hrs', convert_to_hours(start))
# print('rec end', end)
# print('rec end hrs', convert_to_hours(end))
# print('rec sleep time in hrs', convert_to_hours(calculate_sleeptime(start, end)))