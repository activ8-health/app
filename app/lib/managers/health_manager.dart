import 'package:activ8/utils/pair.dart';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

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
      if (kDebugMode) print("Failed to get permission status, trying fallback");
      List<HealthDataPoint> dataPoints = await _retrieveDataPoints(90, []);
      permission = dataPoints.isNotEmpty;
    }

    if (kDebugMode) print("Has Permissions: $permission");

    return permission;
  }

  Future<List<HealthDataPoint>> _retrieveDataPoints(int days, List<HealthDataType> dataTypes) async {
    // Extract Data Points
    DateTime endTime = DateTime.now();
    DateTime startTime = endTime.subtract(Duration(days: days));
    List<HealthDataPoint> dataPoints = await health.getHealthDataFromTypes(
      startTime,
      endTime,
      (dataTypes.isNotEmpty) ? dataTypes : HealthManager.dataTypes,
    );

    return dataPoints;
  }

  Future<List<HealthDataPoint>> retrieveStepData({int days = 90}) async {
    List<HealthDataPoint> dataPoints = await _retrieveDataPoints(days, [HealthDataType.STEPS]);

    return dataPoints;
  }

  Future<List<HealthDataPoint>> retrieveSleepData({int days = 90}) async {
    List<HealthDataPoint> dataPoints = await _retrieveDataPoints(days, [HealthDataType.SLEEP_IN_BED]);

    return dataPoints;
  }

  // Returns the height, followed by the weight
  Future<Pair<HealthDataPoint?>> retrieveHeightWeightData({int days = 90}) async {
    List<HealthDataPoint> dataPoints = await _retrieveDataPoints(days, [HealthDataType.HEIGHT, HealthDataType.WEIGHT]);

    HealthDataPoint maxHealthReducer(HealthDataPoint a, HealthDataPoint b) {
      return a.dateFrom.compareTo(b.dateFrom) > 0 ? a : b;
    }

    // Get latest height point
    Iterable<HealthDataPoint> heightPoints = dataPoints.where((e) => e.type == HealthDataType.HEIGHT);
    HealthDataPoint? height = (heightPoints).isEmpty ? null : heightPoints.reduce(maxHealthReducer);

    // Get latest weight point
    Iterable<HealthDataPoint> weightPoints = dataPoints.where((e) => e.type == HealthDataType.WEIGHT);
    HealthDataPoint? weight = (weightPoints).isEmpty ? null : weightPoints.reduce(maxHealthReducer);

    return Pair<HealthDataPoint?>(height, weight);
  }
}
