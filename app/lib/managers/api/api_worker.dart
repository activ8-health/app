import "dart:convert";
import "dart:io";

import "package:activ8/managers/api/api_auth.dart";
import "package:activ8/managers/app_state.dart";
import "package:activ8/utils/logger.dart";
import "package:http/http.dart" as http;

class ApiWorker {
  static final ApiWorker instance = ApiWorker._();

  ApiWorker._();

  Future<http.Response> post(String endpoint, Map<String, dynamic> body, Auth auth) async {
    final Uri uri = _getUri(endpoint);
    logger.i("Making POST request to $uri");
    final http.Response response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {HttpHeaders.authorizationHeader: auth.toHeader()},
    ).catchError((error) {
      logger.e("Error calling function: $error");
      return http.Response('{"error_message": "Cannot connect to the server."}', 600);
    });
    return response;
  }

  Future<http.Response> get(String endpoint, Map<String, dynamic> parameters, Auth auth) async {
    final Map<String, String> stringParameters = parameters.map((key, value) => MapEntry(key, value.toString()));
    final Uri uri = _getUri(endpoint).replace(queryParameters: stringParameters);
    logger.i("Making GET request to $uri");
    final response = await http.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: auth.toHeader()},
    ).catchError((error) {
      logger.e("Error calling function: $error");
      return http.Response('{"error_message": "Cannot connect to the server."}', 600);
    });
    return response;
  }

  Uri _getUri(String endpoint) {
    return Uri(scheme: "http", host: AppState.instance.host, port: AppState.instance.port, path: endpoint);
  }
}
