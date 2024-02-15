import 'package:activ8/constants.dart';
import 'package:flutter/material.dart';

class ClearCard extends StatelessWidget {
  final Widget child;
  final Color color;

  const ClearCard({
    super.key,
    required this.child,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: homeCardBorderRadius,
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: child,
    );
  }
}
