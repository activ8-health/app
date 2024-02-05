import 'package:flutter/material.dart';

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
          late bool isEmpty = value == null || value.isEmpty;
          late bool isBadInteger = inputType == TextInputType.number && int.tryParse(value ?? "") == null;
          late bool isBadDouble =
              inputType == const TextInputType.numberWithOptions(decimal: true) && double.tryParse(value ?? "") == null;
          late bool isInvalidWithCustomValidator = validator != null && !(validator!)(value ?? "");

          if (isEmpty || isBadInteger || isBadDouble || isInvalidWithCustomValidator) {
            return "";
          }

          return null;
        },
      ),
    );
  }
}

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
