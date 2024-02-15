import 'dart:math';

import 'package:activ8/utils/logger.dart';
import 'package:activ8/view/setup_pages/setup_state.dart';
import 'package:activ8/view/setup_pages/widgets/large_icon.dart';
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
      LargeIcon(icon: Icons.business_center, color: Colors.orange.shade500),
      padding(16),

      // Title
      Text("Core Hours", style: headingTheme),
      padding(8),

      // Description
      const Text(
        "Select the times you think you'll be busy"
        "\nWe will avoid these hours when suggesting sleep",
        textAlign: TextAlign.center,
      ),
      padding(4),

      // Time Range Picker
      _createTimeRangePicker(),
      padding(4),

      const Text(
        "We will remind you to sleep 30 minutes"
        "\nbefore your recommended sleep time",
        textAlign: TextAlign.center,
      ),
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

    String startHourText = widget.setupState.coreHours.start.format(context);
    String endHourText = widget.setupState.coreHours.end.format(context);

    return SizedBox(
      width: 320,
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
        start: widget.setupState.coreHours.start,
        end: widget.setupState.coreHours.end,
        onStartChange: (TimeOfDay start) {
          widget.setupState.coreHours.start = start;
          logger.i("Set core hour start time to ${start.format(context)}");
          setState(() {});
        },
        onEndChange: (TimeOfDay end) {
          widget.setupState.coreHours.end = end;
          logger.i("Set core hour end time to ${end.format(context)}");
          setState(() {});
        },
        backgroundWidget: Text("$startHourText to $endHourText",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
      ),
    );
  }
}
