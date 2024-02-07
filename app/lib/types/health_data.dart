class StepPoint {
  final DateTime dateFrom;
  final DateTime dateTo;
  final int steps;

  StepPoint({required this.dateFrom, required this.dateTo, required this.steps});

  Map<String, dynamic> toJson() {
    return {
      "date_from": dateFrom.toIso8601String(),
      "date_to": dateTo.toIso8601String(),
      "steps": steps,
    };
  }
}

class SleepPoint {
  final DateTime dateFrom;
  final DateTime dateTo;

  SleepPoint({required this.dateFrom, required this.dateTo});

  Map<String, dynamic> toJson() {
    return {
      "date_from": dateFrom.toIso8601String(),
      "date_to": dateTo.toIso8601String(),
    };
  }
}

class HealthData {
  final List<StepPoint> stepData;
  final List<SleepPoint> sleepData;

  HealthData({required this.stepData, required this.sleepData});

  Map<String, dynamic> toJson() {
    return {
      "step_data": stepData.map((e) => e.toJson()).toList(),
      "sleep_data": sleepData.map((e) => e.toJson()).toList(),
    };
  }
}
