import datetime
from dateutil import parser

IDEAL_SLEEP_RANGE = 8
IDEAL_SLEEP_RANGE_IN_MINS = 8 * 60
data = {
    1: [1,2,3],
    2: [2,3,4],
    3: [3,4,5],
    4: [4,5,6],
    5: [5,6,7],
    6: [6.7,1],
    7: [7,1,2] 
}

def get_core_hours():
    return {"start": 8*60, "end": 17*60}

def get_day_of_week_data(date):
    # assuming date is a string that is in iso format
    # convert to datetime 
    # get day of week as int
    day_of_week = parser.isoparse(date).isoweekday()
    # find the list of sleep points associated with this day
    # and return it
    return data[day_of_week]

def convert_to_time_of_day(date):
    time = parser.isoparse(date).time()
    hour = time.hour
    mins = time.minute
    return hour * 60 + mins

def avg(times):
    return sum(times)/len(times)

def calculate_sleeptime(start_time, end_time):
    if start_time > end_time:
        return end_time + (24 * 60) - start_time
    return end_time - start_time

def convert_to_hours(time):
    return time / 60

def get_day_diff(date1, date2):
    datetime1 = parser.isoparse(date1).date()
    datetime2 = parser.isoparse(date2).date()
    diff = datetime2-datetime1
    return diff.days

def remove_one_day_diff(time):
    return time - (24 * 60)

def remove_all_day_diff(time):
    while time >= (24 * 60):
        time = remove_one_day_diff(time)
    return time

def get_avg_sleep_times(sleep_data):
    start_data = []
    end_data = []
    for i in range(len(sleep_data)):
        start_date = sleep_data[i]['start']
        end_date = sleep_data[i]['end']
        day_diff = get_day_diff(start_date, end_date)
        start = convert_to_time_of_day(start_date)
        end = convert_to_time_of_day(end_date)
        end += (day_diff*24*60)
        start_data.append(start)
        end_data.append(end)
    avg_start = avg(start_data)
    avg_end = avg(end_data)
    return avg_start, avg_end

