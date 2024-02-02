import 'package:activ8/managers/health_manager.dart';
import 'package:activ8/structures/health_data_points.dart';
import 'package:activ8/utils/pair.dart';
import 'package:activ8/view/setup/setup_state.dart';
import 'package:activ8/view/setup/widgets/large_icon.dart';
import 'package:activ8/view/widgets/custom_navigation_bar.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';

class SetupPermissionPage extends StatefulWidget {
  final SetupState setupState;
  final PageController pageController;

  const SetupPermissionPage({
    super.key,
    required this.setupState,
    required this.pageController,
  });

  @override
  State<SetupPermissionPage> createState() => _SetupPermissionPageState();
}

class _SetupPermissionPageState extends State<SetupPermissionPage> {
  bool hasPermissions = false;
  bool showHint = false;

  void requestPermissionsAction() async {
    hasPermissions = await HealthManager.instance.requestPermissions();

    // Show failed message
    if (!hasPermissions) {
      showHint = true;
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to get all permissions. Please try granting "
                "them in system settings."),
          ),
        );
      }

      setState(() {});
      return;
    }

    // Update the height and weight
    if (hasPermissions) {
      _updateHeightWeight();
      _updateStepsAndSleep();
    }

    setState(() {});
  }

  /// Sets the height and weight in [widget.setupState]
  void _updateHeightWeight() async {
    // Retrieve health points from the last 30 years
    Pair<HealthDataPoint?> values = await HealthManager.instance.retrieveHeightWeightData(days: 365 * 30);

    // Height
    if (values.first != null && widget.setupState.height == null) {
      NumericHealthValue value = values.first!.value as NumericHealthValue;
      double height = value.numericValue.toDouble();

      // m -> cm
      height *= 100;
      widget.setupState.height = height;
    }

    // Weight
    if (values.second != null && widget.setupState.weight == null) {
      NumericHealthValue value = values.second!.value as NumericHealthValue;
      double weight = value.numericValue.toDouble();

      widget.setupState.weight = weight;
    }
  }

  /// Sets the steps and sleep in [widget.setupState]
  void _updateStepsAndSleep() async {
    // Retrieve health points from the last 30 years
    int days = 365 * 30;

    List<SleepPoint> sleepData = (await HealthManager.instance.retrieveSleepData(days: days))
        .map((point) => SleepPoint(dateFrom: point.dateFrom, dateTo: point.dateTo))
        .toList();

    List<StepPoint> stepData = (await HealthManager.instance.retrieveStepData(days: days))
        .map((point) => StepPoint(
            dateFrom: point.dateFrom,
            dateTo: point.dateTo,
            steps: (point.value as NumericHealthValue).numericValue.toInt()))
        .toList();

    widget.setupState.sleeps = sleepData;
    widget.setupState.steps = stepData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomNavigationBarWrapper(
          pageController: widget.pageController,
          enableNext: hasPermissions,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: _createContents(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _createContents(context) {
    final TextStyle? headingTheme = Theme.of(context).textTheme.headlineLarge;

    return [
      padding(48),

      // Icon
      LargeIcon(icon: Icons.monitor_heart_outlined, color: Colors.red.shade300),
      padding(16),

      // Title
      Text("Health Data", style: headingTheme),
      padding(8),

      // Description
      const Text(
        "To give you the most personalized"
        "\nexperience, we need to connect to"
        "\nyour health tracker",
        textAlign: TextAlign.center,
      ),
      padding(32),

      // Check Button
      _createCheckForPermissionsButton(context),
      _createHint(widget.pageController),

      // Navigation Bar
      Expanded(child: Container()),
    ];
  }

  /// Creates the [ElevatedButton] that checks for permissions if no permissions were found
  /// Creates an inactive [ElevatedButton] to report status if permissions were found
  Widget _createCheckForPermissionsButton(context) {
    // Permissions were found, create inactive button
    if (hasPermissions) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.check_outlined),
        label: const Text("Looks Good!"),
        onPressed: null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(128, 48),
        ),
      );
    }

    // Permissions were not found, create request button
    return ElevatedButton.icon(
      icon: const Icon(Icons.sync),
      label: const Text("Check for Permissions"),
      onPressed: requestPermissionsAction,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(128, 48),
      ),
    );
  }

  /// Creates the hint & actions that appear when permissions are not found
  Widget _createHint(PageController pageController) {
    return AnimatedOpacity(
      opacity: showHint ? 1 : 0,
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          padding(16),
          const Text(
            "To grant permissions manually"
            "\nSettings > Health > Data Access > Activ8",
            textAlign: TextAlign.center,
          ),
          padding(8),
          const TextButton(
            onPressed: AppSettings.openAppSettings,
            child: Text("Open Settings"),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuart,
              );
            },
            child: const Text("I'm sure I granted permissions"),
          ),
        ],
      ),
    );
  }
}
