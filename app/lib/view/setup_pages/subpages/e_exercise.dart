import "package:activ8/utils/logger.dart";
import "package:activ8/view/setup_pages/setup_state.dart";
import "package:activ8/view/setup_pages/widgets/large_icon.dart";
import "package:activ8/view/widgets/custom_navigation_bar.dart";
import "package:activ8/shorthands/padding.dart";
import "package:day_night_time_picker/day_night_time_picker.dart";
import "package:flutter/material.dart";

class SetupExercisePage extends StatefulWidget {
  final SetupState setupState;
  final PageController pageController;

  const SetupExercisePage({
    super.key,
    required this.setupState,
    required this.pageController,
  });

  @override
  State<SetupExercisePage> createState() => _SetupExercisePageState();
}

class _SetupExercisePageState extends State<SetupExercisePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Allow tapping outside to dismiss keyboard
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
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
      ),
    );
  }

  List<Widget> _createContent(BuildContext context) {
    final TextStyle? headingTheme = Theme.of(context).textTheme.headlineLarge;

    return [
      padding(48),

      // Icon
      LargeIcon(icon: Icons.directions_run, color: Colors.red.shade400),
      padding(16),

      // Title
      Text("Exercise", style: headingTheme),
      padding(8),

      // Description
      const Text(
        "Let's get moving! Set a daily goal"
        "\nand we will help you reach it",
        textAlign: TextAlign.center,
      ),
      padding(16),

      // Step Goal Slider
      _createStepGoalSlider(),
      padding(4),
      const Text(
          "The CDC recommends 10,000 steps a day. We "
          "encourage you to aim high, but don't overexert!",
          textAlign: TextAlign.center),
      padding(12),
      _createTimeOfDayPicker(),
      padding(4),
      const Text(
          "We will check in with you at this time"
          "\nto help you achieve your goal",
          textAlign: TextAlign.center),
    ];
  }

  Widget _createStepGoalSlider() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Daily Step Goal", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${widget.setupState.stepGoal} steps", textAlign: TextAlign.right),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: SliderTheme(
              data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
              child: Slider(
                min: 5000,
                max: 25000,
                divisions: 20,
                value: widget.setupState.stepGoal.toDouble(),
                inactiveColor: Colors.white.withOpacity(0.35),
                onChanged: (double value) {
                  widget.setupState.stepGoal = value.toInt();
                  logger.i("Step goal set to ${widget.setupState.stepGoal}");
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTimeOfDayAction() async {
    logger.i("Opening time picker dialog");
    await Navigator.of(context).push(
      showPicker(
        context: context,
        iosStylePicker: true,
        value: Time.fromTimeOfDay(widget.setupState.reminderTime, 0),
        duskSpanInMinutes: 120,
        // optional
        onChange: (Time time) {
          widget.setupState.reminderTime = time.toTimeOfDay();
          logger.i("Reminder time set to ${widget.setupState.reminderTime.format(context)}");
        },
      ),
    );

    setState(() {});
  }

  Widget _createTimeOfDayPicker() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: Row(
              children: [
                const Text("Activity Reminder", style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton(
                  onPressed: _selectTimeOfDayAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontSize: 16),
                    elevation: 0,
                  ),
                  child: Text(widget.setupState.reminderTime.format(context), textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
