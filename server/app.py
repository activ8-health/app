import os

from flask import Flask, request
from waitress import serve
from apis.register import register_user
from apis.signin import signin_user
import requests
import sys
from datetime import datetime, timedelta
from apis import sleep
import apis.state as manager_instance

import apis.model as model
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
    instance = manager_instance.ProfileManager.instance()
    return register_user(authentication, decoded_data_register, instance)


@app.route("/v1/signIn", methods=['POST'])
def v1signIn():
    authentication, status = utilities.check_authorization(request.headers)
    if status != 200:
        return authentication, status

    data_retrieved_sign_in = request.data
    decoded_data_sign_in = data_retrieved_sign_in.decode('utf-8')
    instance = manager_instance.ProfileManager.instance()
    return signin_user(authentication, decoded_data_sign_in, instance)


@app.route("/v1/getSleepRecommendation", methods=['GET'])
def v1sleep_recommendation():
    authentication, status = utilities.check_authorization(request.headers)
    if status != 200:
        return authentication, status

    email, password = utilities.get_email_password(authentication)

    instance = manager_instance.ProfileManager.instance()
    check_email = utilities.check_email_password(email, password, instance, 1)
    if check_email == 401:
        return {'error_message': 'Incorrect email or password'}, 401

    sleep_args = request.args

    _, user = instance.get_user(email, 1)
    user.update_location((sleep_args.get("location_lat"), sleep_args.get("location_long")))

    date = sleep_args.get('date')
    if date is None:
        date = (datetime.now() - timedelta(hours=6)).isoformat()
    return sleep.get_sleep_recommendation(email, date)


@app.route("/v1/getFoodRecommendation", methods=['GET'])
def food_recommendation():
    authentication = request.headers["Authorization"]
    status, email, password = utilities.create_email_password(authentication)
    return "Hello, World!"


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
