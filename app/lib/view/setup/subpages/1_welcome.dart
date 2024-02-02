import 'package:activ8/view/setup/widgets/large_icon.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:activ8/view/widgets/styles.dart';
import 'package:flutter/material.dart';

class SetupWelcomePage extends StatelessWidget {
  final PageController pageController;

  const SetupWelcomePage({
    super.key,
    setupState, // unused
    required this.pageController,
  });

  void nextPageAction() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
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

  List<Widget> _createContents(BuildContext context) {
    final TextStyle? headingTheme = Theme.of(context).textTheme.headlineLarge;

    return [
      padding(96),
      LargeIcon(child: Image.asset("assets/icon.png")),
      padding(16),
      Text("Welcome to Activ8", style: headingTheme),
      padding(8),
      const Text("Embark on your personal\nself-improvement journey"),
      padding(32),
      ElevatedButton.icon(
        onPressed: nextPageAction,
        icon: const Icon(Icons.flight_takeoff),
        label: const Text("Let's Go!"),
        style: filledElevatedButtonStyle(context),
      ),
    ];
  }
}
