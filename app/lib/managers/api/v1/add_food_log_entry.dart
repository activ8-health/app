import "package:activ8/extensions/position_serializer.dart";
import "package:activ8/managers/api/api_auth.dart";
import "package:activ8/managers/api/api_worker.dart";
import "package:activ8/managers/api/interfaces.dart";
import "package:activ8/types/food/menu.dart";
import "package:activ8/utils/json.dart";
import "package:geolocator/geolocator.dart";
import "package:http/http.dart" show Response;

String _endpoint = "/v1/addFoodLogEntry";

Future<V1AddFoodLogEntryResponse> v1addFoodLogEntry(V1AddFoodLogEntryBody body, Auth auth) async {
  final Response response = await ApiWorker.instance.post(_endpoint, body.toJson(), auth);
  final V1AddFoodLogEntryStatus status = V1AddFoodLogEntryStatus.fromStatusCode(response.statusCode);

  return V1AddFoodLogEntryResponse.fromJson(
    JsonUtils.tryDecode(response.body, {"error_message": "Something went wrong"}),
    status: status,
  );
}

class V1AddFoodLogEntryBody implements IBody {
  final Position? location;
  final FoodLogEntry entry;

  V1AddFoodLogEntryBody({this.location, required this.entry});

  Map<String, dynamic> toJson() {
    return {
      "entry_id": entry.id,
      "food_id": entry.item.name,
      "date": entry.date.toIso8601String(),
      "portion_eaten": entry.servings,
      "rating": entry.rating,
      "location": location?.asLatLonList(),
    };
  }
}

class V1AddFoodLogEntryResponse implements IResponse {
  @override
  final V1AddFoodLogEntryStatus status;
  @override
  final String? errorMessage;

  V1AddFoodLogEntryResponse({
    required this.status,
    this.errorMessage,
  });

  V1AddFoodLogEntryResponse.fromJson(Map<String, dynamic> json, {required this.status})
      : errorMessage = json["error_message"] {
    if (!status.isSuccessful) return;
    assert(errorMessage == null, "Error message provided on success");
  }
}

enum V1AddFoodLogEntryStatus implements IStatus {
  success(statusCode: 200),
  incorrectCredentials(statusCode: 401),
  badRequest(statusCode: 400),
  entryAlreadyExists(statusCode: 409),
  unknown,
  ;

  const V1AddFoodLogEntryStatus({this.statusCode});

  factory V1AddFoodLogEntryStatus.fromStatusCode(int statusCode) {
    for (V1AddFoodLogEntryStatus status in V1AddFoodLogEntryStatus.values) {
      if (status.statusCode == statusCode) {
        return status;
      }
    }
    return V1AddFoodLogEntryStatus.unknown;
  }

  @override
  bool get isSuccessful => this == V1AddFoodLogEntryStatus.success;

  final int? statusCode;
}
