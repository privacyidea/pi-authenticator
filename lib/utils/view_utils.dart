import 'package:flutter/material.dart';

/// Shows a message to the user for a given `Duration`.
void showMessage({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 3),
}) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
