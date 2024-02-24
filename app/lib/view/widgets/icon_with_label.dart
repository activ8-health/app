import "package:flutter/material.dart";

class IconWithLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const IconWithLabel({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
