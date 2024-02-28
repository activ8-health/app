import "package:activ8/constants.dart";
import "package:flutter/material.dart";

class LargeIcon extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final Widget? child;

  const LargeIcon({
    super.key,
    this.icon,
    this.child,
    this.color,
  })  : assert((icon == null) != (child == null), "Either icon or child must be provided, but not both"),
        assert((icon != null) == (color != null), "If icon is provided, color must be provided");

  @override
  Widget build(BuildContext context) {
    final Widget childWidget = (child != null) ? child! : Icon(icon, size: 72);
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        borderRadius: largeIconBorderRadius,
        color: color,
      ),
      child: ClipRRect(
        borderRadius: largeIconBorderRadius,
        child: childWidget,
      ),
    );
  }
}
