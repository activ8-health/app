import "package:activ8/view/widgets/styles.dart";
import "package:flutter/material.dart";

/// Creates a two-button navigation bar for paginated [PageView]
class CustomNavigationBar extends StatelessWidget {
  final PageController pageController;
  final bool allowNext; // Whether the next button should be enabled (for validation)
  final bool showNextButton;

  const CustomNavigationBar({
    super.key,
    required this.pageController,
    this.allowNext = true,
    this.showNextButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _createBackButton(context),
          if (showNextButton) _createForwardButton(context),
        ],
      ),
    );
  }

  /// Creates an [IconButton] that goes back a page
  Widget _createBackButton(context) {
    return IconButton(
      onPressed: () async {
        if (pageController.page != null && pageController.page! < 0.5) {
          Navigator.of(context).pop();
        }
        await pageController.previousPage(
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
    if (allowNext) {
      action = () async {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        await pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
        );
      };
    }

    // Create the icon
    final Widget icon = ElevatedButton.icon(
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
            allowNext: enableNext,
            showNextButton: showNext,
          ),
        ),
      ],
    );
  }
}
