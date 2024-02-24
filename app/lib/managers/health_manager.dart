import "package:activ8/constants.dart";
import "package:activ8/types/health_data.dart";
import "package:activ8/utils/logger.dart";
import "package:activ8/utils/pair.dart";
import "package:health/health.dart";

class HealthManager {
  // Set up singleton
  static final HealthManager instance = HealthManager._create();

  HealthManager._create();

  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: false);

  static const List<HealthDataType> dataTypes = [
    // Preliminary Data
    HealthDataType.HEIGHT,
    HealthDataType.WEIGHT,

    // Exercise
    HealthDataType.STEPS,

    // Sleep
    HealthDataType.SLEEP_IN_BED,
  ];

  /// Requests the system for permission to health data, returns success status
  Future<bool> requestPermissions() async {
    await health.requestAuthorization(dataTypes);
    return await hasPermissions();
  }

  Future<bool> hasPermissions() async {
    bool? permission = await health.hasPermissions(dataTypes);

    if (permission == null) {
      logger.w("Failed to get permission status, trying fallback");
      final List<HealthDataPoint> dataPoints = await _retrieveDataPoints(90, []);
      permission = dataPoints.isNotEmpty;
    }

    logger.d("Has Permissions: $permission");

    return permission;
  }

  /// Retrieves data points for a generic type
  Future<List<HealthDataPoint>> _retrieveDataPoints(int days, List<HealthDataType> dataTypes) async {
    // Extract Data Points
    final DateTime endTime = DateTime.now();
    final DateTime startTime = endTime.subtract(Duration(days: days));
    final List<HealthDataPoint> dataPoints = await health.getHealthDataFromTypes(
      startTime,
      endTime,
      (dataTypes.isNotEmpty) ? dataTypes : HealthManager.dataTypes,
    );

    logger.i("Retrieved ${dataPoints.length} datapoints for types $dataTypes");

    return dataPoints;
  }

  Future<List<StepPoint>> retrieveStepData({int days = healthHistoryLength}) async {
    final List<HealthDataPoint> dataPoints = await _retrieveDataPoints(days, [HealthDataType.STEPS]);

    // Convert HealthDataPoints to StepPoints
    final List<StepPoint> stepPoints = dataPoints
        .map((point) => StepPoint(
            dateFrom: point.dateFrom,
            dateTo: point.dateTo,
            steps: (point.value as NumericHealthValue).numericValue.toInt()))
        .toList();

    return stepPoints;
  }

  Future<List<SleepPoint>> retrieveSleepData({int days = healthHistoryLength}) async {
    final List<HealthDataPoint> dataPoints = await _retrieveDataPoints(days, [HealthDataType.SLEEP_IN_BED]);

    // Convert HealthDataPoints to SleepPoints
    final List<SleepPoint> sleepPoints =
        dataPoints.map((point) => SleepPoint(dateFrom: point.dateFrom, dateTo: point.dateTo)).toList();

    return sleepPoints;
  }

  /// Retrieves sleep and step data
  Future<HealthData> retrieveHealthData({int days = healthHistoryLength}) async {
    return HealthData(
      stepData: await HealthManager.instance.retrieveStepData(days: days),
      sleepData: await HealthManager.instance.retrieveSleepData(days: days),
    );
  }

  // Returns the height, followed by the weight
  Future<Pair<HealthDataPoint?>> retrieveHeightWeightData({int days = 90}) async {
    final List<HealthDataPoint> dataPoints = await _retrieveDataPoints(days, [HealthDataType.HEIGHT, HealthDataType.WEIGHT]);

    HealthDataPoint maxHealthReducer(HealthDataPoint a, HealthDataPoint b) {
      return a.dateFrom.compareTo(b.dateFrom) > 0 ? a : b;
    }

    // Get latest height point
    final Iterable<HealthDataPoint> heightPoints = dataPoints.where((e) => e.type == HealthDataType.HEIGHT);
    final HealthDataPoint? height = (heightPoints).isEmpty ? null : heightPoints.reduce(maxHealthReducer);

    // Get latest weight point
    final Iterable<HealthDataPoint> weightPoints = dataPoints.where((e) => e.type == HealthDataType.WEIGHT);
    final HealthDataPoint? weight = (weightPoints).isEmpty ? null : weightPoints.reduce(maxHealthReducer);

    return Pair<HealthDataPoint?>(height, weight);
  }
}
