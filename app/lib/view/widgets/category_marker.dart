import "package:flutter/material.dart";

/// The small text above each section
class CategoryMarker extends StatelessWidget {
  final String label;

  const CategoryMarker({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: Colors.white.withOpacity(0.5),
        );

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24.0, bottom: 2.0),
      child: Text(
        label,
        style: textStyle,
      ),
    );
  }
}
