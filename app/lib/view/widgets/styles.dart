import "package:flutter/material.dart";

/// Creates the [ButtonStyle] of an [ElevatedButton] with filled color and larger size
ButtonStyle filledElevatedButtonStyle(BuildContext context) => ElevatedButton.styleFrom(
      minimumSize: const Size(64, 48),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.background,
      textStyle: const TextStyle(fontSize: 16),
    );
