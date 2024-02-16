import base64
import model
import json


def create_email_password(authorization) -> (int, str, str):
    """
    Create email and password from authorization, return status code and email, password
    If email already in use, return status 409, email, password, else return 200, email, password
    """
    decoded = base64.b64decode(authorization[6:])
    decoded_data = decoded.decode('utf-8')
    email, password = decoded_data.split(':', 1)

    # check if email already in use
    # return status 409, email already in use
    status = check_email(email)
    if status == 409:
        return 409, email, password

    return 200, email, password


def check_email(email) -> int:
    """
    Check if email already in use, return 409 if email already in use, 201 if email not in use.
    """
    with open("../data/login_data.json", "r") as infile:
        try:
            data = json.load(infile)
            all_email = [user_login['email'] for user_login in data]
            if email in all_email:
                return 409
        except json.JSONDecodeError:
            return 201


def store_user_info(email, password, user_data) -> int:
    """
    Store a list of user along with their info in data/login_data.json and data/user_profile.json,
    return 200 if successful, 400 if not.
    """
    try:
        user = model.UserProfile(email, password, user_data)
    except ValueError as e:
        print(e)
        return 400

    auth, user_data = user.serialize()

    # store authentication (email, password) in data/login_data.json
    auth_info = retrieve_data_from_file("../data/login_data.json")
    write_data_to_file("../data/login_data.json", auth_info, auth)

    # store user_data in data/user_profile.json
    user_info = retrieve_data_from_file("../data/user_profile.json")
    write_data_to_file("../data/user_profile.json", user_info, user_data)
    return 200


def retrieve_data_from_file(file_name) -> list:
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
