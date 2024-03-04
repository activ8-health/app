import itertools
from collections import defaultdict
from enum import Enum
from apis import model
from datetime import datetime, timedelta
from sklearn.neural_network import MLPClassifier


class BMR(Enum):
    Male = 5
    Female = -161
    Indeterminate = -78


class Dietary(Enum):
    # ContainsFish
    pescetarian = 'IsVegan'
    lactose_intolerant = 'ContainsMilk'
    peanut_allergy = 'ContainsPeanuts'
    sesame_allergy = 'ContainsSesame'
    shellfish_allergy = 'ContainsShellfish'
    soy_allergy = 'ContainsSoy'
    nut_allergy = 'ContainsTreeNuts'
    wheat_allergy = 'ContainsWheat'
    gluten_sensitive = 'IsGlutenFree'
    hala = 'IsHalal'
    kosher = 'IsKosher'
    vegan = 'IsVegan'
    vegetarian = "IsVegetarian"


def calculate_bmr(user_profile):
    # (9.99 × weight[kg]) + (6.25 × height[cm]) − (4.92 × age[years]) + 5
    if type(user_profile) is not model.UserProfile:
        weight = user_profile['user_profile']['weight']
        height = user_profile['user_profile']['height']
        age = user_profile['user_profile']['age']
        sex = user_profile['user_profile']['sex']
    else:
        weight = user_profile.user.weight
        height = user_profile.user.height
        age = user_profile.user.age
        sex = user_profile.user.sex

    bmr = (9.99 * weight) + (6.25 * height) - (4.92 * age) + BMR[sex].value
    return bmr


def get_daily_target(user_profile):
    bmr = calculate_bmr(user_profile)
    if type(user_profile) is not model.UserProfile:
        steps = user_profile['exercise']['step_data']
        goal = user_profile['food']['weight_goal']
    else:
        steps = user_profile.exercise.step_data
        goal = user_profile.food.weight_goal

    total_steps = 0
    for _, steps in itertools.islice(steps.items(), 1, 31):
        total_steps += steps
    total_steps = total_steps / 30

    if total_steps < 5000:
        daily_target = bmr * 1.2
    elif total_steps < 7500:
        daily_target = bmr * 1.375
    elif total_steps < 10000:
        daily_target = bmr * 1.55
    elif total_steps < 12500:
        daily_target = bmr * 1.725
    else:
        daily_target = bmr * 2

    if goal == 'Lose':
        daily_target -= 200
    elif goal == 'Gain':
        daily_target += 500
    return daily_target


def get_calories_consumed_today(user_profile, date):
    calories_consumed = 0
    date = date.strftime('%Y-%m-%d')
    try:
        if type(user_profile) is not model.UserProfile:
            log = user_profile['food']['food_log'][date]
        else:
            log = user_profile.food.food_log[date]

        for _, food_log in log.items():
            calories_consumed += food_log['total_calories']
    except KeyError:
        calories_consumed = 0
    return calories_consumed


def prefilter_food_rec(user, menu, menu_mapping, remaining_calories):
    prefilter_food = []

    if not user.food.dietary:
        prefilter_food = [food_id for food_id in menu_mapping.values()]
        return prefilter_food

    lower_bound = 200 if remaining_calories > 400 else 0
    for food in menu:
        if remaining_calories >= float(food['Calories']) > lower_bound:
            for dietary in user.food.dietary:
                if dietary == 'pescetarian':
                    if food['Filters']['IsVegan'] or food['Filters']['ContainsFish']:
                        prefilter_food.append(menu_mapping[food['Food Name']])
                elif dietary in ['lactose_intolerant', 'peanut_allergy', 'sesame_allergy',
                                 'shellfish_allergy', 'soy_allergy', 'nut_allergy', 'wheat_allergy']:
                    if not food['Filters'][Dietary[dietary].value] or food['Filters'][Dietary[dietary].value] is None:
                        prefilter_food.append(menu_mapping[food['Food Name']])
                else:
                    if food['Filters'][Dietary[dietary].value] or food['Filters'][Dietary[dietary].value] is None:
                        prefilter_food.append(menu_mapping[food['Food Name']])
    return prefilter_food


