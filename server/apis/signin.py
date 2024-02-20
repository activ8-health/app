import apis.utilities as utilities
import json
import apis.model as model


def signin_user(authentication, new_data) -> (str, int):
    with open("./data/login_data.json", "r") as infile:
        email, password = utilities.get_email_password(authentication)
        check_email = utilities.check_email_password(email, password, 1)
        if check_email == 401:
            return {'error_message': 'Incorrect email or password'}, 401

        data = utilities.retrieve_data_from_file("../data/user_profile.json")
        user_stored_data = data[email]
        user_profile = model.UserProfile(email, password, user_stored_data['user_profile'], None,
                                         user_stored_data['food'], user_stored_data['exercise'],
                                         user_stored_data['sleep'], user_stored_data['location'], 1)
        update_data = json.loads(new_data)
        user_profile.update_step_data(update_data['health_data']['step_data'])
        user_profile.update_sleep_data(update_data['health_data']['sleep_data'])
        user_profile.update_location(update_data['location'])
        _, user = user_profile.serialize()
        data[email] = user
        utilities.write_data_to_file("./data/user_profile.json", data, user)
        return user[email], 200
