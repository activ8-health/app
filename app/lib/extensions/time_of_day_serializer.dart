import 'package:flutter/material.dart';

extension TimeOfDaySerializer on TimeOfDay {
  int get minutesSinceMidnight => hour * 60 + minute;

  double get hourDouble => hour + minute / 60;

  static TimeOfDay fromMinutesSinceMidnight(int minutesSinceMidnight) {
    return TimeOfDay(
      hour: minutesSinceMidnight ~/ 60,
      minute: minutesSinceMidnight % 60,
    );
  }
}
