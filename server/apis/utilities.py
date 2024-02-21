import base64
import json
from flask import request
import apis.model as model


def check_authorization(authentication) -> int:
    try:
        authentication = request.headers["Authorization"]
    except KeyError:
        return {'error_message': 'Invalid authorization'}, 400
    return authentication, 200


def get_email_password(authorization) -> (int, str, str):
    """
    Get email and password from authorization, return status code and email, password
    """
    decoded = base64.b64decode(authorization[6:])
    decoded_data = decoded.decode('utf-8')
    email, password = decoded_data.split(':', 1)
    return email, password


def create_email_password(authorization) -> (int, str, str):
    """
    Create email and password from authorization, return status code and email, password
    If email already in use, return status 409, email, password, else return 200, email, password
    """
    email, password = get_email_password(authorization)
    # check if email already in use
    # return status 409, email already in use
    status = check_email_password(email, password, 0)
    if status == 409:
        return 409, email, password

    return 200, email, password


def check_email_password(email, password, flag) -> int:
    """
    Check if email already in use, return 409 if email already in use, 201 if email not in use.
    """
    with open("./data/login_data.json", "r") as infile:
        try:
            data = json.load(infile)
            if email in data:
                if flag == 0:
                    return 409
                else:
                    if data[email]['password'] == password:
                        return 200
                    else:
                        return 401
            else:
                return 401
        except json.JSONDecodeError:
            return 200


def store_user_info(email, password, user_data) -> int:
    """
    Store a list of user along with their info in data/login_data.json and data/user_profile.json,
    return 200 if successful, 400 if not.
    """
    try:
        user_info = user_data['user_profile']
        health_data = user_data['health_data']
        food_data = user_data['food_preferences']
        exercise_data = user_data['exercise_preferences']
        sleep_data = user_data['sleep_preferences']
        location = user_data['location']

        user = model.UserProfile(email, password, user_info, health_data,
                                 food_data, exercise_data, sleep_data, location)
    except ValueError as e:
        print(e)
        return 400

    auth, user_data = user.serialize()

    # store authentication (email, password) in data/login_data.json
    auth_info = retrieve_data_from_file("./data/login_data.json")
    write_data_to_file("./data/login_data.json", auth_info, auth)

    # store user_data in data/user_profile.json
    user_info = retrieve_data_from_file("./data/user_profile.json")
    write_data_to_file("./data/user_profile.json", user_info, user_data)
    return 200


def retrieve_data_from_file(file_name) -> dict:
    """
    Retrieve data from file and return it as a list of dictionaries. If file is empty, return an empty list.
    """
    with open(file_name, 'r') as infile:
        try:
            data = json.load(infile)
        except json.JSONDecodeError:
            data = dict()
    return data


def write_data_to_file(file_name, retrieved_data, info) -> None:
    """
    Write data to file. If file is empty, write info to file as a list. If file is not empty, append info to file.
    """
    with open(file_name, 'w') as outfile:
        if len(retrieved_data) != 0:
            retrieved_data.update(info)
            json.dump(retrieved_data, outfile, indent=2)
        else:
            json.dump(info, outfile, indent=2)
