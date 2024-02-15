import 'package:activ8/types/gender.dart';
import 'package:activ8/utils/logger.dart';
import 'package:activ8/view/setup_pages/setup_state.dart';
import 'package:activ8/view/setup_pages/widgets/large_icon.dart';
import 'package:activ8/view/widgets/custom_navigation_bar.dart';
import 'package:activ8/view/widgets/custom_text_field.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';
import 'package:units_converter/units_converter.dart';

class SetupProfilePage extends StatefulWidget {
  final SetupState setupState;
  final PageController pageController;

  const SetupProfilePage({
    super.key,
    required this.setupState,
    required this.pageController,
  });

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final _FormFieldManager formFieldManager;
  bool enableNext = false;

  @override
  void initState() {
    super.initState();

    formFieldManager = _FormFieldManager(widget.setupState);

    // Check to validate the form shortly after opening this page
    Future.delayed(const Duration(milliseconds: 300), () {
      enableNext = (formKey.currentState?.validate() ?? false);
      logger.i("Can go to next page: $enableNext");
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
      LargeIcon(icon: Icons.person, color: Colors.grey.shade700),
      padding(16),

      // Title
      Text("Profile", style: headingTheme),
      padding(8),

      // Description
      const Text(
        "Let us get to know you!",
        textAlign: TextAlign.center,
      ),
      padding(16),

      // Form
      _createForm(),
    ];
  }

  Widget _createForm() {
    return SizedBox(
      width: 250,
      child: Form(
        key: formKey,
        onChanged: () {
          // Check to validate the form
          enableNext = (formKey.currentState?.validate() ?? false);
          logger.i("Can go to next page: $enableNext");
          setState(() {});
        },
        child: Column(
          children: [
            CustomTextField(
              label: "Name",
              initialValue: formFieldManager.name,
              onChanged: (String value) => formFieldManager.name = value,
              validator: (String value) => value.length >= 2 && value.length <= 35,
            ),
            Row(
              children: [
                Flexible(
                  child: CustomTextField(
                    label: "Age",
                    inputType: TextInputType.number,
                    suffix: "years",
                    initialValue: formFieldManager.age,
                    onChanged: (String age) {
                      age = age.trim();
                      if (int.tryParse(age) != null) formFieldManager.age = age;
                    },
                    validator: (String value) => (int.tryParse(value) ?? 0) >= 14 && (int.parse(value)) <= 120,
                  ),
                ),
                padding(8),
                Flexible(
                  child: DropdownButtonFormField(
                    decoration: createInputDecoration(context, "Sex"),
                    value: formFieldManager.sex,
                    items: const [
                      DropdownMenuItem(value: Sex.male, child: Text("Male")),
                      DropdownMenuItem(value: Sex.female, child: Text("Female")),
                      DropdownMenuItem(value: Sex.indeterminate, child: Text("Other")),
                    ],
                    onChanged: (Sex? sex) => formFieldManager.sex = sex,
                    validator: (Sex? sex) => sex != null ? null : "",
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Height (ft)
                Flexible(
                  child: CustomTextField(
                    label: "Height",
                    inputType: const TextInputType.numberWithOptions(decimal: true),
                    suffix: "ft",
                    initialValue: formFieldManager.heightFt,
                    onChanged: (String value) => formFieldManager.heightFt = value,
                    validator: (String value) => (double.tryParse(value) ?? 0) >= 3 && (double.parse(value)) <= 8,
                  ),
                ),

                padding(8),

                // Height (in)
                Flexible(
                  child: CustomTextField(
                    label: "",
                    inputType: const TextInputType.numberWithOptions(decimal: true),
                    suffix: "in",
                    initialValue: formFieldManager.heightIn,
                    onChanged: (String value) => formFieldManager.heightIn = value,
                    validator: (String value) => (double.tryParse(value) ?? -1) >= 0 && (double.parse(value)) <= 11,
                  ),
                ),
              ],
            ),
            CustomTextField(
              label: "Weight",
              inputType: const TextInputType.numberWithOptions(decimal: true),
              suffix: "lb",
              initialValue: formFieldManager.weight,
              onChanged: (String value) => formFieldManager.weight = value,
              validator: (String value) => (double.tryParse(value) ?? 0) >= 30 && (double.parse(value)) <= 800,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormFieldManager {
  final SetupState setupState;

  _FormFieldManager(this.setupState);

  String get name => setupState.name ?? "";

  set name(String name) {
    setupState.name = name.trim();
    logger.i('Name set to "$name"');
  }

  String get age => setupState.age?.toString() ?? "";

  set age(String age) {
    setupState.age = int.tryParse(age);
    logger.i('Age set to "$age"');
  }

  Sex? get sex => setupState.sex;

  set sex(Sex? sex) {
    setupState.sex = sex;
    logger.i("Sex set to $sex");
  }

  // Height, cm <=> ft/in

  String get heightFt => setupState.height?.convertFromTo(LENGTH.centimeters, LENGTH.feet)?.floor().toString() ?? "";

  String get heightIn {
    double? height = setupState.height;
    if (height == null) return "";
    return (height.convertFromTo(LENGTH.centimeters, LENGTH.inches)!.floor() % 12).toString();
  }

  set heightFt(String heightFt) {
    heightFt = heightFt.trim();
    if (int.tryParse(heightFt) == null) return;
    int heightIn = int.tryParse(this.heightIn) ?? 0;
    setupState.height = (heightIn + int.parse(heightFt) * 12).convertFromTo(LENGTH.inches, LENGTH.centimeters);
    logger.i("Height set to ${setupState.height} cm, converted from $heightFt ft $heightIn in");
  }

  set heightIn(String heightIn) {
    heightIn = heightIn.trim();
    if (int.tryParse(heightIn) == null) return;
    int heightFt = int.tryParse(this.heightFt) ?? 0;
    setupState.height = (int.parse(heightIn) + heightFt * 12).convertFromTo(LENGTH.inches, LENGTH.centimeters);
    logger.i("Height set to ${setupState.height} cm, converted from $heightFt ft $heightIn in");
  }

  // Weight, kg <=> lb

  String get weight => setupState.weight?.convertFromTo(MASS.kilograms, MASS.pounds)?.toStringAsFixed(2) ?? "";

  set weight(String weight) {
    setupState.weight = double.tryParse(weight)?.convertFromTo(MASS.pounds, MASS.kilograms);
    logger.i("Weight set to ${setupState.weight} kg, converted from $weight lb");
  }
}
