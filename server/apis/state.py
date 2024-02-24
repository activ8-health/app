import json
import apis.utilities as utilities


class ProfileManager:
    _instance = None

    @classmethod
    def instance(cls):
        if cls._instance is None:
            cls._instance = ProfileManager()
        return cls._instance

    def __init__(self):
        try:
            with open("./data/user_profile.json", "r") as user_profile_file:
                self.user_data = json.load(user_profile_file)
        except FileNotFoundError:
            self.user_data = {}
        except json.JSONDecodeError:
            self.user_data = {}

        try:
            with open("./data/login_data.json", "r") as login_data_file:
                self.login_data = json.load(login_data_file)
        except FileNotFoundError:
            self.login_data = {}
        except json.JSONDecodeError:
            self.login_data = {}

    def get_login_data(self, email):
        return self.login_data[email]

    def get_user(self, email, flag=0):
        return utilities.create_user(email, self.login_data[email]['password'], self.user_data[email], flag)

    def update_user(self, email, update_user_profile):
        login_data, user_data = update_user_profile.serialize()

        # with open("./data/login_data.json", "w") as login_data_file:
        #     self.login_data[email] = login_data[email]
        #     json.dump(self.login_data, login_data_file, indent=2)

        with open("./data/user_profile.json", "w") as user_profile_file:
            self.user_data[email] = user_data[email]
            json.dump(self.user_data, user_profile_file, indent=2)

        return update_user_profile.serialize_return()
