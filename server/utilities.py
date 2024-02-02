import base64


def create_user_password(authorization):
    decoded = base64.b64decode(authorization[6:])
    user_pass = decoded.split(b':', 1)
    user = user_pass[0]
    password = user_pass[1]
    return user, password
