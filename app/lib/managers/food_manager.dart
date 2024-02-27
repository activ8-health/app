import "package:activ8/types/food/menu.dart";

class FoodManager {
  static FoodManager instance = FoodManager._();

  FoodManager._();

  List<FoodMenuItem> items = [];
  List<FoodLogEntry> log = [];

  Future<void> initialize() async {
    // TODO load items and log from disk
    items = [
      FoodMenuItem(name: "Pizza", calories: 650, nutritionFacts: {}),
      FoodMenuItem(name: "Brocolini", calories: 650, nutritionFacts: {}),
      FoodMenuItem(name: "Chicken Tortellini with Bacon Alfredo Sauce", calories: 30000, nutritionFacts: {}),
    ];

    log = [
      FoodLogEntry(item: items[0], date: DateTime.now().subtract(const Duration(days: 2)), servingSize: 1.5, rating: 5),
      FoodLogEntry(item: items[1], date: DateTime.now().subtract(const Duration(days: 1)), servingSize: 0.7, rating: 3),
      FoodLogEntry(item: items[2], date: DateTime.now().subtract(const Duration(days: 1)), servingSize: 0.7, rating: 3),
      FoodLogEntry(item: items[2], date: DateTime.now(), servingSize: 0.7, rating: 3),
    ];
  }
}
