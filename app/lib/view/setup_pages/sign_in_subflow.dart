import 'package:activ8/view/setup_pages/setup_state.dart';
import 'package:activ8/view/setup_pages/subpages/b_health_permission.dart';
import 'package:activ8/view/setup_pages/subpages/c_location_permission.dart';
import 'package:activ8/view/setup_pages/subpages/h_handshake.dart';
import 'package:activ8/view/widgets/page_indicator.dart';
import 'package:flutter/material.dart';

class SignInSubflow extends StatefulWidget {
  const SignInSubflow({super.key});

  @override
  State<SignInSubflow> createState() => _SignInSubflowState();
}

class _SignInSubflowState extends State<SignInSubflow> {
  final SetupState setupState = SetupState();
  final PageController pageController = PageController();

  late final List<Widget> pages;

  // uiGradients Lawrencium (hue shifted)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF290C0E), Color(0xFF632B36), Color(0xFF3D232C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    pages = [
      // TODO add page to easy the user into the new workflow branch
      SetupHealthPermissionPage(setupState: setupState, pageController: pageController),
      SetupLocationPermissionPage(setupState: setupState, pageController: pageController),
      SetupHandshakePage(setupState: setupState, pageController: pageController, accountExists: true),
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
