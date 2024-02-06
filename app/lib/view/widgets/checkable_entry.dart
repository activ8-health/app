import 'package:flutter/material.dart';

class CheckableEntry extends StatefulWidget {
  final String label;
  final Function(bool) onChanged;
  final bool value;
  final BorderRadius borderRadius;

  const CheckableEntry({
    super.key,
    required this.label,
    required this.onChanged,
    this.value = false,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<CheckableEntry> createState() => _CheckableEntryState();
}

class _CheckableEntryState extends State<CheckableEntry> {
  late bool value;

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  void onChanged(bool value) {
    this.value = value;
    widget.onChanged(this.value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        value ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.white.withOpacity(0.08);

    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: widget.borderRadius,
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (bool? value) => onChanged(value ?? this.value),
            ),
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
