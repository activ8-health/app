def get_daily_target(email, instance):
    pass


def get_food_recommendation(email, instance):

    daily_target = 0
    consumed_today = 0

    food_recommendations = []
    message = 'Hello, World!'

    return {'calories': {
        'daily_target': daily_target,
        'consumed_today': consumed_today},
        'food_recommendations': [],
        'message': message}
