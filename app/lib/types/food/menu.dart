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
}

class FoodLogEntry {
  static const _uuid = Uuid();

  final String id;
  final FoodMenuItem item;
  final DateTime date;
  final double servingSize;
  final int rating;

  FoodLogEntry({
    required this.item,
    required this.date,
    required this.servingSize,
    required this.rating,
    String? id,
  }) : id = id ?? _uuid.v4();
}
