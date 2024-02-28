import "dart:ui";

import "package:flutter/material.dart";

class BlurUnder extends StatelessWidget {
  final Widget child;
  final double strength;

  const BlurUnder({super.key, required this.child, this.strength = 4});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: strength,
          sigmaY: strength,
        ),
        child: child,
      ),
    );
  }
}
