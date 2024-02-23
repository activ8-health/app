import 'package:activ8/view/setup_pages/setup_state.dart';
import 'package:activ8/view/setup_pages/subpages/a_welcome.dart';
import 'package:activ8/view/setup_pages/subpages/b_health_permission.dart';
import 'package:activ8/view/setup_pages/subpages/c_location_permission.dart';
import 'package:activ8/view/setup_pages/subpages/d_profile.dart';
import 'package:activ8/view/setup_pages/subpages/e_exercise.dart';
import 'package:activ8/view/setup_pages/subpages/f_nutrition.dart';
import 'package:activ8/view/setup_pages/subpages/g_core_hours.dart';
import 'package:activ8/view/setup_pages/subpages/h_handshake.dart';
import 'package:activ8/view/widgets/page_indicator.dart';
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

  // uiGradients (Lawrencium)
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
            child: PageIndicator(
              pageController: pageController,
              pageCount: pages.length,
            ),
          ),
        ],
      ),
    );
  }
}
