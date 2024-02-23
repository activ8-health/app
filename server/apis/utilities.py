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


def create_email_password(authorization, instance, flag) -> (int, str, str):
    """
    Create email and password from authorization, return status code and email, password
    If email already in use, return status 409, email, password, else return 200, email, password
    """
    email, password = get_email_password(authorization)
    # check if email already in use
    # return status 409, email already in use
    status = check_email_password(email, password, instance, flag)
    if status == 409:
        return 409, None, None

    return 200, email, password


def check_email_password(email, password, instance, flag) -> int:
    """
    Check if email already in use, return 409 if email already in use, 201 if email not in use.
    """
    try:
        stored_password = instance.get_login_data(email)
        if flag == 0:
            return 409
        else:
            if stored_password['password'] == password:
                return 200
            else:
                return 401
    except KeyError:
        if flag == 0:
            return 200
        return 401


def create_user(email, password, user_data, flag=0) -> (int, model.UserProfile):
    """
    Create a new user, return 200 if successful, 400 if not.
    """
    try:
        user = model.UserProfile(email, password, user_data, flag)
    except ValueError as e:
        print(e)
        return 400, None
    return 200, user


def store_user_info(email, password, user_data, instance) -> int:
    """
    Store a list of user along with their info in data/login_data.json and data/user_profile.json,
    return 200 if successful, 400 if not.
    """
    status, user = create_user(email, password, user_data)
    if status != 200:
        return status

    instance.update_user(email, user)
    return 200

# TODO DELETE
# def retrieve_data_from_file(file_name) -> dict:
#     """
#     Retrieve data from file and return it as a list of dictionaries. If file is empty, return an empty list.
#     """
#     try:
#         with open(file_name, 'r') as infile:
#             data = json.load(infile)
#     except FileNotFoundError:
#         data = dict()
#     except json.JSONDecodeError:
#         data = dict()
#     return data
#
#
# def write_data_to_file(file_name, retrieved_data, info) -> None:
#     """
#     Write data to file. If file is empty, write info to file as a list. If file is not empty, append info to file.
#     """
#     with open(file_name, 'w') as outfile:
#         if len(retrieved_data) != 0:
#             retrieved_data.update(info)
#             json.dump(retrieved_data, outfile, indent=2)
#         else:
#             json.dump(info, outfile, indent=2)
