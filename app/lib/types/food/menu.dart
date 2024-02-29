import "package:uuid/uuid.dart";

class FoodMenuItem {
  final String name;
  final String description;
  final int calories;
  final Map<String, String> nutritionFacts; // TODO do we need this?

  FoodMenuItem({
    required this.name,
    required this.description,
    required this.calories,
    required this.nutritionFacts,
  });

  @override
  bool operator ==(Object other) {
    if (other is! FoodMenuItem) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return "FoodMenuItem(name: $name, calories: $calories, nutritionFacts: $nutritionFacts)";
  }
}

class FoodLogEntry {
  static const _uuid = Uuid();

  final String id;
  final FoodMenuItem item;
  final DateTime date;
  final double servings;
  final int rating;

  FoodLogEntry({
    required this.item,
    required this.date,
    required this.servings,
    required this.rating,
    String? id,
  }) : id = id ?? _uuid.v4();

  @override
  bool operator ==(Object other) {
    if (other is! FoodLogEntry) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return "FoodLogEntry(id: $id, item: $item, date: $date, servings: $servings, rating: $rating)";
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "item": item.name,
      "date": date.toIso8601String(),
      "servings": servings,
      "rating": rating,
    };
  }

  static FoodLogEntry fromJson(Map<String, dynamic> json, List<FoodMenuItem> items) {
    final String id = json["id"];
    final FoodMenuItem item = items.firstWhere((FoodMenuItem item) => item.name == json["item"]);
    final DateTime date = DateTime.parse(json["date"]);
    final double servings = json["servings"];
    final int rating = json["rating"];
    return FoodLogEntry(item: item, date: date, servings: servings, rating: rating, id: id);
  }

  bool isIdentical(FoodLogEntry other) {
    return item == other.item && date == other.date && servings == other.servings && rating == other.rating;
  }
}
