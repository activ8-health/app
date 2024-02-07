import 'package:activ8/types/food/dietary_restrictions.dart';
import 'package:activ8/types/food/weight_goal.dart';
import 'package:activ8/types/gender.dart';
import 'package:activ8/types/health_data.dart';
import 'package:activ8/types/sleep/core_hours.dart';
import 'package:activ8/types/user_preferences.dart';
import 'package:activ8/types/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// Blueprint for Profile objects and all information sent during registration
class SetupState {
  // UserProfile
  String? name;
  int? age;
  Sex? sex;
  double? height; // in cm
  double? weight; // in kg

  // HealthData
  HealthData? healthData;

  // UserPreferences

  // Sleep
  CoreHours coreHours = CoreHours(
    start: const TimeOfDay(hour: 9, minute: 0),
    end: const TimeOfDay(hour: 20, minute: 0),
  );

  // Exercise
  int stepGoal = 10000;
  TimeOfDay reminderTime = const TimeOfDay(hour: 19, minute: 0);

  // Food
  WeightGoal weightGoal = WeightGoal.maintain;
  Set<DietaryRestriction> dietaryRestrictions = {};

  // Location
  Position? location; // NOTE: this may remain null, even after going through the registration workflow

  // Utility & Data Extraction
  bool get isComplete =>
      name != null && age != null && sex != null && height != null && weight != null && healthData != null;

  UserProfile get userProfile => UserProfile(name: name!, age: age!, height: height!, weight: weight!, sex: sex!);

  UserPreferences get userPreferences => UserPreferences(
        // Sleep
        coreHours: coreHours,

        // Food
        dietaryRestrictions: dietaryRestrictions,
        weightGoal: weightGoal,

        // Exercise
        stepGoal: stepGoal,
        exerciseReminderTime: reminderTime,
      );
}
