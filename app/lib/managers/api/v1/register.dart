import "package:activ8/extensions/position.dart";
import "package:activ8/managers/api/api_auth.dart";
import "package:activ8/managers/api/api_worker.dart";
import "package:activ8/managers/api/interfaces.dart";
import "package:activ8/types/health_data.dart";
import "package:activ8/types/user_preferences.dart";
import "package:activ8/types/user_profile.dart";
import "package:activ8/utils/json.dart";
import "package:geolocator/geolocator.dart";
import "package:http/http.dart" show Response;

String _endpoint = "/v1/register";

Future<V1RegisterResponse> v1register(V1RegisterBody body, Auth auth) async {
  final Response response = await ApiWorker.instance.post(_endpoint, body.toJson(), auth);

  final V1RegisterStatus status = V1RegisterStatus.fromStatusCode(response.statusCode);

  final Map<String, dynamic> json = JsonUtils.tryDecode(response.body, {"error_message": "Something went wrong"});
  return V1RegisterResponse(status: status, errorMessage: json["error_message"]);
}

class V1RegisterBody implements IBody {
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
      "location": location?.asLatLonList(),
      ...userPreferences.toJson(), // UserPreferences is not stored in its own field
    };
  }
}

class V1RegisterResponse implements IResponse {
  @override
  final V1RegisterStatus status;
  @override
  final String? errorMessage;

  V1RegisterResponse({required this.status, this.errorMessage});
}

enum V1RegisterStatus implements IStatus {
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

  @override
  bool get isSuccessful => this == V1RegisterStatus.success;

  final int? statusCode;
}
