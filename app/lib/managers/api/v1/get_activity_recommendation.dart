import "dart:convert";

import "package:activ8/managers/api/api_auth.dart";
import "package:activ8/managers/api/api_worker.dart";
import "package:activ8/managers/api/interfaces.dart";
import "package:geolocator/geolocator.dart";
import "package:http/http.dart" show Response;

String _endpoint = "/v1/getActivityRecommendation";

Future<V1GetActivityRecommendationResponse> v1getActivityRecommendation(
    V1GetActivityRecommendationBody body, Auth auth) async {
  final Response response = await ApiWorker.instance.get(_endpoint, body.toJson(), auth);

  final status = V1GetActivityRecommendationStatus.fromStatusCode(response.statusCode);

  final Map<String, dynamic> json = jsonDecode(response.body);
  return V1GetActivityRecommendationResponse(json, status: status);
}

class V1GetActivityRecommendationBody implements IBody {
  final Position? location;

  V1GetActivityRecommendationBody({this.location});

  Map<String, dynamic> toJson() {
    return {
      "location_lat": location?.latitude,
      "location_lon": location?.longitude,
    };
  }
}

class V1GetActivityRecommendationResponse implements IResponse {
  @override
  final V1GetActivityRecommendationStatus status;
  @override
  final String? errorMessage;

  late final int? caloriesBurned;
  late final int? stepTarget;
  late final int? stepProgress;
  late final String? message;

  V1GetActivityRecommendationResponse(Map<String, dynamic> json, {required this.status})
      : errorMessage = json["error_message"] {
    if (!status.isSuccessful) return;
    assert(errorMessage == null, "Error message provided on success");
    caloriesBurned = json["calories_burned"]?.toInt();
    stepTarget = json["steps"]["daily_target"]?.toInt();
    stepProgress = json["steps"]["progress_today"]?.toInt();
    message = json["message"].toString();
  }
}

enum V1GetActivityRecommendationStatus implements IStatus {
  success(statusCode: 200),
  incorrectCredentials(statusCode: 401),
  unknown,
  ;

  const V1GetActivityRecommendationStatus({this.statusCode});

  factory V1GetActivityRecommendationStatus.fromStatusCode(int statusCode) {
    for (V1GetActivityRecommendationStatus status in V1GetActivityRecommendationStatus.values) {
      if (status.statusCode == statusCode) {
        return status;
      }
    }
    return V1GetActivityRecommendationStatus.unknown;
  }

  @override
  bool get isSuccessful => this == V1GetActivityRecommendationStatus.success;

  final int? statusCode;
}
