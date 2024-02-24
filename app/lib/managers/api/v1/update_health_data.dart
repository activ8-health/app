import "package:activ8/extensions/position.dart";
import "package:activ8/managers/api/api_auth.dart";
import "package:activ8/managers/api/api_worker.dart";
import "package:activ8/types/health_data.dart";
import "package:activ8/utils/json.dart";
import "package:geolocator/geolocator.dart";
import "package:http/http.dart" show Response;

String _endpoint = "/v1/updateHealthData";

Future<V1UpdateHealthDataResponse> v1updateHealthData(V1UpdateHealthDataBody body, Auth auth) async {
  final Response response = await ApiWorker.instance.post(_endpoint, body.toJson(), auth);
  final V1UpdateHealthDataStatus status = V1UpdateHealthDataStatus.fromStatusCode(response.statusCode);

  return V1UpdateHealthDataResponse.fromJson(
    JsonUtils.tryDecode(response.body, {"error_message": "Something went wrong"}),
    status: status,
  );
}

class V1UpdateHealthDataBody {
  final Position? location;
  final HealthData healthData;

  V1UpdateHealthDataBody({this.location, required this.healthData});

  Map<String, dynamic> toJson() {
    return {
      "location": location?.asLatLonList(),
      "health_data": healthData.toJson(),
    };
  }
}

class V1UpdateHealthDataResponse {
  final V1UpdateHealthDataStatus status;
  final String? errorMessage;

  V1UpdateHealthDataResponse({
    required this.status,
    this.errorMessage,
  });

  V1UpdateHealthDataResponse.fromJson(Map<String, dynamic> json, {required this.status})
      : errorMessage = json["error_message"] {
    if (!status.isSuccessful) return;
    assert(errorMessage == null, "Error message provided on success");
  }
}

enum V1UpdateHealthDataStatus {
  success(statusCode: 200),
  incorrectCredentials(statusCode: 401),
  badRequest(statusCode: 400),
  unknown,
  ;

  const V1UpdateHealthDataStatus({this.statusCode});

  factory V1UpdateHealthDataStatus.fromStatusCode(int statusCode) {
    for (V1UpdateHealthDataStatus status in V1UpdateHealthDataStatus.values) {
      if (status.statusCode == statusCode) {
        return status;
      }
    }
    return V1UpdateHealthDataStatus.unknown;
  }

  bool get isSuccessful => this == V1UpdateHealthDataStatus.success;

  final int? statusCode;
}
