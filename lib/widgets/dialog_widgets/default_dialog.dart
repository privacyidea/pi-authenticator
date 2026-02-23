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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/riverpod/riverpod_providers/generated_providers/messenger_stack.dart';

class DefaultDialog extends ConsumerWidget {
  final bool? scrollable;
  final Widget? title;
  final List<Widget>? actions;
  final MainAxisAlignment? actionsAlignment;
  final Widget? content;
  final bool hasCloseButton;
  final double closeButtonSize;

  const DefaultDialog({
    this.scrollable,
    this.title,
    this.actions,
    this.actionsAlignment,
    this.content,
    this.hasCloseButton = false,
    this.closeButtonSize = 22,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(color: Colors.transparent),
          ),
        ),
        ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Builder(
              builder: (dialogContext) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(messengerStackProvider.notifier).push(dialogContext);
                });

                return PopScope(
                  onPopInvokedWithResult: (didPop, result) {
                    if (didPop) {
                      ref
                          .read(messengerStackProvider.notifier)
                          .pop(dialogContext);
                    }
                  },
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    actionsAlignment: actionsAlignment ?? MainAxisAlignment.end,
                    scrollable: scrollable ?? false,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    buttonPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    insetPadding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
                    titlePadding: const EdgeInsets.all(10),
                    contentPadding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
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
                    actions: actions,
                    content: DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyLarge!,
                      child: content ?? const SizedBox(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
