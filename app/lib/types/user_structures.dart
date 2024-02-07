import 'package:activ8/types/food/dietary_restrictions.dart';
import 'package:activ8/types/food/weight_goal.dart';
import 'package:activ8/types/gender.dart';
import 'package:activ8/types/sleep/core_hours.dart';
import 'package:flutter/material.dart';

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
}

class UserPreferences {
  // Sleep
  final CoreHours coreHours;

  // Dietary
  final WeightGoal weightGoal;
  final List<DietaryRestriction> dietaryRestrictions;

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
