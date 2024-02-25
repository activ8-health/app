import "package:flutter/material.dart";

/// A [TextFormField] with default styling and validation logic
class CustomTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final Function(String) onChanged;
  final TextInputType inputType;

  // Optional parameters
  final String? suffix;
  final bool Function(String)? validator;
  final bool obscureText;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,

    // Optional parameters
    this.inputType = TextInputType.text,
    this.suffix,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        decoration: createInputDecoration(context, label, suffix: suffix),
        initialValue: initialValue,
        autocorrect: false,
        keyboardType: inputType,
        obscureText: obscureText,
        readOnly: readOnly,
        onChanged: onChanged,
        validator: (String? value) {
          // Conditions to check
          late final bool isEmpty = value == null || value.isEmpty;
          late final bool isInteger = inputType == TextInputType.number;
          late final bool isBadInteger = isInteger && int.tryParse(value ?? "") == null;
          late final bool isDouble = inputType == const TextInputType.numberWithOptions(decimal: true);
          late final bool isBadDouble = isDouble && double.tryParse(value ?? "") == null;
          late final bool isInvalidWithCustomValidator = validator != null && !(validator!)(value ?? "");

          final bool bad = isEmpty || isBadInteger || isBadDouble || isInvalidWithCustomValidator;

          if (bad) return "";
          return null;
        },
      ),
    );
  }
}

/// Creates a custom [InputDecoration] for the [CustomTextField]
InputDecoration createInputDecoration(context, String label, {String? suffix}) {
  return InputDecoration(
    labelText: label,
    suffix: (suffix == null) ? null : Text(suffix),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    errorStyle: const TextStyle(height: 0),
    filled: true,
    fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.07),
  );
}
