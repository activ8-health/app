import 'dart:convert';
import 'dart:io';

import 'package:activ8/managers/api/api_auth.dart';
import 'package:activ8/types/user_preferences.dart';
import 'package:activ8/types/user_profile.dart';
import 'package:activ8/utils/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  AppState._();

  static final AppState instance = AppState._();

  static const _userProfileFile = "user_profile.json";
  static const _userPreferencesFile = "user_preferences.json";

  late SharedPreferences _sharedPreferences;
  String? email;
  String? password;

  String? host;
  int? port;
  UserProfile? userProfile;
  UserPreferences? userPreferences;

  Auth get auth => Auth(email: email!, password: password!);

  set serverAddress(String address) {
    List<String> splitAuthority = address.split(":");
    host = splitAuthority.first;
    port = (splitAuthority.length > 1) ? int.tryParse(splitAuthority[1]) : null;
    logger.i('Split "$address" into host="$host" and port="$port"');

    logger.i("Storing server address in SharedPreferences");
    _sharedPreferences.setString("host", host!);
    _sharedPreferences.setString("port", port.toString());
  }

  /// Returns whether a user was found
  Future<bool> initialize() async {
    logger.i("Retrieving email and password from SharedPreferences");
    _sharedPreferences = await SharedPreferences.getInstance();
    email = _sharedPreferences.getString("email");
    password = _sharedPreferences.getString("password");

    host = _sharedPreferences.getString("host");
    port = int.tryParse(_sharedPreferences.getString("port") ?? "");

    if (email == null) {
      logger.i("No email found in SharedPreferences, going to setup page");
      return false;
    }

    Directory documents = await getApplicationDocumentsDirectory();

    logger.i("Retrieving user profile from disk");
    File userProfileFile = File("${documents.path}/$_userProfileFile");
    logger.i("User profile file exists: ${userProfileFile.existsSync()}");
    String userProfileJson = await userProfileFile.readAsString();
    userProfile = UserProfile.fromJson(jsonDecode(userProfileJson));

    logger.i("Retrieving user preferences from disk");
    File userPreferencesFile = File("${documents.path}/$_userPreferencesFile");
    logger.i("User preferences file exists: ${userPreferencesFile.existsSync()}");
    String userPreferencesJson = await userPreferencesFile.readAsString();
    userPreferences = UserPreferences.fromJson(jsonDecode(userPreferencesJson));

    logger.i("User loaded");

    return true;
  }

  /// Creates the local user profile, not to be confused with server-side profile creation
  Future<void> registerUser({
    required String email,
    required String password,
    required UserProfile userProfile,
    required UserPreferences userPreferences,
  }) async {
    logger.i("Storing email and password in SharedPreferences");
    await _sharedPreferences.setString("email", email);
    await _sharedPreferences.setString("password", password);
    this.email = email;
    this.password = password;

    Directory documents = await getApplicationDocumentsDirectory();

    logger.i("Storing user profile on disk");
    File userProfileFile = File("${documents.path}/$_userProfileFile");
    await userProfileFile.writeAsString(jsonEncode(userProfile.toJson()));
    this.userProfile = userProfile;

    logger.i("Storing user preferences on disk");
    File userPreferencesFile = File("${documents.path}/$_userPreferencesFile");
    await userPreferencesFile.writeAsString(jsonEncode(userPreferences.toJson()));
    this.userPreferences = userPreferences;

    logger.i("User created");
  }

  Future<void> signOut() async {
    logger.i("Clearing email and password from SharedPreferences");
    await _sharedPreferences.remove("email");
    await _sharedPreferences.remove("password");
    email = null;
    password = null;

    Directory documents = await getApplicationDocumentsDirectory();

    logger.i("Deleting user profile from disk");
    File userProfileFile = File("${documents.path}/$_userProfileFile");
    await userProfileFile.delete();
    userProfile = null;

    logger.i("Deleting user preferences from disk");
    File userPreferencesFile = File("${documents.path}/$_userPreferencesFile");
    await userPreferencesFile.delete();
    userPreferences = null;

    logger.i("User signed out");
  }
}
