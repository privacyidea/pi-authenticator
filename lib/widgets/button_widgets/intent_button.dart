/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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
/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
 */

import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/customization/theme_extentions/app_dimensions.dart';

extension DialogActionIntentX on DialogActionIntent {
  int get priority {
    return switch (this) {
      DialogActionIntent.cancel || DialogActionIntent.neutral => 1,
      DialogActionIntent.external => 2,
      DialogActionIntent.info => 3,
      DialogActionIntent.confirm || DialogActionIntent.destructive => 4,
    };
  }
}

enum DialogActionIntent {
  confirm,
  destructive,
  info,
  neutral,
  cancel,
  external,
}

class IntentButton extends StatefulWidget {
  final DialogActionIntent intent;
  final FutureOr<void> Function()? onPressed;
  final Widget child;

  const IntentButton({
    super.key,
    required this.intent,
    required this.onPressed,
    required this.child,
  });

  @override
  State<IntentButton> createState() => _IntentButtonState();
}

class _IntentButtonState extends State<IntentButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return switch (widget.intent) {
      DialogActionIntent.confirm ||
      DialogActionIntent.destructive => _buildElevatedButton(context),
      DialogActionIntent.info => _buildOutlinedButton(context),
      DialogActionIntent.neutral ||
      DialogActionIntent.cancel ||
      DialogActionIntent.external => _buildTextButton(context),
    };
  }

  @override
  void dispose() {
    _isLoading = false;
    super.dispose();
  }

  FutureOr<void> Function()? get effectiveOnPressed {
    if (widget.onPressed == null) return null;

    return () async {
      try {
        final futureOr = widget.onPressed!();
        if (futureOr is Future) {
          setState(() => _isLoading = true);
          await futureOr;
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    };
  }

  Widget _buildElevatedButton(BuildContext context) {
    final theme = Theme.of(context);
    final dimensions =
        theme.extension<AppDimensions>() ?? const AppDimensions();
    final isDestructive = widget.intent == DialogActionIntent.destructive;

    return ElevatedButton(
      onPressed: effectiveOnPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive ? theme.colorScheme.error : null,
        foregroundColor: isDestructive ? theme.colorScheme.onError : null,
        disabledBackgroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.12,
        ),
        disabledForegroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.38,
        ),
        minimumSize: Size(0, dimensions.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
        ),
      ),
      child: _buildChildWithLoading(),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    final theme = Theme.of(context);
    final dimensions =
        theme.extension<AppDimensions>() ?? const AppDimensions();

    return OutlinedButton(
      onPressed: effectiveOnPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, dimensions.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        disabledForegroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.38,
        ),
        side: BorderSide(
          color: effectiveOnPressed == null
              ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
              : theme.dividerColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
        ),
      ),
      child: _buildChildWithLoading(),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    final theme = Theme.of(context);
    final dimensions =
        theme.extension<AppDimensions>() ?? const AppDimensions();

    return TextButton(
      onPressed: effectiveOnPressed,
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        minimumSize: Size(0, dimensions.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        disabledForegroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.38,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
        ),
      ),
      child: widget.intent == DialogActionIntent.external
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildChildWithLoading(),
                const SizedBox(width: 4),
                Icon(
                  Icons.open_in_new,
                  size: 16,
                  // Icon passt sich automatisch der Vordergrundfarbe an,
                  // außer im disabled State
                  color: effectiveOnPressed == null
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                      : theme.colorScheme.onSurface,
                ),
              ],
            )
          : _buildChildWithLoading(),
    );
  }

  Widget _buildChildWithLoading() {
    if (!_isLoading) return widget.child;

    return const SizedBox(
      height: 16,
      width: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
