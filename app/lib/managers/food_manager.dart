import "package:activ8/types/food/menu.dart";
import "package:activ8/utils/logger.dart";
import "package:fuzzywuzzy/fuzzywuzzy.dart";
import "package:fuzzywuzzy/model/extracted_result.dart";
import "package:fuzzywuzzy/ratios/partial_ratio.dart";

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
      FoodLogEntry(item: items[0], date: DateTime.now().subtract(const Duration(days: 2)), servings: 1.5, rating: 5),
      FoodLogEntry(item: items[1], date: DateTime.now().subtract(const Duration(days: 1)), servings: 0.7, rating: 3),
      FoodLogEntry(item: items[2], date: DateTime.now().subtract(const Duration(days: 1)), servings: 0.7, rating: 3),
      FoodLogEntry(item: items[2], date: DateTime.now(), servings: 0.7, rating: 3),
    ];

    items.sort((a, b) => a.name.compareTo(b.name));
    log.sort((a, b) => b.date.compareTo(a.date));
  }

  /// Search with partial fuzzy matching
  Iterable<FoodMenuItem> searchFoodItems(String query) {
    // Fuzzy match results
    final List<ExtractedResult<FoodMenuItem>> results = extractTop<FoodMenuItem>(
      query: query,
      choices: FoodManager.instance.items,
      limit: 4,
      cutoff: 60,
      ratio: PartialRatio(),
      getter: (FoodMenuItem item) => item.name,
    );

    // Return results
    return results.map((ExtractedResult<FoodMenuItem> result) => result.choice);
  }

  /// Add a new food item [entry] to [log] and saves to disk
  void addFoodLogEntry(FoodLogEntry entry) {
    logger.i("Adding food log entry: $entry");
    log.add(entry);
    log.sort((a, b) => b.date.compareTo(a.date));
    // TODO save to disk
  }

  /// Removes a new food item [entry] from [log] and saves to disk
  void removeFoodLogEntry(FoodLogEntry entry) {
    logger.i("Removing food log entry: $entry");
    log.remove(entry);
    // TODO save to disk
  }
}
