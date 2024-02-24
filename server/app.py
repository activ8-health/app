import os

from flask import Flask, request
from waitress import serve
from apis.register import register_user
from apis.signin import signin_user
import sys
from datetime import datetime, timedelta
from apis import sleep
from apis import exercise
import apis.state as manage_instance
import apis.update as update

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
    email, status = utilities.check_authentication_login(request.headers, instance)
    if status != 200:
        return email, status

    sleep_args = request.args
    _, user = instance.get_user(email, 1)
    user.update_location((sleep_args.get("location_lat"), sleep_args.get("location_lon")))
    instance.update_user(email, user)

    date = sleep_args.get('date')
    if date is None:
        date = (datetime.now() - timedelta(hours=6)).isoformat()
    return sleep.get_sleep_recommendation(email, date), 200


@app.route("/v1/getFoodRecommendation", methods=['GET'])
def v1food_recommendation():
    return "Hello, World!"


@app.route("/v1/getActivityRecommendation", methods=['GET'])
def v1activity_recommendation():
    instance = manage_instance.ProfileManager.instance()
    email, status = utilities.check_authentication_login(request.headers, instance)
    if status != 200:
        return email, status

    exercise_args = request.args
    _, user = instance.get_user(email, 1)
    user.update_location((exercise_args.get("location_lat"), exercise_args.get("location_lon")))
    instance.update_user(email, user)

    return exercise.get_activity_recommendation(email, datetime.now().isoformat())


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
