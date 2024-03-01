import os

from flask import Flask, request
from waitress import serve
from apis.register import register_user
from apis.signin import signin_user
import sys
from datetime import datetime, timedelta
from apis import sleep
from apis import exercise
from apis import food
import apis.state as manage_instance
import apis.update as update
import apis.food_entry as food_entry

import apis.utilities as utilities

app = Flask(__name__)
app.json.sort_keys = False
PORT = 8080


@app.route("/v1/register", methods=['POST'])
def v1register():
    authentication, status = utilities.check_authorization(request.headers)
    if status != 200:
        return authentication, status

    data_retrieved_register = request.data
    decoded_data_register = data_retrieved_register.decode('utf-8')
    instance = manage_instance.ProfileManager.instance()
    return register_user(authentication, decoded_data_register, instance)


@app.route("/v1/signIn", methods=['POST'])
def v1signIn():
    authentication, status = utilities.check_authorization(request.headers)
    if status != 200:
        return authentication, status

    data_retrieved_sign_in = request.data
    decoded_data_sign_in = data_retrieved_sign_in.decode('utf-8')
    instance = manage_instance.ProfileManager.instance()
    return signin_user(authentication, decoded_data_sign_in, instance)


@app.route("/v1/getSleepRecommendation", methods=['GET'])
def v1sleep_recommendation():
    instance = manage_instance.ProfileManager.instance()
    email_or_error_message, status = utilities.check_authentication_login(request.headers, instance)
    if status != 200:
        return email_or_error_message, status

    sleep_args = request.args
    utilities.update_location(email_or_error_message, sleep_args, instance)

    date = sleep_args.get('date')
    if date is None:
        date = (datetime.now() - timedelta(hours=6)).isoformat()
    return sleep.get_sleep_recommendation(email_or_error_message, date)


@app.route("/v1/getFoodRecommendation", methods=['GET'])
def v1food_recommendation():
    instance = manage_instance.ProfileManager.instance()
    email_or_error_message, status = utilities.check_authentication_login(request.headers, instance)
    if status != 200:
        return email_or_error_message, status

    food_args = request.args
    utilities.update_location(email_or_error_message, food_args, instance)

    return food.get_food_recommendation(email_or_error_message, instance)


@app.route("/v1/addFoodLogEntry", methods=['POST'])
def v1addFoodLogEntry():
    authentication, status = utilities.check_authorization(request.headers)
    if status != 200:
        return authentication, status

    data_retrieved_food_log = request.data
    decoded_data_food_log = data_retrieved_food_log.decode('utf-8')
    instance = manage_instance.ProfileManager.instance()
    return food_entry.add_food_entry(authentication, decoded_data_food_log, instance)


@app.route("/v1/getActivityRecommendation", methods=['GET'])
def v1activity_recommendation():
    instance = manage_instance.ProfileManager.instance()
    email_or_error_message, status = utilities.check_authentication_login(request.headers, instance)
    if status != 200:
        return email_or_error_message, status

    exercise_args = request.args
    utilities.update_location(email_or_error_message, exercise_args, instance)
    return exercise.get_activity_recommendation(email_or_error_message, datetime.now().isoformat())


@app.route("/v1/updateHealthData", methods=['POST'])
def v1update_health_data():
    authentication, status = utilities.check_authorization(request.headers)
    if status != 200:
        return authentication, status

    data_retrieved_update_data = request.data
    decoded_data_update_data = data_retrieved_update_data.decode('utf-8')
    instance = manage_instance.ProfileManager.instance()
    return update.update_health_data(authentication, decoded_data_update_data, instance)


mode = 'dev'
if __name__ == '__main__':
    path = os.path.join(os.getcwd(), "data")
    if not os.path.exists(path):
        os.makedirs(path)

    if len(sys.argv) > 1:
        PORT = sys.argv[1]

    if mode == 'dev':
        app.run(host='localhost', port=int(PORT), debug=True)
    else:
        serve(app, host='localhost', port=int(PORT), threads=2)
