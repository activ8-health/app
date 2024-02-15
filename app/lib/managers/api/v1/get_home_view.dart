import 'dart:convert';

import 'package:activ8/managers/api/api_auth.dart';
import 'package:activ8/managers/api/api_worker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' show Response;

String _endpoint = "/v1/getHomeView";

Future<V1GetHomeViewResponse> v1getHomeView(V1GetHomeViewBody body, Auth auth) async {
  Response response = await ApiWorker.instance.get(_endpoint, body.toJson(), auth);

  V1GetHomeViewStatus status = V1GetHomeViewStatus.fromStatusCode(response.statusCode);

  Map<String, dynamic> json = jsonDecode(response.body);
  return V1GetHomeViewResponse(json, status: status);
}

class V1GetHomeViewBody {
  final Position? location;

  V1GetHomeViewBody({
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      "location_lat": location?.latitude,
      "location_lon": location?.longitude,
    };
  }
}

class V1GetHomeViewResponse {
  final V1GetHomeViewStatus status;
  final String? errorMessage;

  late final int? fitnessScore;
  late final String? message;

  V1GetHomeViewResponse(Map<String, dynamic> json, {required this.status}) : errorMessage = json["error_message"] {
    if (!status.isSuccessful) return;
    assert(errorMessage == null, "Error message provided on success");
    fitnessScore = json["fitness_score"].toInt();
    message = json["message"].toString();
  }
}

enum V1GetHomeViewStatus {
  success(statusCode: 200),
  incorrectCredentials(statusCode: 401),
  unknown,
  ;

  const V1GetHomeViewStatus({this.statusCode});

  factory V1GetHomeViewStatus.fromStatusCode(int statusCode) {
    for (V1GetHomeViewStatus status in V1GetHomeViewStatus.values) {
      if (status.statusCode == statusCode) {
        return status;
      }
    }
    return V1GetHomeViewStatus.unknown;
  }

  bool get isSuccessful => this == V1GetHomeViewStatus.success;

  final int? statusCode;
}
