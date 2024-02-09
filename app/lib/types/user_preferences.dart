import 'package:activ8/extensions/dietary_restriction_set_serializer.dart';
import 'package:activ8/extensions/time_of_day_serializer.dart';
import 'package:activ8/types/food/dietary_restrictions.dart';
import 'package:activ8/types/food/weight_goal.dart';
import 'package:activ8/types/sleep/core_hours.dart';
import 'package:flutter/material.dart';

class UserPreferences {
  // Sleep
  final CoreHours coreHours;

  // Dietary
  final WeightGoal weightGoal;
  final Set<DietaryRestriction> dietaryRestrictions;

  // Exercise Preferences
  final TimeOfDay exerciseReminderTime;
  final int stepGoal;

  UserPreferences({
    required this.coreHours,
    required this.weightGoal,
    required this.dietaryRestrictions,
    required this.exerciseReminderTime,
    required this.stepGoal,
  });

  Map<String, dynamic> toJson() {
    return {
      "sleep_preferences": {
        "core_hours": coreHours.toJson(),
      },
      "food_preferences": {
        "weight_goal": weightGoal.index,
        "dietary": dietaryRestrictions.toJson(),
      },
      "exercise_preferences": {
        "reminder_time": exerciseReminderTime.minutesSinceMidnight,
        "step_goal": stepGoal,
      },
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      coreHours: CoreHours.fromJson(json["sleep_preferences"]["core_hours"]),
      dietaryRestrictions: DietaryRestrictionSerializer.fromJson(json["food_preferences"]["dietary"]),
      weightGoal: WeightGoal.fromIndex(json["food_preferences"]["weight_goal"]),
      stepGoal: json["exercise_preferences"]["step_goal"].toInt(),
      exerciseReminderTime: TimeOfDaySerializer.fromMinutesSinceMidnight(json["exercise_preferences"]["reminder_time"]),
    );
  }
}
