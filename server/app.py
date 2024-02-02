from flask import Flask, request
from waitress import serve
import utilities

app = Flask(__name__)


@app.route("/v1/register", methods=['POST'])
def register_user():
    auth = request.headers["Authorization"]
    user, password = utilities.create_user_password(auth)

    # get json data user's health data???????
    # jsonifity: create response object
    print(request.data)

    return user, password


@app.route("/v1/getFoodRecommendation", methods=['POST'])
def food_recommendation():
    return "Hello, World!"


mode = 'dev'
if __name__ == '__main__':
    if mode == 'dev':
        app.run(host='localhost', port=8080, debug=True)
    else:
        serve(app, host='localhost', port=8080, threads=2)
