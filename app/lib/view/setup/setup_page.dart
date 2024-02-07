import 'package:activ8/view/setup/setup_state.dart';
import 'package:activ8/view/setup/subpages/a_welcome.dart';
import 'package:activ8/view/setup/subpages/b_health_permission.dart';
import 'package:activ8/view/setup/subpages/c_location_permission.dart';
import 'package:activ8/view/setup/subpages/d_profile.dart';
import 'package:activ8/view/setup/subpages/e_exercise.dart';
import 'package:activ8/view/setup/subpages/f_nutrition.dart';
import 'package:activ8/view/setup/subpages/g_core_hours.dart';
import 'package:activ8/view/setup/subpages/h_handshake.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final SetupState setupState = SetupState();
  final PageController pageController = PageController();

  late final List<Widget> pages;

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    pages = [
      SetupWelcomePage(setupState: setupState, pageController: pageController),

      // Permissions
      SetupHealthPermissionPage(setupState: setupState, pageController: pageController),
      SetupLocationPermissionPage(setupState: setupState, pageController: pageController),

      // Information
      SetupProfilePage(setupState: setupState, pageController: pageController),

      // Preferences
      SetupExercisePage(setupState: setupState, pageController: pageController),
      SetupNutritionPage(setupState: setupState, pageController: pageController),
      SetupCoreHoursPage(setupState: setupState, pageController: pageController),

      // Log in
      SetupHandshakePage(setupState: setupState, pageController: pageController, accountExists: false),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: backgroundGradient),
      child: Stack(
        children: [
          PageView(
            // Prevent scrolling
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: pages,
          ),
          Positioned(
            bottom: 35,
            left: 0,
            right: 0,
            child: _PageIndicator(
              pageController: pageController,
              pageCount: pages.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatefulWidget {
  final PageController pageController;
  final int pageCount;

  const _PageIndicator({
    required this.pageController,
    required this.pageCount,
  });

  @override
  State<_PageIndicator> createState() => _PageIndicatorState();
}

class _PageIndicatorState extends State<_PageIndicator> {
  int currentPage = 0;

  @override
  void initState() {
    widget.pageController.addListener(() {
      currentPage = widget.pageController.page?.toInt() ?? currentPage;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: widget.pageCount,
      position: currentPage,
      decorator: DotsDecorator(
        color: Colors.white.withOpacity(0.5),
        activeColor: Colors.white,
      ),
    );
  }
}
