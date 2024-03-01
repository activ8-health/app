import json
from apis import utilities
from apis import food_log


def create_food_entry(user, data, menu_data):
    user_food_log = user.food.food_log
    if data['entry_id'] in user_food_log:
        return {'error_message': 'Entry already exists'}, 409

    if data['food_id'] not in menu_data.get_all_menu_items():
        return {'error_message': 'Food item does not exist'}, 400

    food_item = food_log.FoodLog(entry_id=data['entry_id'], food_name=data['food_id'],
                                 date=data['date'], portion_eaten=data['portion_eaten'], rating=data['rating'])
    user.update_food_data(food_item.to_dict())
    return user, 200


def add_food_entry(authentication, food_data, instance):
    email, password = utilities.get_email_password(authentication)
    check_login = utilities.check_email_password(email, password, instance, 1)
    if check_login != 200:
        return {'error_message': 'Incorrect email or password'}, 401

    _, user = instance.get_user(email, 1)
    food_log_data_load = json.loads(food_data)
    user.update_location(food_log_data_load['location'])

    user_or_error_message, status = create_food_entry(user, food_log_data_load, instance)
    if status != 200:
        return user_or_error_message, status
    instance.update_user(email, user_or_error_message)
    return {}, 200


def delete_food_entry(authentication, entry_data, instance):
    email, password = utilities.get_email_password(authentication)
    check_login = utilities.check_email_password(email, password, instance, 1)
    if check_login != 200:
        return {'error_message': 'Incorrect email or password'}, 401

    entry_data_load = json.loads(entry_data)
    _, user = instance.get_user(email, 1)
    user.update_location(entry_data_load['location'])

    if entry_data_load['entry_id'] not in user.food.food_log:
        return {'error_message': 'Entry does not exist'}, 404

    user.food.food_log.pop(entry_data_load['entry_id'])
    instance.update_user(email, user)
    return {}, 200
