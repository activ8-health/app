import 'package:activ8/types/food/dietary_restrictions.dart';
import 'package:activ8/types/food/weight_goal.dart';
import 'package:activ8/utils/logger.dart';
import 'package:activ8/view/setup_pages/setup_state.dart';
import 'package:activ8/view/setup_pages/widgets/large_icon.dart';
import 'package:activ8/view/widgets/checkable_entry.dart';
import 'package:activ8/view/widgets/custom_navigation_bar.dart';
import 'package:activ8/view/widgets/icon_with_label.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetupNutritionPage extends StatefulWidget {
  final SetupState setupState;
  final PageController pageController;

  const SetupNutritionPage({
    super.key,
    required this.setupState,
    required this.pageController,
  });

  @override
  State<SetupNutritionPage> createState() => _SetupNutritionPageState();
}

class _SetupNutritionPageState extends State<SetupNutritionPage> {
  Widget get divider => Divider(
        height: 0,
        color: Colors.white.withOpacity(0.25),
      );

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
      LargeIcon(icon: Icons.dinner_dining, color: Colors.green.shade400),
      padding(16),

      // Title
      Text("Nutrition", style: headingTheme),
      padding(8),

      // Description
      const Text(
        "A balanced diet makes a balanced life!",
        textAlign: TextAlign.center,
      ),
      padding(16),

      // Eating Goal
      const Text("What is your weight goal?"),
      padding(4),
      _createWeightGoalSelector(context),
      padding(16),

      // Dietary Restrictions
      const Text("Do you have any dietary restrictions?"),
      padding(4),
      _createDietaryRestrictionSelection(),
      padding(64),
    ];
  }

  Widget _createWeightGoalSelector(context) {
    Color thumbColor = Theme.of(context).colorScheme.primary.withOpacity(0.2);

    return SizedBox(
      width: 350,
      child: CupertinoSlidingSegmentedControl(
        children: const {
          WeightGoal.lose: IconWithLabel(icon: Icons.monitor_weight_outlined, label: "Lose"),
          WeightGoal.maintain: IconWithLabel(icon: Icons.how_to_reg, label: "Maintain"),
          WeightGoal.gain: IconWithLabel(icon: Icons.monitor_weight, label: "Gain"),
        },
        groupValue: widget.setupState.weightGoal,
        onValueChanged: (WeightGoal? value) {
          if (value != null) widget.setupState.weightGoal = value;
          logger.i("Weight goal set to $value");
          setState(() {});
        },
        thumbColor: thumbColor,
      ),
    );
  }

  Widget _createDietaryRestrictionSelection() {
    BorderRadius getBorderRadius(DietaryRestriction restriction) {
      if (restriction == DietaryRestriction.values.first) {
        return const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(8));
      } else if (restriction == DietaryRestriction.values.last) {
        return const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(8));
      } else {
        return BorderRadius.zero;
      }
    }

    return SizedBox(
      width: 350,
      child: Column(
        children: [
          for (DietaryRestriction restriction in DietaryRestriction.values) ...[
            CheckableEntry(
              label: restriction.displayName,
              value: widget.setupState.dietaryRestrictions.contains(restriction),
              onChanged: (bool value) => _updateDietaryRestriction(restriction, value),
              borderRadius: getBorderRadius(restriction),
            ),
            if (restriction != DietaryRestriction.values.last) divider,
          ],
        ],
      ),
    );
  }

  _updateDietaryRestriction(DietaryRestriction dietaryRestriction, bool value) {
    logger.i("Set $dietaryRestriction to $value");
    if (value) {
      widget.setupState.dietaryRestrictions.add(dietaryRestriction);
    } else {
      widget.setupState.dietaryRestrictions.remove(dietaryRestriction);
    }
  }
}
