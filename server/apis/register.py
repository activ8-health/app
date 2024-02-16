import utilities
import json
import model


def register_user(authentication, data) -> (str, int):
    # get email and password from authentication
    status, email, password = utilities.create_email_password(authentication)
    if status == 409:
        return 'Email already exist', 409

    # store user info
    data_loads = json.loads(data)
    status = utilities.store_user_info(email, password, data_loads)
    if status == 400:
        return 'Something went wrong', 400

    return "", 200
