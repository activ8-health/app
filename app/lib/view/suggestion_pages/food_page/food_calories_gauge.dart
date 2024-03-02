import "dart:math";

import "package:activ8/constants.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:syncfusion_flutter_gauges/gauges.dart";

class FoodCaloriesGauge extends StatelessWidget {
  final int? caloriesConsumed;
  final int? caloriesGoal;

  const FoodCaloriesGauge({super.key, this.caloriesConsumed, this.caloriesGoal});

  final double width = 20;
  final double degreesUnder = 45;

  @override
  Widget build(BuildContext context) {
    final int caloriesConsumed = this.caloriesConsumed ?? 0;
    final int caloriesGoal = this.caloriesGoal ?? 2000;

    final bool consumedExcess = (caloriesConsumed >= caloriesGoal + caloriesOverWarningThreshold);

    // The gradient that colors the gauge
    final GaugePointer gaugePointer = RangePointer(
      // The minimum value should be 12 to prevent the corners from becoming flat
      value: max(0.14 * (caloriesGoal), caloriesConsumed.toDouble()),
      cornerStyle: CornerStyle.bothCurve,
      enableAnimation: true,
      animationDuration: 1200,
      sizeUnit: GaugeSizeUnit.logicalPixel,
      color: (consumedExcess) ? Colors.red : null,
      gradient: const SweepGradient(
        colors: [
          Color(0xFFFFDEA9),
          Color(0xFFFFFFFF),
        ],
      ),
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
              positionFactor: 0.06,
              widget: _getTextLabel(context),
            )
          ],
          showAxisLine: false,
          canScaleToFit: true,
        ),
      ],
    );
  }

  Widget _getTextLabel(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Symbols.nutrition, size: 30, color: Colors.white.withOpacity(0.8)),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: RichText(
            text: TextSpan(
              children: [
                (caloriesConsumed != null)
                    ? TextSpan(
                        text: "$caloriesConsumed",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      )
                    : WidgetSpan(
                        child: Container(
                          width: 28 * 1.5,
                          height: 28,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                TextSpan(
                  text: " cal",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: "of "),
              (caloriesGoal != null)
                  ? TextSpan(text: "$caloriesGoal")
                  : WidgetSpan(
                      child: Container(
                        width: 18 * 1.5,
                        height: 18,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
            ],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
