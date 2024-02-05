class StepPoint {
  final DateTime dateFrom;
  final DateTime dateTo;
  final int steps;

  StepPoint({required this.dateFrom, required this.dateTo, required this.steps});

  @override
  String toString() {
    return "StepPoint(dateFrom: $dateFrom, dateTo: $dateTo, steps: $steps)";
  }
}

class SleepPoint {
  final DateTime dateFrom;
  final DateTime dateTo;

  SleepPoint({required this.dateFrom, required this.dateTo});

  @override
  String toString() {
    return "SleepPoint(dateFrom: $dateFrom, dateTo: $dateTo)";
  }
}
