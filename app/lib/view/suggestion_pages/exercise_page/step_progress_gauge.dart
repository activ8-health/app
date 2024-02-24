import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class StepProgressGauge extends StatelessWidget {
  final double progress;
  final double target;

  const StepProgressGauge({super.key, required this.progress, required this.target});

  @override
  Widget build(BuildContext context) {
    return SfLinearGauge(
      minimum: 0,
      maximum: target,
      showLabels: false,
      showTicks: false,
      axisTrackStyle: LinearAxisTrackStyle(
        thickness: 20,
        edgeStyle: LinearEdgeStyle.bothCurve,
        color: Colors.white.withOpacity(0.25),
      ),
      barPointers: [
        LinearBarPointer(
          enableAnimation: false,
          value: max(progress, target * 0.075),
          thickness: 20,
          edgeStyle: LinearEdgeStyle.bothCurve,
          color: Colors.white,
          shaderCallback: _getShader,
        )
      ],
    );
  }

  Shader _getShader(Rect bounds) {
    return const LinearGradient(
      colors: [
        Color(0xFFFFEFBA),
        Color(0xFFFFFFFF),
      ],
    ).createShader(bounds);
  }
}
