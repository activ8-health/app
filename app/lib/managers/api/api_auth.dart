import 'dart:convert';

class Auth {
  String email;
  String password;

  Auth({required this.email, required this.password});

  String toHeader() {
    return "Basic ${base64Encode(utf8.encode("$email:$password"))}";
  }
}
