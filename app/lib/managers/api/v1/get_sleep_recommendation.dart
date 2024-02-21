import 'dart:convert';

import 'package:activ8/extensions/time_of_day_serializer.dart';
import 'package:activ8/managers/api/api_auth.dart';
import 'package:activ8/managers/api/api_worker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' show Response;

String _endpoint = "/v1/getSleepRecommendation";

Future<V1GetSleepRecommendationResponse> v1getSleepRecommendation(V1GetSleepRecommendationBody body, Auth auth) async {
  Response response = await ApiWorker.instance.get(_endpoint, body.toJson(), auth);

  V1GetSleepRecommendationStatus status = V1GetSleepRecommendationStatus.fromStatusCode(response.statusCode);

  Map<String, dynamic> json = jsonDecode(response.body);
  return V1GetSleepRecommendationResponse(json, status: status);
}

class V1GetSleepRecommendationBody {
  final Position? location;
  final DateTime? date;

  V1GetSleepRecommendationBody({this.location, this.date});

  Map<String, dynamic> toJson() {
    return {
      "location_lat": location?.latitude,
      "location_lon": location?.longitude,
      "date": date?.toIso8601String(),
    };
  }
}

class V1GetSleepRecommendationResponse {
  final V1GetSleepRecommendationStatus status;
  final String? errorMessage;

  late final TimeOfDay? sleepRangeStart;
  late final TimeOfDay? sleepRangeEnd;

  V1GetSleepRecommendationResponse(Map<String, dynamic> json, {required this.status})
      : errorMessage = json["error_message"] {
    if (!status.isSuccessful) return;
    assert(errorMessage == null, "Error message provided on success");
    sleepRangeStart = TimeOfDaySerializer.fromMinutesSinceMidnight(json["ideal_sleep_range"]["start"].toInt());
    sleepRangeEnd = TimeOfDaySerializer.fromMinutesSinceMidnight(json["ideal_sleep_range"]["end"].toInt());
  }
}

enum V1GetSleepRecommendationStatus {
  success(statusCode: 200),
  incorrectCredentials(statusCode: 401),
  unknown,
  ;

  const V1GetSleepRecommendationStatus({this.statusCode});

  factory V1GetSleepRecommendationStatus.fromStatusCode(int statusCode) {
    for (V1GetSleepRecommendationStatus status in V1GetSleepRecommendationStatus.values) {
      if (status.statusCode == statusCode) {
        return status;
      }
    }
    return V1GetSleepRecommendationStatus.unknown;
  }

  bool get isSuccessful => this == V1GetSleepRecommendationStatus.success;

  final int? statusCode;
}
