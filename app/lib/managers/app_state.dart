import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  AppState._();

  static final AppState instance = AppState._();

  late SharedPreferences _sharedPreferences;
  String? email;
  String? password;

  Future<void> initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    email = _sharedPreferences.getString("email");
    password = _sharedPreferences.getString("password");
    // TODO: Probably shouldn't store passwords in plaintext
  }
}
