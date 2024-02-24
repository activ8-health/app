import "dart:math";

import "package:flutter/material.dart";
import "package:syncfusion_flutter_gauges/gauges.dart";

class LifestyleScoreContent extends StatelessWidget {
  /// If this score is null, then this widget will interpret the value as indeterminate
  final int? fitnessScore;

  const LifestyleScoreContent({super.key, this.fitnessScore});

  final double width = 30;
  final double degreesUnder = 25; // the number of degrees the gauge "peeks" under y=0

  // the height of the gauge as a fraction of the width, determined by its angle
  double get heightToWidthRatio => sin(degreesUnder * pi / 180) / 2 + 0.5;

  /// Scales the gradient so that we can render part of it
  /// For instance, if we render only 45% of the gradient, this scales
  /// it so that the gradient the stops 0-1 only make up 45% of the gradient
  /// That is, the maximum "stop" x is such that 0.45 * x = 1
  double _scaleGradient(num value, double percentage) {
    if (percentage == 0) percentage = 0.01;
    return value * (1 / percentage);
  }

  @override
  Widget build(BuildContext context) {
    // The gradient that colors the gauge
    final GaugePointer gaugePointer = RangePointer(
      // The minimum value should be 12 to prevent the corners from becoming flat
      value: max(12, (fitnessScore ?? 0).toDouble()),
      cornerStyle: CornerStyle.bothCurve,
      enableAnimation: true,
      animationDuration: 1200,
      sizeUnit: GaugeSizeUnit.logicalPixel,
      gradient: SweepGradient(
        colors: const [Colors.red, Colors.orange, Colors.yellow, Colors.green],
        // Looks wrong when animating down, since values past the end assume the last value in the gradient
        stops: [0, 0.25, 0.5, 1].map((e) => _scaleGradient(e, (fitnessScore ?? 0) / 100)).toList(),
      ),
      color: Colors.white,
      width: width,
    );

    // The white track of the gauge
    final GaugePointer gaugeRange = RangePointer(
      value: 100,
      cornerStyle: CornerStyle.bothCurve,
      sizeUnit: GaugeSizeUnit.logicalPixel,
      color: Colors.white.withOpacity(0.2),
      width: width,
    );

    // Center of the gauge
    final Widget label = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${fitnessScore ?? '--'}", style: Theme.of(context).textTheme.headlineLarge),
            Text(" / 100", style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        Text("Lifestyle Score", style: Theme.of(context).textTheme.headlineSmall)
      ],
    );

    return ClipRRect(
      child: Align(
        alignment: Alignment.center,
        heightFactor: heightToWidthRatio,
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              showTicks: false,
              showLabels: false,
              minimum: 0,
              maximum: 100,
              startAngle: 180 - degreesUnder,
              endAngle: degreesUnder,
              pointers: [gaugePointer, gaugeRange],
              annotations: [GaugeAnnotation(angle: 270, widget: label, positionFactor: 0.15)],
              showAxisLine: false,
              canScaleToFit: true,
            ),
          ],
        ),
      ),
    );
  }
}
