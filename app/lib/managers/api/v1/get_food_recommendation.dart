import "dart:convert";

import "package:activ8/managers/api/api_auth.dart";
import "package:activ8/managers/api/api_worker.dart";
import "package:activ8/managers/api/interfaces.dart";
import "package:activ8/managers/food_manager.dart";
import "package:activ8/types/food/menu.dart";
import "package:geolocator/geolocator.dart";
import "package:http/http.dart" show Response;

String _endpoint = "/v1/getFoodRecommendation";

Future<V1GetFoodRecommendationResponse> v1getFoodRecommendation(V1GetFoodRecommendationBody body, Auth auth) async {
  final Response response = await ApiWorker.instance.get(_endpoint, body.toJson(), auth);

  final status = V1GetFoodRecommendationStatus.fromStatusCode(response.statusCode);

  final Map<String, dynamic> json = jsonDecode(response.body);
  return V1GetFoodRecommendationResponse(json, status: status);
}

class V1GetFoodRecommendationBody implements IBody {
  final Position? location;

  V1GetFoodRecommendationBody({this.location});

  Map<String, dynamic> toJson() {
    return {
      "location_lat": location?.latitude,
      "location_lon": location?.longitude,
    };
  }
}

class V1GetFoodRecommendationResponse implements IResponse {
  @override
  final V1GetFoodRecommendationStatus status;
  @override
  final String? errorMessage;

  late final int? caloriesConsumed;
  late final int? caloriesGoal;
  late final List<FoodMenuItem> recommendations;
  late final String? message;

  V1GetFoodRecommendationResponse(Map<String, dynamic> json, {required this.status})
      : errorMessage = json["error_message"] {
    if (!status.isSuccessful) return;
    assert(errorMessage == null, "Error message provided on success");
    caloriesConsumed = json["calories"]["consumed_today"]?.toInt();
    caloriesGoal = json["calories"]["daily_target"]?.toInt();
    recommendations = json["food_recommendations"]?.map<FoodMenuItem>((dynamic name) {
      return FoodManager.instance.items.firstWhere((item) => item.name == name);
    }).toList();
    message = json["message"].toString();
  }
}

enum V1GetFoodRecommendationStatus implements IStatus {
  success(statusCode: 200),
  incorrectCredentials(statusCode: 401),
  unknown,
  ;

  const V1GetFoodRecommendationStatus({this.statusCode});

  factory V1GetFoodRecommendationStatus.fromStatusCode(int statusCode) {
    for (V1GetFoodRecommendationStatus status in V1GetFoodRecommendationStatus.values) {
      if (status.statusCode == statusCode) {
        return status;
      }
    }
    return V1GetFoodRecommendationStatus.unknown;
  }

  @override
  bool get isSuccessful => this == V1GetFoodRecommendationStatus.success;

  final int? statusCode;
}
