import 'package:activ8/extensions/time_of_day.dart';
import 'package:flutter/material.dart';

class CoreHours {
  TimeOfDay start;
  TimeOfDay end;

  CoreHours({required this.start, required this.end});

  Map<String, dynamic> toJson() {
    return {
      "start": start.minutesSinceMidnight,
      "end": end.minutesSinceMidnight,
    };
  }

  CoreHours.fromJson(Map<String, dynamic> json)
      : start = TimeOfDay(hour: (json["start"] / 60).toInt(), minute: json["start"] % 60),
        end = TimeOfDay(hour: (json["end"] / 60).toInt(), minute: json["end"] % 60);
}
