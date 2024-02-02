import 'package:activ8/view/widgets/styles.dart';
import 'package:flutter/material.dart';

/// Creates a two-button navigation bar
class CustomNavigationBar extends StatelessWidget {
  final PageController pageController;
  final bool enableNext; // Whether the next button should be enabled (for validation)
  final bool showNext;

  const CustomNavigationBar({
    super.key,
    required this.pageController,
    this.enableNext = true,
    this.showNext = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _createBackButton(),
          if (showNext) _createForwardButton(context),
        ],
      ),
    );
  }

  /// Creates an [IconButton] that goes back a page
  Widget _createBackButton() {
    return IconButton(
      onPressed: () {
        pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
        );
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  /// Creates an [ElevatedButton] that goes forward a page
  Widget _createForwardButton(context) {
    Function()? action;

    // Determine whether the button should be available
    if (enableNext) {
      action = () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
        );
      };
    }

    // Create the icon
    Widget icon = ElevatedButton.icon(
      onPressed: action,
      icon: const Icon(Icons.arrow_back),
      label: const Text("Next"),
      style: filledElevatedButtonStyle(context),
    );

    // The Directionality widget is used to invert the position of the icon
    return Directionality(
      textDirection: TextDirection.rtl,
      child: icon,
    );
  }
}

/// Shorthand to insert a [CustomNavigationBar] into the tree
class CustomNavigationBarWrapper extends StatelessWidget {
  final Widget child;
  final PageController pageController;
  final bool enableNext;
  final bool showNext;

  const CustomNavigationBarWrapper({
    super.key,
    required this.child,
    required this.pageController,
    this.enableNext = true,
    this.showNext = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        child,
        Align(
          alignment: Alignment.bottomCenter,
          child: CustomNavigationBar(
            pageController: pageController,
            enableNext: enableNext,
            showNext: showNext,
          ),
        ),
      ],
    );
  }
}
