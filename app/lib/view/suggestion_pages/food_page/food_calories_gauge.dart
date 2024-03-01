import "dart:math";

import "package:flutter/material.dart";
import "package:syncfusion_flutter_gauges/gauges.dart";

class FoodCaloriesGauge extends StatelessWidget {
  final int caloriesGoal;
  final int caloriesConsumed;

  const FoodCaloriesGauge({super.key, caloriesGoal, caloriesConsumed})
      : caloriesGoal = caloriesGoal ?? 2000,
        caloriesConsumed = caloriesConsumed ?? 0;

  final double width = 20;
  final double degreesUnder = 45;

  bool get consumedExcess => caloriesConsumed >= caloriesGoal + 200;

  @override
  Widget build(BuildContext context) {
    // The gradient that colors the gauge
    final GaugePointer gaugePointer = RangePointer(
      // The minimum value should be 12 to prevent the corners from becoming flat
      value: max(0.14 * (caloriesGoal), caloriesConsumed.toDouble()),
      cornerStyle: CornerStyle.bothCurve,
      enableAnimation: true,
      animationDuration: 1200,
      sizeUnit: GaugeSizeUnit.logicalPixel,
      color: (consumedExcess) ? Colors.red : Colors.white,
      width: width,
    );

    // The white track of the gauge
    final GaugePointer gaugeRange = RangePointer(
      value: caloriesGoal.toDouble(),
      cornerStyle: CornerStyle.bothCurve,
      sizeUnit: GaugeSizeUnit.logicalPixel,
      color: Colors.white.withOpacity(0.2),
      width: width,
    );

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          showTicks: false,
          showLabels: false,
          minimum: 0,
          maximum: caloriesGoal.toDouble(),
          startAngle: 180 - degreesUnder,
          endAngle: degreesUnder,
          pointers: [gaugePointer, gaugeRange],
          annotations: [
            GaugeAnnotation(
              angle: 90,
              positionFactor: 0.15,
              widget: Icon(
                Icons.local_fire_department,
                color: Colors.orange.shade300,
                size: 64,
              ),
            )
          ],
          showAxisLine: false,
          canScaleToFit: true,
        ),
      ],
    );
  }
}
