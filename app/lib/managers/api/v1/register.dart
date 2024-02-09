import 'dart:convert';

import 'package:activ8/extensions/position.dart';
import 'package:activ8/managers/api/api_auth.dart';
import 'package:activ8/managers/api/api_worker.dart';
import 'package:activ8/types/health_data.dart';
import 'package:activ8/types/user_preferences.dart';
import 'package:activ8/types/user_profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' show Response;

String _endpoint = "/v1/register";

Future<V1RegisterResponse> v1register(V1RegisterBody body, Auth auth) async {
  Response response = await ApiWorker.instance.post(_endpoint, body.toJson(), auth);

  V1RegisterStatus status = V1RegisterStatus.fromStatusCode(response.statusCode);

  Map<String, dynamic> json = jsonDecode(response.body);
  return V1RegisterResponse(status: status, errorMessage: json["error_message"]);
}

class V1RegisterBody {
  final UserProfile userProfile;
  final HealthData healthData;
  final UserPreferences userPreferences;
  final Position? location;

  V1RegisterBody({
    required this.userProfile,
    required this.healthData,
    required this.userPreferences,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_profile": userProfile.toJson(),
      "health_data": healthData.toJson(),
      ...userPreferences.toJson(), // UserPreferences is not stored in its own field
      "location": location?.asLatLonList(),
    };
  }
}

class V1RegisterResponse {
  final V1RegisterStatus status;
  final String? errorMessage;

  V1RegisterResponse({required this.status, this.errorMessage});
}

enum V1RegisterStatus {
  success(statusCode: 200),
  emailInUse(statusCode: 409),
  badRequest(statusCode: 400),
  unknown,
  ;

  const V1RegisterStatus({this.statusCode});

  factory V1RegisterStatus.fromStatusCode(int statusCode) {
    for (V1RegisterStatus status in V1RegisterStatus.values) {
      if (status.statusCode == statusCode) {
        return status;
      }
    }
    return V1RegisterStatus.unknown;
  }

  final int? statusCode;
}
