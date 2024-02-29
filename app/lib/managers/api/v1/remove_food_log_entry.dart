import "package:activ8/extensions/position_serializer.dart";
import "package:activ8/managers/api/api_auth.dart";
import "package:activ8/managers/api/api_worker.dart";
import "package:activ8/managers/api/interfaces.dart";
import "package:activ8/types/food/menu.dart";
import "package:activ8/utils/json.dart";
import "package:geolocator/geolocator.dart";
import "package:http/http.dart" show Response;

String _endpoint = "/v1/removeFoodLogEntry";

Future<V1RemoveFoodLogEntryResponse> v1removeFoodLogEntry(V1RemoveFoodLogEntryBody body, Auth auth) async {
  final Response response = await ApiWorker.instance.post(_endpoint, body.toJson(), auth);
  final V1RemoveFoodLogEntryStatus status = V1RemoveFoodLogEntryStatus.fromStatusCode(response.statusCode);

  return V1RemoveFoodLogEntryResponse.fromJson(
    JsonUtils.tryDecode(response.body, {"error_message": "Something went wrong"}),
    status: status,
  );
}

class V1RemoveFoodLogEntryBody implements IBody {
  final Position? location;
  final FoodLogEntry entry;

  V1RemoveFoodLogEntryBody({this.location, required this.entry});

  Map<String, dynamic> toJson() {
    return {
      "entry_id": entry.id,
      "location": location?.asLatLonList(),
    };
  }
}

class V1RemoveFoodLogEntryResponse implements IResponse {
  @override
  final V1RemoveFoodLogEntryStatus status;
  @override
  final String? errorMessage;

  V1RemoveFoodLogEntryResponse({
    required this.status,
    this.errorMessage,
  });

  V1RemoveFoodLogEntryResponse.fromJson(Map<String, dynamic> json, {required this.status})
      : errorMessage = json["error_message"] {
    if (!status.isSuccessful) return;
    assert(errorMessage == null, "Error message provided on success");
  }
}

enum V1RemoveFoodLogEntryStatus implements IStatus {
  success(statusCode: 200),
  incorrectCredentials(statusCode: 401),
  badRequest(statusCode: 400),
  entryDoesNotExists(statusCode: 404),
  unknown,
  ;

  const V1RemoveFoodLogEntryStatus({this.statusCode});

  factory V1RemoveFoodLogEntryStatus.fromStatusCode(int statusCode) {
    for (V1RemoveFoodLogEntryStatus status in V1RemoveFoodLogEntryStatus.values) {
      if (status.statusCode == statusCode) {
        return status;
      }
    }
    return V1RemoveFoodLogEntryStatus.unknown;
  }

  @override
  bool get isSuccessful => this == V1RemoveFoodLogEntryStatus.success;

  final int? statusCode;
}
