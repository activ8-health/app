import 'package:activ8/extensions/time_of_day_serializer.dart';
import 'package:activ8/managers/app_state.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SleepTimeWidget extends StatelessWidget {
  final TimeOfDay? sleepTime;
  final TimeOfDay? wakeTime;
  final DateTime? date;

  const SleepTimeWidget({super.key, this.sleepTime, this.wakeTime, this.date});

  @override
  Widget build(BuildContext context) {
    final Widget alarmSuggestionText = RichText(
      text: TextSpan(
        children: [
          const TextSpan(text: "Set an alarm at "),
          TextSpan(
            text: wakeTime?.format(context) ?? "--:--",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const TextSpan(text: "\nto get started"),
        ],
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white.withOpacity(0.65)),
      ),
      textAlign: TextAlign.center,
    );

    return Column(
      children: [
        _GaugeWidget(sleepTime: sleepTime, wakeTime: wakeTime, date: date),
        padding(16),
        alarmSuggestionText,
      ],
    );
  }
}

class _GaugeWidget extends StatelessWidget {
  final TimeOfDay? sleepTime;
  final TimeOfDay? wakeTime;
  final DateTime? date;

  const _GaugeWidget({this.sleepTime, this.wakeTime, this.date});

  final double width = 24;

  @override
  Widget build(BuildContext context) {
    // The sleep/wake times as doubles between 0..24
    final double sleepPosition = (sleepTime ?? const TimeOfDay(hour: 0, minute: 0)).hourDouble;
    final double wakePosition = (wakeTime ?? const TimeOfDay(hour: 0, minute: 0)).hourDouble;

    // The core hours as doubles between 0..24
    final double coreStart = AppState.instance.userPreferences!.coreHours.start.hourDouble;
    final double coreEnd = AppState.instance.userPreferences!.coreHours.end.hourDouble;

    // The icon for sleep
    final GaugePointer sleepPointer = WidgetPointer(
      value: sleepPosition,
      offset: 6,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.bedtime_outlined, size: 36),
      ),
    );

    // The icon for wake
    final GaugePointer wakePointer = WidgetPointer(
      value: wakePosition,
      offset: 6,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.yellow.shade900,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.alarm, size: 36),
      ),
    );

    // The gradient between the sleep/wake icons
    final GaugeRange sleepTrack = GaugeRange(
      startValue: sleepPosition,
      endValue: wakePosition,
      startWidth: width,
      endWidth: width,
      sizeUnit: GaugeSizeUnit.logicalPixel,
      gradient: SweepGradient(
        colors: [
          Colors.blue.shade900,
          Colors.blue.shade800,
          Colors.blue.shade700,
          Color.alphaBlend(Colors.yellow.shade900.withOpacity(0.8), Colors.black),
        ],
        stops: const [0, 0.15, 0.5, 1],
      ),
    );

    // The red track indicating the core hours we are avoiding
    final GaugeRange coreHoursRange = GaugeRange(
      startValue: coreStart,
      endValue: coreEnd,
      startWidth: width,
      endWidth: width,
      sizeUnit: GaugeSizeUnit.logicalPixel,
      color: Colors.red.withOpacity(0.35),
    );

    // The grey track behind other tracks
    final GaugeRange backgroundTrack = GaugeRange(
      startValue: 0,
      endValue: 24,
      startWidth: width,
      endWidth: width,
      sizeUnit: GaugeSizeUnit.logicalPixel,
      color: Colors.white.withOpacity(0.15),
    );

    final Widget dayOfWeekText = Text(
      (date != null) ? "${DateFormat.EEEE().format(date!).toUpperCase()}S" : "",
      style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold),
    );

    final Widget sleepText = Text(
      sleepTime?.format(context) ?? "--:--",
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        shadows: [
          Shadow(
            color: Colors.blue.withOpacity(0.8),
            offset: const Offset(0, 0),
            blurRadius: 12,
          ),
        ],
      ),
    );

    final Widget wakeText = Text(
      wakeTime?.format(context) ?? "--:--",
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        shadows: [
          Shadow(
            color: Colors.orange.withOpacity(0.6),
            offset: const Offset(0, 0),
            blurRadius: 12,
          ),
        ],
      ),
    );

    final Widget toText = Text(
      "to",
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
    );

    return SfRadialGauge(
      axes: [
        RadialAxis(
          minimum: 0,
          maximum: 24,
          startAngle: 270,
          endAngle: 270,
          tickOffset: 34,
          labelFormat: "",
          majorTickStyle: MajorTickStyle(
            thickness: 3,
            color: Colors.white.withOpacity(0.7),
            length: 15,
          ),
          minorTickStyle: MinorTickStyle(
            thickness: 2,
            color: Colors.white.withOpacity(0.2),
            length: 10,
          ),
          minorTicksPerInterval: 2,
          interval: 3,
          pointers: [sleepPointer, wakePointer],
          ranges: [backgroundTrack, coreHoursRange, sleepTrack],
          annotations: [
            GaugeAnnotation(widget: dayOfWeekText, angle: 270, positionFactor: 0.40),
            GaugeAnnotation(widget: sleepText, angle: 270, positionFactor: 0.22),
            GaugeAnnotation(widget: toText, angle: 0, positionFactor: 0),
            GaugeAnnotation(widget: wakeText, angle: 90, positionFactor: 0.22),
          ],
          showAxisLine: false,
        ),
      ],
    );
  }
}
