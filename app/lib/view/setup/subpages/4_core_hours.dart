import 'dart:math';

import 'package:activ8/view/setup/setup_state.dart';
import 'package:activ8/view/setup/widgets/large_icon.dart';
import 'package:activ8/view/widgets/custom_navigation_bar.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';

class SetupCoreHoursPage extends StatefulWidget {
  final SetupState setupState;
  final PageController pageController;

  const SetupCoreHoursPage({
    super.key,
    required this.setupState,
    required this.pageController,
  });

  @override
  State<SetupCoreHoursPage> createState() => _SetupCoreHoursPageState();
}

class _SetupCoreHoursPageState extends State<SetupCoreHoursPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomNavigationBarWrapper(
          pageController: widget.pageController,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: _createContent(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _createContent(BuildContext context) {
    final TextStyle? headingTheme = Theme.of(context).textTheme.headlineLarge;

    return [
      padding(48),

      // Icon
      LargeIcon(icon: Icons.bedtime, color: Colors.blue.shade900),
      padding(16),

      // Title
      Text("Core Hours", style: headingTheme),
      padding(8),

      // Description
      const Text(
        "Select the times you think you'll be busy",
        textAlign: TextAlign.center,
      ),
      padding(16),

      // Time Range Picker
      _createTimeRangePicker(),
    ];
  }

  Widget _createTimeRangePicker() {
    List<ClockLabel> labels = [];
    // AM labels
    for (int i = 0; i < 12; i += 2) {
      labels.add(ClockLabel(
        text: "${(i == 0 ? 12 : i)} AM",
        angle: pi / 2 + i * pi / 12,
      ));
    }
    // PM labels
    for (int i = 0; i < 12; i += 2) {
      labels.add(ClockLabel(
        text: "${(i == 0 ? 12 : i)} PM",
        angle: -pi / 2 + i * pi / 12,
      ));
    }

    return SizedBox(
      width: 370,
      child: TimeRangePicker(
        handlerColor: Color.alphaBlend(Colors.pinkAccent.shade100.withOpacity(0.3), Colors.white),
        strokeColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        backgroundColor: Colors.white.withOpacity(0.2),
        interval: const Duration(minutes: 15),
        selectedColor: Colors.white,
        clockRotation: 3.1415 / 2,
        use24HourFormat: false,
        hideButtons: true,
        hideTimes: true,
        labels: labels,
        snap: true,
        ticks: 24,
        start: widget.setupState.coreStart,
        end: widget.setupState.coreEnd,
        onStartChange: (start) {
          widget.setupState.coreStart = start;
          setState(() {});
        },
        onEndChange: (end) {
          widget.setupState.coreEnd = end;
          setState(() {});
        },
        backgroundWidget: Text(
            "${widget.setupState.coreStart.format(context)} to ${widget.setupState.coreEnd.format(context)}",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
      ),
    );
  }
}
