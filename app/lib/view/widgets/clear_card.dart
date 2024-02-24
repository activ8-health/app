import "package:activ8/constants.dart";
import "package:flutter/material.dart";

class ClearCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final double backgroundOpacity;
  final double borderOpacity;
  final double borderWidth;
  final EdgeInsets padding;

  const ClearCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.backgroundOpacity = 0.12,
    this.borderOpacity = 0.6,
    this.borderWidth = 1,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(backgroundOpacity),
        borderRadius: homeCardBorderRadius,
        border: Border.all(
          color: color.withOpacity(borderOpacity),
          width: borderWidth,
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}
