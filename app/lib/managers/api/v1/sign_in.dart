import 'dart:convert';

import 'package:activ8/extensions/position.dart';
import 'package:activ8/managers/api/api_auth.dart';
import 'package:activ8/managers/api/api_worker.dart';
import 'package:activ8/types/user_preferences.dart';
import 'package:activ8/types/user_profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' show Response;

String _endpoint = "/v1/signIn";

Future<V1SignInResponse> v1signIn(V1SignInBody body, Auth auth) async {
  Response response = await ApiWorker.instance.post(_endpoint, body.toJson(), auth);
  V1SignInStatus status = V1SignInStatus.fromStatusCode(response.statusCode);

  return V1SignInResponse.fromJson(jsonDecode(response.body), status: status);
}

class V1SignInBody {
  final Position? location;

  V1SignInBody({this.location});

  Map<String, dynamic> toJson() {
    return {
      "location": location?.asLatLonList(),
    };
  }
}

class V1SignInResponse {
  final V1SignInStatus status;
  final String? errorMessage;

  late final UserProfile? userProfile;
  late final UserPreferences? userPreferences;

  V1SignInResponse({
    required this.status,
    this.errorMessage,
    required this.userProfile,
    required this.userPreferences,
  });

  V1SignInResponse.fromJson(Map<String, dynamic> json, {required this.status}) : errorMessage = json["error_message"] {
    if (status != V1SignInStatus.success) return;
    userProfile = UserProfile.fromJson(json["user_profile"]);
    userPreferences = UserPreferences.fromJson(json); // UserPreferences is not stored in its own field
  }
}

enum V1SignInStatus {
  success(statusCode: 200),
  incorrectCredentials(statusCode: 401),
  badRequest(statusCode: 400),
  unknown,
  ;

  const V1SignInStatus({this.statusCode});

  factory V1SignInStatus.fromStatusCode(int statusCode) {
    for (V1SignInStatus status in V1SignInStatus.values) {
      if (status.statusCode == statusCode) {
        return status;
      }
    }
    return V1SignInStatus.unknown;
  }

  final int? statusCode;
}
