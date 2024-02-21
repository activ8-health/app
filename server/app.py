from flask import Flask, request
from waitress import serve
from apis.register import register_user
from apis.signin import signin_user
import requests
from apis import sleep

import apis.utilities as utilities

app = Flask(__name__)
app.json.sort_keys = False


@app.route("/v1/register", methods=['POST'])
def v1register():
    authentication, status = utilities.check_authorization(request.headers)
    if status != 200:
        return authentication, status

    data_retrieved_register = request.data
    decoded_data_register = data_retrieved_register.decode('utf-8')
    return register_user(authentication, decoded_data_register)


@app.route("/v1/signIn", methods=['POST'])
def v1signIn():
    authentication, status = utilities.check_authorization(request.headers)
    if status != 200:
        return authentication, status

    data_retrieved_sign_in = request.data
    decoded_data_sign_in = data_retrieved_sign_in.decode('utf-8')
    return signin_user(authentication, decoded_data_sign_in)


@app.route("/v1/getSleepRecommendation", methods=['GET'])
def sleep_recommendation():
    authentication, status = utilities.check_authorization(request.headers)
    if status != 200:
        return authentication, status

    with open("./data/login_data.json", "r") as infile:
        email, password = utilities.get_email_password(authentication)
        check_email = utilities.check_email_password(email, password, 1)
        if check_email == 401:
            return {'error_message': 'Incorrect email or password'}, 401

    data_retrieved_sleep = request.data
    decoded_data_sign_in = data_retrieved_sleep.decode('utf-8')
    return {}  # sleep.get_sleep_recommendation(email)


@app.route("/v1/getFoodRecommendation", methods=['GET'])
def food_recommendation():
    authentication = request.headers["Authorization"]
    status, email, password = utilities.create_email_password(authentication)

    param = {
        'email': email,
        'password': password,
    }
    data = requests.get('http://localhost:8080/v1/getFoodRecommendation', params=param)
    print(data.content)
    return "Hello, World!"


mode = 'dev'
if __name__ == '__main__':
    if mode == 'dev':
        app.run(host='localhost', port=8080, debug=True)
    else:
        serve(app, host='localhost', port=8080, threads=2)
