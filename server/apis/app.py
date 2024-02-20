from flask import Flask, request
from waitress import serve
from register import register_user
from signin import signin_user
import requests

from server.apis import utilities

app = Flask(__name__)
app.json.sort_keys = False


@app.route("/v1/register", methods=['POST'])
def v1register():
    authentication = request.headers["Authorization"]

    data_retrieved_register = request.data
    decoded_data_register = data_retrieved_register.decode('utf-8')
    return register_user(authentication, decoded_data_register)


@app.route("/v1/signIn", methods=['POST'])
def v1signIn():
    authentication = request.headers["Authorization"]

    data_retrieved_sign_in = request.data
    decoded_data_sign_in = data_retrieved_sign_in.decode('utf-8')
    return signin_user(authentication, decoded_data_sign_in)


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
