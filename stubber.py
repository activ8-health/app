import base64
import json
import sys
from datetime import datetime
from urllib.parse import urlparse

import requests
from flask import Flask, request
from requests.auth import HTTPBasicAuth

app = Flask(__name__)

# "api" : ("method", should_redirect)
apis = {
    # User3
    "register": ("POST", True),
    "signIn": ("POST", True),

    # Home
    "getHomeView": ("GET", True),

    # Sleep
    "getSleepRecommendation": ("GET", True),

    # Food
    "addFoodLogEntry": ("POST", True),
    "removeFoodLogEntry": ("POST", True),
    "getFoodRecommendation": ("GET", True),

    # Activity
    "getActivityRecommendation": ("GET", True),

    # Background
    "updateHealthData": ("POST", True),
}


def setup():
    for api, (method, should_redirect) in apis.items():
        print(f"Creating handler for /v1/{api} for {method}")

        function = create_function(api, method, should_redirect)
        app.add_url_rule(rule=f"/v1/{api}", methods=[method], view_func=function)


def create_function(api: str, method: str, should_redirect: bool):
    def function():
        process_auth(api)
        # time.sleep(1)

        # Get data
        if method == "POST":
            data = request.data.decode('utf-8')
        else:
            data = json.dumps(request.args)

        # Record data
        time_of_request: str = datetime.now().isoformat()
        with open(f"input_logs/{api}-{time_of_request}.json", "w") as file:
            json.dump(json.loads(data), file, indent=2)

        # Redirect if can
        if should_redirect:
            url = urlparse(request.url)
            url = url._replace(netloc=f"localhost:8085")
            print(f"Redirecting to {url.geturl()}")

            authorization = request.headers["Authorization"]
            decoded = base64.b64decode(authorization[6:])
            email_pass = decoded.split(b':', 1)

            response = requests.request(method, url.geturl(), auth=HTTPBasicAuth(*email_pass), data=request.data)
            return response.content, response.status_code

        # Give response
        with open(f"outputs/{api}.json", "r") as file:
            return json.load(file)

    function.__name__ = api
    return function


def process_auth(api: str):
    print(f"Received request for {api}")
    authorization = request.headers["Authorization"]
    decoded = base64.b64decode(authorization[6:])
    email_pass = decoded.split(b':', 1)
    print(f'email: {email_pass[0]}, password: {email_pass[1]}')


if __name__ == '__main__':
    port = sys.argv[1]
    setup()
    app.run(host='0.0.0.0', port=int(port), debug=True)
