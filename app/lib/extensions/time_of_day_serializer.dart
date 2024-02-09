import 'package:flutter/material.dart';

extension TimeOfDaySerializer on TimeOfDay {
  int get minutesSinceMidnight => hour * 60 + minute;

  static TimeOfDay fromMinutesSinceMidnight(int minutesSinceMidnight) {
    return TimeOfDay(
      hour: minutesSinceMidnight ~/ 60,
      minute: minutesSinceMidnight % 60,
    );
  }
}
