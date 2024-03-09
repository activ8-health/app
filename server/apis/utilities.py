import base64
import json
from flask import request
import apis.model as model


def check_authorization(headers) -> [str, int]:
    try:
        authentication: str = headers["Authorization"]
    except KeyError:
        return {'error_message': 'Invalid authorization'}, 401
    return authentication, 200


def get_email_password(authorization) -> [int, str, str]:
    """
    Get email and password from authorization, return status code and email, password
    """
    decoded: bytes = base64.b64decode(authorization[6:])
    decoded_data: str = decoded.decode('utf-8')
    email, password = decoded_data.split(':', 1)
    return email, password


def create_email_password(authorization, instance, flag) -> [int, str, str]:
    """
    Create email and password from authorization, return status code and email, password
    If email already in use, return status 409, email, password, else return 200, email, password
    """
    email, password = get_email_password(authorization)

    # check if email already in use
    # return status 409, email already in use
    status: int = check_email_password(email, password, instance, flag)
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


def create_user(email, password, user_data, flag=0) -> [int, model.UserProfile]:
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


def check_authentication_login(headers, instance) -> [str, int]:
    authentication, status = check_authorization(headers)
    if status != 200:
        return authentication, status

    email, password = get_email_password(authentication)
    check_email = check_email_password(email, password, instance, 1)
    if check_email != 200:
        return {'error_message': 'Incorrect email or password'}, 401

    return email, 200


def update_location(email, location, instance) -> None:
    _, user = instance.get_user(email, 1)
    user.update_location((location.get("location_lat"), location.get("location_lon")))
    instance.update_user(email, user)


def update_user_info(new_data, user_profile, email, instance) -> [model.UserProfile, int]:
    update_data = json.loads(new_data)
    user_profile.replace_step_data(update_data['health_data']['step_data'])
    user_profile.replace_sleep_data(update_data['health_data']['sleep_data'])
    user_profile.update_location(update_data['location'])
    user = instance.update_user(email, user_profile)
    return user, 200

