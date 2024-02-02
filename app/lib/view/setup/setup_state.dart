import 'package:activ8/structures/health_data_points.dart';
import 'package:flutter/material.dart';

// Blueprint for Profile objects and all information sent during registration
class SetupState {
  String? name;
  int? age;
  double? height; // in cm
  double? weight; // in kg

  List<StepPoint>? steps;
  List<SleepPoint>? sleeps;

  TimeOfDay coreStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay coreEnd = const TimeOfDay(hour: 20, minute: 0);

  bool get isComplete =>
      name != null && age != null && height != null && weight != null && steps != null && sleeps != null;

  @override
  String toString() {
    return "SetupState(name: $name, age: $age, height: $height, weight: $weight, steps: $steps, sleeps: $sleeps, coreStart: $coreStart, coreEnd: $coreEnd, isComplete: $isComplete)";
  }
}
