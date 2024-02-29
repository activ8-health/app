import "dart:async";
import "dart:convert";

import "package:activ8/managers/api/v1/add_food_log_entry.dart";
import "package:activ8/managers/api/v1/remove_food_log_entry.dart";
import "package:activ8/managers/app_state.dart";
import "package:activ8/managers/location_manager.dart";
import "package:activ8/types/food/menu.dart";
import "package:activ8/utils/logger.dart";
import "package:flutter/services.dart" show rootBundle;
import "package:fuzzywuzzy/fuzzywuzzy.dart";
import "package:fuzzywuzzy/model/extracted_result.dart";
import "package:fuzzywuzzy/ratios/partial_ratio.dart";
import "package:geolocator/geolocator.dart";
import "package:shared_preferences/shared_preferences.dart";

class FoodManager {
  static FoodManager instance = FoodManager._();

  FoodManager._();

  List<FoodMenuItem> items = [];
  List<FoodLogEntry> log = [];

  late SharedPreferences _sharedPreferences;

  Future<void> initialize() async {
    logger.i("Loading food items from disk");
    items = [];
    final String menuDataContent = await rootBundle.loadString("assets/menu_data.json");
    final Map<String, dynamic> menuData = jsonDecode(menuDataContent);

    for (Map<String, dynamic> food in menuData["food"]!) {
      items.add(FoodMenuItem(
        name: food["Food Name"].toString(),
        calories: int.parse(food["Calories"]),
        nutritionFacts: {},
      ));
    }
    logger.i("Loaded ${items.length} food items from disk");

    // Load log from disk
    logger.i("Loading food log from disk");
    log = [];
    _sharedPreferences = await SharedPreferences.getInstance();
    final String? data = _sharedPreferences.getString("food_log");
    if (data != null) {
      final List<dynamic> logData = jsonDecode(data);
      log = logData.map((dynamic entry) => FoodLogEntry.fromJson(entry, items)).toList();
    }
    logger.i("Loaded ${log.length} food log entries from disk");

    items.sort((a, b) => a.name.compareTo(b.name));
    log.sort((a, b) => b.date.compareTo(a.date));
  }

  /// Search with partial fuzzy matching
  Iterable<FoodMenuItem> searchFoodItems(String query) {
    // Empty query, give top few results
    if (query.isEmpty) return items;

    // Fuzzy match results
    final List<ExtractedResult<FoodMenuItem>> results = extractAllSorted<FoodMenuItem>(
      query: query,
      choices: FoodManager.instance.items,
      cutoff: 70,
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

    unawaited(_saveFoodLogToDisk());
    unawaited(_sendAddFoodLogEntryRequest(entry));
  }

  /// Removes a new food item [entry] from [log] and saves to disk
  void removeFoodLogEntry(FoodLogEntry entry) {
    logger.i("Removing food log entry: $entry");
    log.remove(entry);

    unawaited(_saveFoodLogToDisk());
    unawaited(_sendRemoveFoodLogEntryRequest(entry));
  }

  /// Send the add request to the server using the addFoodLogEntry API
  Future<void> _sendAddFoodLogEntryRequest(FoodLogEntry entry) async {
    final Position location = await LocationManager.instance.getLocation();
    final V1AddFoodLogEntryBody body = V1AddFoodLogEntryBody(entry: entry, location: location);
    await v1addFoodLogEntry(body, AppState.instance.auth);
  }

  /// Send the remove request to the server using the removeFoodLogEntry API
  Future<void> _sendRemoveFoodLogEntryRequest(FoodLogEntry entry) async {
    final Position location = await LocationManager.instance.getLocation();
    final V1RemoveFoodLogEntryBody body = V1RemoveFoodLogEntryBody(entry: entry, location: location);
    await v1removeFoodLogEntry(body, AppState.instance.auth);
  }

  Future<void> _saveFoodLogToDisk() async {
    final String data = jsonEncode(log.map((FoodLogEntry entry) => entry.toJson()).toList());
    await _sharedPreferences.setString("food_log", data);
  }
}
