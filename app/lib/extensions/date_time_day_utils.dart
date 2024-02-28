import "package:flutter/material.dart";

extension DateTimeDayUtils on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Only return the date (year, month, and day)
  DateTime extractDate() {
    return DateTime(year, month, day);
  }

  /// Only return the time (hour and minute)
  TimeOfDay extractTime() {
    return TimeOfDay(hour: hour, minute: minute);
  }
}
