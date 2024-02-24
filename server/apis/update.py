from apis.signin import signin_user


# noinspection DuplicatedCode
def update_health_data(authentication, new_data, instance):
    _, status = signin_user(authentication, new_data, instance)
    return {}, status
