import "package:activ8/view/setup_pages/setup_state.dart";
import "package:activ8/view/setup_pages/subpages/a_welcome.dart";
import "package:activ8/view/setup_pages/subpages/b_health_permission.dart";
import "package:activ8/view/setup_pages/subpages/c_location_permission.dart";
import "package:activ8/view/setup_pages/subpages/d_profile.dart";
import "package:activ8/view/setup_pages/subpages/e_exercise.dart";
import "package:activ8/view/setup_pages/subpages/f_nutrition.dart";
import "package:activ8/view/setup_pages/subpages/g_core_hours.dart";
import "package:activ8/view/setup_pages/subpages/h_handshake.dart";
import "package:activ8/view/widgets/page_indicator.dart";
import "package:flutter/material.dart";

// uiGradients (Lawrencium)
const LinearGradient _backgroundGradient = LinearGradient(
  colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final SetupState setupState = SetupState();
  final PageController pageController = PageController();

  late final List<Widget> pages = [
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

  @override
  Widget build(BuildContext context) {
    // Each subpage has its own Scaffold
    return Container(
      decoration: const BoxDecoration(gradient: _backgroundGradient),
      child: Stack(
        children: [
          PageView(
            // Prevent manual scrolling
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