def get_recommended_sleep_time(time, time2):
# def get_recommended_sleep_time(date):
    # sleep_data = get_day_of_week_data(date)
    # avg_start, avg_end = get_avg_sleep_times(sleep_data)
    avg_start, avg_end = time, time2
    # check with core and adjust
    core_hours = get_core_hours()
    print('core horus')
    print(core_hours)
    print('start', avg_start, 'end', avg_end)
    print('start', convert_to_hours(avg_start), 'end', convert_to_hours(remove_all_day_diff(avg_end)))
    if core_hours['start'] > core_hours['end']:
        core_end = core_hours['end'] + (24 * 60)
        core_start = core_hours['start']
    else:
        core_start = core_hours['start']
        core_end = core_hours['end']
    if avg_start < remove_all_day_diff(core_end):
        avg_start = remove_all_day_diff(core_end)
    if avg_end > core_start:
        avg_end = core_start
        if avg_start > avg_end:
            avg_end += (24*60)
    print(core_start, core_end)
    sleep_time = calculate_sleeptime(avg_start, avg_end)
    print('before adjustment')
    print('start', avg_start, 'end', avg_end)
    print('start', convert_to_hours(avg_start), 'end', convert_to_hours(remove_all_day_diff(avg_end)))
    print('time', convert_to_hours(sleep_time))
    if sleep_time == IDEAL_SLEEP_RANGE_IN_MINS:
        return avg_start, remove_all_day_diff(avg_end)
    elif sleep_time < IDEAL_SLEEP_RANGE_IN_MINS:
        if avg_start == remove_all_day_diff(core_end) and remove_all_day_diff(avg_end) == core_start:
            return avg_start, remove_all_day_diff(avg_end)
        # adjust only start then check with core and adjust if needed
        print('less')
        diff = IDEAL_SLEEP_RANGE_IN_MINS - sleep_time
        avg_start -= diff
        if avg_start < 0:
            avg_start = (24 * 60) + avg_start
        elif avg_start == 0:
            avg_start = 0
        print('start',avg_start)
        print(core_end)
        print(remove_all_day_diff(core_end))
        print(core_start)
        if avg_start < core_end and avg_start > core_start:
            print('sounds abt right')
            avg_start = remove_all_day_diff(core_end)
        sleep_time = calculate_sleeptime(avg_start, avg_end)
        if sleep_time == IDEAL_SLEEP_RANGE_IN_MINS:
            return avg_start, remove_all_day_diff(avg_end)
        # check with core hours
        if avg_start < core_end and avg_start > core_start:
            print('end', remove_all_day_diff(core_end))
            avg_start = remove_all_day_diff(core_end)
        if sleep_time == IDEAL_SLEEP_RANGE_IN_MINS:
            return avg_start, remove_all_day_diff(avg_end)
        elif sleep_time > IDEAL_SLEEP_RANGE_IN_MINS:
            diff = sleep_time - IDEAL_SLEEP_RANGE_IN_MINS
            avg_end -= diff
            if avg_end < 0:
                avg_end = (24 * 60) + avg_end
            elif avg_end == 0:
                avg_end = 0
        elif sleep_time < IDEAL_SLEEP_RANGE_IN_MINS:
            diff = IDEAL_SLEEP_RANGE_IN_MINS - sleep_time
            avg_end += diff 
            if remove_all_day_diff(avg_end) > core_start:
                avg_end = core_start
            if avg_start > avg_end:
                avg_end += (24*60)
        # return avg_start, remove_all_day_diff(avg_end)
    elif sleep_time > IDEAL_SLEEP_RANGE_IN_MINS:
        # adjust only start then check with core and adjust if needed
        print('greater than')
        diff = sleep_time - IDEAL_SLEEP_RANGE_IN_MINS
        print(sleep_time)
        print(IDEAL_SLEEP_RANGE_IN_MINS)
        print('diff', diff)
        avg_start += diff
        if avg_start >= (24 * 60):
            avg_start -= (24 * 60)
            avg_end = remove_one_day_diff(avg_end)
        sleep_time = calculate_sleeptime(avg_start, avg_end)
        print('before core hours check')
        print('start', avg_start, 'end', avg_end)
        print('start', convert_to_hours(avg_start), 'end', convert_to_hours(remove_all_day_diff(avg_end)))
        print('time', convert_to_hours(sleep_time))
        # check with core hours
        if avg_start < core_end and avg_start > core_start:
            print('end', remove_all_day_diff(core_end))
            avg_start = remove_all_day_diff(core_end)
        if sleep_time == IDEAL_SLEEP_RANGE_IN_MINS:
            print('start', avg_start, 'end', avg_end)
            print('start', convert_to_hours(avg_start), 'end', convert_to_hours(remove_all_day_diff(avg_end)))
            print('time', convert_to_hours(sleep_time))
            return avg_start, remove_all_day_diff(avg_end)
        elif sleep_time > IDEAL_SLEEP_RANGE_IN_MINS:
            print('greater')
            diff = sleep_time - IDEAL_SLEEP_RANGE_IN_MINS
            print(avg_end)
            print(avg_start)
            avg_end -= diff
            if avg_end < 0:
                avg_end = (24 * 60) + avg_end
            elif avg_end == 0:
                avg_end = 0
        elif sleep_time < IDEAL_SLEEP_RANGE_IN_MINS:
            print('less')
            diff = IDEAL_SLEEP_RANGE_IN_MINS - sleep_time
            avg_end += diff 
            if remove_all_day_diff(avg_end) > core_start:
                avg_end = core_start
            if avg_start > avg_end:
                avg_end += (24*60)
    print('before return')
    print('avg_end', avg_end)
    print('avg_start', avg_start)
    return avg_start, remove_all_day_diff(avg_end)



print(get_day_of_week_data(datetime.datetime.now().isoformat()))
print(convert_to_time_of_day(datetime.datetime.now().isoformat()))
test = '2022-09-27 02:00:00.000'
test2 = '2022-09-27 10:00:00.000'
day_diff = get_day_diff(test, test2)
print(day_diff)
print(convert_to_hours(calculate_sleeptime(convert_to_time_of_day(test), (day_diff*24*60 + convert_to_time_of_day(test2)))))
print(remove_all_day_diff(day_diff*24*60 + convert_to_time_of_day(test2)))
print('core hours')
print(convert_to_hours(get_core_hours()['start']))
print(convert_to_hours(get_core_hours()['end']))
print('get')
start, end = get_recommended_sleep_time(convert_to_time_of_day(test),(day_diff*24*60 + convert_to_time_of_day(test2)))
print(start)
print(convert_to_hours(start))
print(end)
print(convert_to_hours(end))
print(convert_to_hours(calculate_sleeptime(start, end)))