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
}
