import "package:flutter/material.dart";

class CheckableEntry extends StatefulWidget {
  final Widget child;
  final Function(bool) onChanged;
  final bool value;
  final BorderRadius borderRadius;

  const CheckableEntry({
    super.key,
    required this.child,
    required this.onChanged,
    this.value = false,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<CheckableEntry> createState() => _CheckableEntryState();
}

class _CheckableEntryState extends State<CheckableEntry> {
  late bool checked = widget.value;

  /// Change the state of this entry to [newState]
  void _onChanged(bool newState) {
    checked = newState;
    widget.onChanged(checked);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    if (checked) {
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.2);
    } else {
      backgroundColor = Colors.white.withOpacity(0.08);
    }

    return InkWell(
      onTap: () => _onChanged(!checked),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: widget.borderRadius,
        ),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: (bool? value) => _onChanged(value ?? checked),
            ),
            Expanded(
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium!,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
