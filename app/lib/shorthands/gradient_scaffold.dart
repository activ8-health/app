import "package:activ8/view/widgets/back_button_app_bar.dart";
import "package:flutter/material.dart";

class GradientScaffold extends StatelessWidget {
  final Widget child;
  final LinearGradient backgroundGradient;
  final bool hasBackButton;

  const GradientScaffold({
    super.key,
    required this.child,
    required this.backgroundGradient,
    this.hasBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: (hasBackButton) ? const BackButtonAppBar() : null,
      body: Container(
        color: Colors.black,
        child: Container(
          decoration: BoxDecoration(gradient: backgroundGradient),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
