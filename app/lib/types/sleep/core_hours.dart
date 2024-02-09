import 'package:activ8/extensions/time_of_day_serializer.dart';
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
      : start = TimeOfDaySerializer.fromMinutesSinceMidnight(json["start"]),
        end = TimeOfDaySerializer.fromMinutesSinceMidnight(json["end"]);
}
