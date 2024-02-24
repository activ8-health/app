import "package:activ8/types/gender.dart";

class UserProfile {
  final String name;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final Sex sex;

  UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.sex,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "age": age,
      "height": height,
      "weight": weight,
      "sex": sex.index,
    };
  }

  UserProfile.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        age = json["age"],
        height = json["height"].toDouble(),
        weight = json["weight"].toDouble(),
        sex = Sex.fromIndex(json["sex"]);
}
