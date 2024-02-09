import "dart:convert";
import "dart:io";

import "package:activ8/managers/api/api_auth.dart";
import "package:activ8/utils/logger.dart";
import "package:http/http.dart" as http;

class ApiWorker {
  static final ApiWorker instance = ApiWorker._();

  ApiWorker._();

  late String host; // Should be assigned in the Register/Log In step
  late int? port;

  // Sets the address in the form of "<host>:<port>" or "<host>"
  set address(String address) {
    List<String> splitAuthority = address.split(":");
    host = splitAuthority.first;
    port = (splitAuthority.length > 1) ? int.tryParse(splitAuthority[1]) : null;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body, Auth auth) async {
    http.Response response = await http.post(
      _getUri(endpoint),
      body: jsonEncode(body),
      headers: {HttpHeaders.authorizationHeader: auth.toHeader()},
    ).catchError((error) {
      logger.e("Error calling function: $error");
      return http.Response('{"error_message": "Cannot connect to the server."}', 600);
    });
    return response;
  }

  Future<http.Response> get(String endpoint, Map<String, dynamic> parameters, Auth auth) async {
    http.Response response = await http.get(
      _getUri(endpoint).replace(queryParameters: parameters),
      headers: {HttpHeaders.authorizationHeader: auth.toHeader()},
    ).catchError((error) {
      logger.e("Error calling function: $error");
      return http.Response('{"error_message": "Cannot connect to the server."}', 600);
    });
    return response;
  }

  Uri _getUri(String endpoint) {
    return Uri(scheme: "http", host: host, port: port, path: endpoint);
  }
}
