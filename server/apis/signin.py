import apis.utilities as utilities
import json
import apis.model as model


def signin_user(authentication, new_data, instance) -> (str, int):
    email, password = utilities.get_email_password(authentication)
    check_login = utilities.check_email_password(email, password, instance, 1)
    if check_login == 401:
        return {'error_message': 'Incorrect email or password'}, 401

    status, user_profile = instance.get_user(email, 1)

    if status != 200:
        return {'error_message': 'Something went wrong'}, 400

    update_data = json.loads(new_data)
    user_profile.update_step_data(update_data['health_data']['step_data'])
    user_profile.update_sleep_data(update_data['health_data']['sleep_data'])
    user_profile.update_location(update_data['location'])

    user = instance.update_user(email, user_profile)
    return user[email], 200
