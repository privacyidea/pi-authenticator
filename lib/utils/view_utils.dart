import 'package:flutter/material.dart';

import 'customizations.dart';
import 'logger.dart';

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
}) {
  if (globalNavigatorKey.currentContext == null) {
    Logger.warning('globalNavigatorKey.currentContext is null');
    return Future.value(null);
  }
  return showDialog(
    context: globalNavigatorKey.currentContext!,
    builder: builder,
    useRootNavigator: false,
  );
}
