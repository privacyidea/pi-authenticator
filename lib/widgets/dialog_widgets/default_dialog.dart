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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/customization/theme_extentions/app_dimensions.dart';
import '../button_widgets/intent_button.dart';
import '../button_widgets/time_guarded_button.dart';

export '../button_widgets/intent_button.dart' show DialogActionIntent;

class DialogAction {
  final String label;
  final FutureOr<void> Function()? onPressed;
  final int delaySeconds;
  final int cooldownMs;
  final GlobalKey<FormState>? formState;
  final DialogActionIntent intent;

  DialogAction({
    required this.label,
    required this.intent,
    this.onPressed,
    this.delaySeconds = 0,
    this.cooldownMs = 0,
    this.formState,
  });

  // Determines if this action requires the TimeGuardedButton logic
  bool get isTimed => delaySeconds > 0 || cooldownMs > 0;
}

class DefaultDialog extends ConsumerWidget {
  final bool? scrollable;
  final Widget? title;
  final List<DialogAction> actions;
  final MainAxisAlignment? actionsAlignment;
  final Widget? content;
  final bool hasCloseButton;
  final double closeButtonSize;

  const DefaultDialog({
    this.scrollable,
    this.title,
    this.actions = const [],
    this.actionsAlignment,
    this.content,
    this.hasCloseButton = false,
    this.closeButtonSize = 22,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dimensions =
        Theme.of(context).extension<AppDimensions>() ?? const AppDimensions();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: dimensions.strokeWidth,
        ),
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
      ),
      actionsAlignment: actionsAlignment ?? MainAxisAlignment.end,
      scrollable: scrollable ?? false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      actionsPadding: EdgeInsets.fromLTRB(
        dimensions.spacingSmall,
        0,
        dimensions.spacingSmall,
        dimensions.spacingSmall,
      ),
      buttonPadding: EdgeInsets.symmetric(
        horizontal: dimensions.spacingSmall / 2,
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: dimensions.screenPadding,
        vertical: dimensions.spacingLarge,
      ),
      titlePadding: EdgeInsets.all(dimensions.spacingMedium),
      contentPadding: EdgeInsets.fromLTRB(
        dimensions.spacingMedium,
        0,
        dimensions.spacingMedium,
        dimensions.spacingSmall,
      ),
      elevation: 2,
      title: Row(
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.titleLarge!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              child: title ?? const SizedBox(),
            ),
          ),
          if (hasCloseButton)
            IconButton(
              icon: Icon(Icons.close, size: closeButtonSize),
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
      ),
      actions: _mapActions(actions),
      content: Padding(
        padding: EdgeInsets.symmetric(vertical: dimensions.spacingSmall),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyLarge!,
          child: content ?? const SizedBox(),
        ),
      ),
    );
  }

  List<StatefulWidget> _mapActions(List<DialogAction> actions) {
    final sortedActions = [...actions]
      ..sort((a, b) => a.intent.priority.compareTo(b.intent.priority));

    return sortedActions.map((action) {
      if (action.isTimed) {
        return TimeGuardedButton(
          intent: action.intent,
          onPressed: action.onPressed,
          delaySeconds: action.delaySeconds,
          cooldownMs: action.cooldownMs,
          child: Text(action.label),
        );
      }
      return IntentButton(
        intent: action.intent,
        onPressed: action.onPressed,
        child: Text(action.label),
      );
    }).toList();
  }
}