def get_food_based_on_preferences(user, current_date, prefilter_food, menu_mapping, menu_feature):
    food_item_ratings = defaultdict(list)
    training_food_name = []
    training_food_label = []

    exclude_from_testing = set([food['food_name'] for i in range(3)
                                for _, food in
                                user.food.food_log
                               .get(datetime.fromisoformat(str(current_date - timedelta(days=i)))
                                    .strftime('%Y-%m-%d'), {}).items()])

    testing_menu_feature_index = prefilter_food.copy()
    for exclude_food in exclude_from_testing:
        if menu_mapping[exclude_food] in prefilter_food:
            testing_menu_feature_index.remove(menu_mapping[exclude_food])

    for date in user.food.food_log:
        for _, food_log in user.food.food_log[date].items():
            food_item_ratings[food_log['food_name']].append(food_log['rating'])

    for food, rating in food_item_ratings.items():
        training_food_name.append(food)
        rating_avg = round((sum(rating) / len(rating)), 2)
        if rating_avg >= 3.5:
            training_food_label.append(1)
        else:
            training_food_label.append(0)

    testing_menu_feature = [menu_feature[food_id] for food_id in testing_menu_feature_index]
    training_food = [menu_feature[menu_mapping[food]] for food in training_food_name]
    classifier = MLPClassifier(hidden_layer_sizes=(100,),
                               solver='sgd',
                               random_state=1881228559)
    classifier.fit(training_food, training_food_label)
    test_predictions = classifier.predict_proba(testing_menu_feature)
    return test_predictions, testing_menu_feature_index


def get_top_3_food_recommendations(food_label, food, mapping):
    top_recs = []
    for label, food_id in zip(food_label, food):
        top_recs.append((label[1], mapping[food_id]))
    return [item[1] for item in sorted(top_recs, key=lambda rank: rank[0], reverse=True)[:3]]


def get_food_recommendation(email, date, instance):
    _, user_profile = instance.get_user(email, 1)
    menu = instance.get_menu_data()
    menu_mapping_food_id, menu_mapping_id_food, menu_feature_names, menu_feature = instance.get_menu_feature()
    daily_target = int(get_daily_target(user_profile))
    consumed_today = get_calories_consumed_today(user_profile, date)
    remaining_calories = daily_target - consumed_today

    food_recommendations = []
    if len(user_profile.food.food_log) == 0:
        message = ("We're still trying to figure out what you like. Get started by logging some food you've eaten in "
                   "the past few days!")
        return {'calories': {
            'daily_target': daily_target,
            'consumed_today': consumed_today},
            'food_recommendations': food_recommendations,
            'message': message}

    if -150 <= remaining_calories <= 50:
        message = 'Congratulations! You have reached your daily calorie intake.'
    elif remaining_calories < -150:
        message = ('You have exceeded your daily calorie intake. If you\'re still hungry, look for a light calorie '
                   'snack!')
    else:
        prefilter_food = prefilter_food_rec(user_profile, menu, menu_mapping_food_id, remaining_calories)
        food_label, food = get_food_based_on_preferences(user_profile, date, prefilter_food,
                                                         menu_mapping_food_id, menu_feature)
        food_recommendations = get_top_3_food_recommendations(food_label, food, menu_mapping_id_food)
        if remaining_calories > 200:
            message = ("You still have a ways to go. Try some of our recommendations below! Remember to log what you "
                       "eat.")
        else:
            message = "You're almost there! Try some of our recommendations below! Remember to log what you eat."

    return {'calories': {
        'daily_target': daily_target,
        'consumed_today': consumed_today},
        'food_recommendations': food_recommendations,
        'message': message}
