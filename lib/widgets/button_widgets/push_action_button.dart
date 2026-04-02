/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2026 NetKnights GmbH
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

import 'dart:async';

import 'package:flutter/material.dart';

import 'intent_button.dart';

/// A specialized button for Push Notification actions with a distinct border and typography.
/// Uses [IntentButton] to handle asynchronous execution and a minimum threshold to prevent double-taps.
class PushActionButton extends StatelessWidget {
  final FutureOr<void> Function()? onPressed;
  final Widget child;
  // final double height;
  final ActionIntent intent;

  /// Minimum time in milliseconds between button presses to prevent double-taps.
  final int minThreshold;

  const PushActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.minThreshold = 1000,
    this.intent = ActionIntent.confirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntentButton(
      intent: intent,
      onPressed: onPressed,
      cooldownMs: minThreshold,
      child: Center(
        child: DefaultTextStyle.merge(
          style: theme.textTheme.headlineSmall?.copyWith(
            color: onPressed == null
                ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                : theme.colorScheme.onPrimary,
          ),
          child: child,
        ),
      ),
    );
  }
}
