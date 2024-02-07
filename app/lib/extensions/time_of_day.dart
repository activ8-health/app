import 'package:flutter/material.dart';

extension MinutesSinceMidnight on TimeOfDay {
  int get minutesSinceMidnight => hour * 60 + minute;
}
