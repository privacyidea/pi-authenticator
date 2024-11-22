import 'package:flutter/material.dart';

import 'globals.dart';
import 'logger.dart';

/// Shows a snackbar message to the user for 3 seconds.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar(String message) => _showSnackBar(message, const Duration(seconds: 3));

/// Shows a snackbar message to the user for 10 seconds.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBarLong(String message) => _showSnackBar(message, const Duration(seconds: 10));

/// Shows a snackbar message to the user for a given `Duration`.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _showSnackBar(
  String message,
  Duration duration,
) {
  if (globalSnackbarKey.currentState == null) {
    Logger.warning('globalSnackbarKey.currentState is null');
    return null;
  }
  return globalSnackbarKey.currentState!.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      duration: const Duration(seconds: 5),
    ),
  );
}

/// Shows a snackbar message to the user for a given `Duration`.
void showMessage({
  required String message,
  Duration duration = const Duration(seconds: 5),
}) {
  if (globalSnackbarKey.currentState == null) {
    Logger.warning('globalSnackbarKey.currentState is null');
    return;
  }
  globalSnackbarKey.currentState!.showSnackBar(
    SnackBar(content: Text(message), duration: duration),
  );
}

Future<T?> showAsyncDialog<T>({
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  if (globalContextSync == null) {
    Logger.error('globalContextSync is null');
    return Future.value(null);
  }
  return showDialog(
    context: globalContextSync!,
    builder: builder,
    useRootNavigator: false,
    barrierDismissible: barrierDismissible,
  );
}
