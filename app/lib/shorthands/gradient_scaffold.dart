import "package:activ8/view/widgets/back_button_app_bar.dart";
import "package:flutter/material.dart";

class GradientScaffold extends StatelessWidget {
  final Widget child;
  final LinearGradient backgroundGradient;
  final bool hasBackButton;

  final Widget? floatingActionButton;
  final Widget? title;
  final Function()? onBack;

  const GradientScaffold({
    super.key,
    required this.child,
    required this.backgroundGradient,
    this.hasBackButton = false,
    this.floatingActionButton,
    this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: (hasBackButton) ? BackButtonAppBar(title: title, onBack: onBack) : null,
      body: Container(
        color: Colors.black,
        child: Container(
          decoration: BoxDecoration(gradient: backgroundGradient),
          alignment: Alignment.center,
          child: child,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
