import 'package:activ8/types/dietary_restrictions.dart';
import 'package:activ8/types/gender.dart';
import 'package:activ8/types/health_data_points.dart';
import 'package:activ8/types/weight_goal.dart';
import 'package:flutter/material.dart';

// Blueprint for Profile objects and all information sent during registration
class SetupState {
  // Profile
  String? name;
  int? age;
  Sex? sex;
  double? height; // in cm
  double? weight; // in kg

  // Health Data
  List<StepPoint>? stepPoints;
  List<SleepPoint>? sleepPoints;

  // Sleep
  TimeOfDay coreStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay coreEnd = const TimeOfDay(hour: 20, minute: 0);

  // Exercise
  int stepGoal = 10000;
  TimeOfDay reminderTime = const TimeOfDay(hour: 19, minute: 0);

  // Food
  WeightGoal? weightGoal;
  List<DietaryRestriction> dietaryRestrictions = [];

  bool get isComplete =>
      name != null &&
      age != null &&
      sex != null &&
      height != null &&
      weight != null &&
      stepPoints != null &&
      sleepPoints != null &&
      stepGoal != null &&
      reminderTime != null &&
      weightGoal != null;

  @override
  String toString() {
    return "SetupState("
        "name: $name, "
        "age: $age, "
        "sex: $sex, "
        "height: $height, "
        "weight: $weight, "
        "steps: $stepPoints, "
        "sleeps: $sleepPoints, "
        "coreStart: $coreStart, "
        "coreEnd: $coreEnd, "
        "stepGoal: $stepGoal, "
        "reminderTime: $reminderTime, "
        "weightGoal: $weightGoal, "
        "dietaryRestrictions: $dietaryRestrictions, "
        "isComplete: $isComplete)";
  }
}
