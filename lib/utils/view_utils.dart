/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/material.dart';

import 'globals.dart';
import 'logger.dart';
import 'riverpod/riverpod_providers/state_providers/status_message_provider.dart';

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

void showStatusMessage({required String message, String? subMessage}) {
  final ref = globalRef;
  Logger.warning('$message : $subMessage');
  if (ref == null) {
    Logger.error('Could not show status message: globalRef is null');
    return;
  }
  ref.read(statusMessageProvider.notifier).state = (message, subMessage);
}

Future<T?> showAsyncDialog<T>({
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  if (globalContextSync == null) {
    Logger.error('globalContextSync is null');
    return Future.value(null);
  }
  return showDialog<T>(
    context: globalContextSync!,
    builder: builder,
    useRootNavigator: false,
    barrierDismissible: barrierDismissible,
  );
}
