import csv
import json
from collections import defaultdict
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

        try:
            with open("./data/menu_data.json", "r") as menu_data_file:
                self.menu_data = json.load(menu_data_file)
        except FileNotFoundError:
            self.menu_data = {}
        except json.JSONDecodeError:
            self.menu_data = {}

        self.menu_id_food = defaultdict(str)
        self.menu_food_id = defaultdict(int)
        self.menu_feature_names = []
        self.menu_feature = []
        try:
            with open("./data/menu_data2.csv", "r") as menu_data_feature:
                menu_feature = csv.DictReader(menu_data_feature)
                for count, menu in enumerate(menu_feature):
                    self.menu_food_id[menu['food_name']] = count
                    self.menu_id_food[count] = menu['food_name']
                    menu.pop('food_name')
                    self.menu_feature.append([float(value) for _, value in menu.items()])
                self.menu_feature_names = [key for key, _ in menu.items()]

        except FileNotFoundError:
            self.menu_feature = {}

    def get_menu_feature(self):
        return self.menu_food_id, self.menu_id_food, self.menu_feature_names, self.menu_feature

    def get_menu_data(self):
        return self.menu_data['food']

    def get_menu_data_food(self, food):
        for food_item in self.menu_data['food']:
            if food_item['Food Name'] == food:
                return food_item
        return None

    def get_all_menu_items_name(self):
        return set(food['Food Name'] for food in self.menu_data['food'])

    def get_login_data(self, email):
        return self.login_data[email]

    def get_user(self, email, flag=0):
        return utilities.create_user(email, self.login_data[email]['password'], self.user_data[email], flag)

    def update_user(self, email, update_user_profile):
        login_data, user_data = update_user_profile.serialize()

        with open("./data/login_data.json", "w") as login_data_file:
            self.login_data[email] = login_data[email]
            json.dump(self.login_data, login_data_file, indent=2)

        with open("./data/user_profile.json", "w") as user_profile_file:
            self.user_data[email] = user_data[email]
            json.dump(self.user_data, user_profile_file, indent=2)

        return update_user_profile.serialize_return()
