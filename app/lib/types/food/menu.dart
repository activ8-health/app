import "package:uuid/uuid.dart";

class FoodMenuItem {
  final String name;
  final int calories;
  final Map<String, String> nutritionFacts; // TODO do we need this?

  FoodMenuItem({
    required this.name,
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
}
