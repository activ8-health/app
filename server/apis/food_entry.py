import json
from datetime import datetime
from apis import utilities
from apis import food_log


def create_food_entry(user, data, menu_data):
    user_food_log = user.food.food_log
    for _, entry_id in user_food_log.items():
        if data['entry_id'] in entry_id:
            return {'error_message': 'Entry already exists'}, 409

    if data['food_id'] not in menu_data.get_all_menu_items_name():
        return {'error_message': 'Food item does not exist'}, 400

    food_item = menu_data.get_menu_data_food(data['food_id'])
    food_item = food_log.FoodLog(entry_id=data['entry_id'], food_name=data['food_id'],
                                 date=data['date'], portion_eaten=data['portion_eaten'],
                                 total_calories=float(food_item['Calories']), rating=data['rating'])

    return food_item, 200


def add_food_entry(authentication, food_data, instance):
    email, password = utilities.get_email_password(authentication)
    check_login = utilities.check_email_password(email, password, instance, 1)
    if check_login != 200:
        return {'error_message': 'Incorrect email or password'}, 401

    _, user = instance.get_user(email, 1)
    food_log_data_load = json.loads(food_data)
    user.update_location(food_log_data_load['location'])

    date = datetime.fromisoformat(food_log_data_load['date']).strftime('%Y-%m-%d')
    food_item_or_error_message, status = create_food_entry(user, food_log_data_load, instance)
    if status != 200:
        return food_item_or_error_message, status

    user.add_food_data(date, food_item_or_error_message.to_dict())

    instance.update_user(email, user)
    return {}, 200


def delete_food_entry(authentication, entry_data, instance):
    email, password = utilities.get_email_password(authentication)
    check_login = utilities.check_email_password(email, password, instance, 1)
    if check_login != 200:
        return {'error_message': 'Incorrect email or password'}, 401

    entry_data_load = json.loads(entry_data)
    _, user = instance.get_user(email, 1)
    user.update_location(entry_data_load['location'])

    date = datetime.fromisoformat(entry_data_load['date']).strftime('%Y-%m-%d')
    if entry_data_load['date'] not in user.food.food_log or entry_data_load['entry_id'] not in user.food.food_log[date]:
        return {'error_message': 'Entry does not exist'}, 404

    user.delete_food_data(date, entry_data_load['entry_id'])
    instance.update_user(email, user)
    return {}, 200
