import 'package:activ8/types/food/dietary_restrictions.dart';
import 'package:activ8/types/food/weight_goal.dart';
import 'package:activ8/view/setup/setup_state.dart';
import 'package:activ8/view/setup/widgets/large_icon.dart';
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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool enableNext = false;

  Widget get divider => Divider(
        height: 0,
        color: Colors.white.withOpacity(0.25),
      );

  @override
  void initState() {
    super.initState();

    // Check to validate the form shortly after opening this page
    Future.delayed(const Duration(milliseconds: 300), () {
      enableNext = (formKey.currentState?.validate() ?? false);
      setState(() {});
    });
  }

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
            enableNext: enableNext,
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
      _createDietaryRestrictionForm(),
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
          setState(() {});
        },
        thumbColor: thumbColor,
      ),
    );
  }

  Widget _createDietaryRestrictionForm() {
    return SizedBox(
      width: 350,
      child: Form(
        key: formKey,
        onChanged: () {
          // Check to validate the form
          enableNext = (formKey.currentState?.validate() ?? false);
          setState(() {});
        },
        child: Column(
          children: [
            CheckableEntry(
              label: "Vegan",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.vegan),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.vegan, value),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(8)),
            ),
            divider,
            CheckableEntry(
              label: "Vegetarian",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.vegetarian),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.vegetarian, value),
            ),
            divider,
            CheckableEntry(
              label: "Kosher",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.kosher),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.kosher, value),
            ),
            divider,
            CheckableEntry(
              label: "Halal",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.halal),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.halal, value),
            ),
            divider,
            CheckableEntry(
              label: "Pescetarian",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.pescetarian),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.pescetarian, value),
            ),
            divider,
            CheckableEntry(
              label: "Sesame Free",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.sesameFree),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.sesameFree, value),
            ),
            divider,
            CheckableEntry(
              label: "Soy Free",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.soyFree),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.soyFree, value),
            ),
            divider,
            CheckableEntry(
              label: "Gluten Free",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.glutenFree),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.glutenFree, value),
            ),
            divider,
            CheckableEntry(
              label: "Lactose Intolerance",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.lactoseIntolerance),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.lactoseIntolerance, value),
            ),
            divider,
            CheckableEntry(
              label: "Nut Allergy",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.nutAllergy),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.nutAllergy, value),
            ),
            divider,
            CheckableEntry(
              label: "Peanut Allergy",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.peanutAllergy),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.peanutAllergy, value),
            ),
            divider,
            CheckableEntry(
              label: "Shellfish Allergy",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.shellfishAllergy),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.shellfishAllergy, value),
            ),
            divider,
            CheckableEntry(
              label: "Wheat Allergy",
              value: widget.setupState.dietaryRestrictions.contains(DietaryRestriction.wheatAllergy),
              onChanged: (bool value) => _updateDietaryRestriction(DietaryRestriction.wheatAllergy, value),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(8)),
            ),
          ],
        ),
      ),
    );
  }

  _updateDietaryRestriction(DietaryRestriction dietaryRestriction, bool value) {
    if (value) {
      widget.setupState.dietaryRestrictions.add(dietaryRestriction);
    } else {
      widget.setupState.dietaryRestrictions.remove(dietaryRestriction);
    }
  }
}
