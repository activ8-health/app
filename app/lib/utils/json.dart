import 'dart:convert';

class JsonUtils {
  JsonUtils._();

  static dynamic tryDecode(String source, [dynamic alternative]) {
    try {
      return jsonDecode(source);
    } catch (e) {
      return alternative;
    }
  }
}
