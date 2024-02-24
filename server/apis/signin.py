import apis.utilities as utilities


def signin_user(authentication, new_data, instance) -> (str, int):
    email, password = utilities.get_email_password(authentication)
    check_login = utilities.check_email_password(email, password, instance, 1)
    if check_login != 200:
        return {'error_message': 'Incorrect email or password'}, 401

    status, user_profile = instance.get_user(email, 1)
    if status != 200:
        return {'error_message': 'Something went wrong'}, 400

    user, status = utilities.update_user_info(new_data, user_profile, email, instance)
    return user[email], status
