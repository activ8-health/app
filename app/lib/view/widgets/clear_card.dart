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
    return ClipRRect(
      borderRadius: homeCardBorderRadius,
      child: Material(
        color: Colors.transparent,
        child: Container(
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
        ),
      ),
    );
  }
}

class ClearCardDivider extends StatelessWidget {
  static const double _dividerIndent = 15;

  const ClearCardDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.white.withOpacity(0.6),
      thickness: 1,
      indent: _dividerIndent,
      height: 0,
      endIndent: _dividerIndent,
    );
  }
}
