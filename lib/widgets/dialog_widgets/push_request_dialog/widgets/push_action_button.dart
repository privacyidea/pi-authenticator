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
import 'package:flutter/material.dart';

import '../../../button_widgets/cooldown_button.dart';

class PushActionButton extends StatelessWidget {
  final Future<void> Function() onPressed;
  final Widget child;
  final Color backgroundColor;
  final double? height;
  final OutlinedBorder? shape;
  final bool isDisabled; // Neues Feld

  const PushActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
    this.height,
    this.shape,
    this.isDisabled = false, // Standardmäßig false
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        // Rahmenfarbe wird bei disabled ebenfalls angepasst
        color: isDisabled ? theme.disabledColor : theme.colorScheme.onPrimary,
        width: 2.5,
      ),
    );

    return CooldownButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          isDisabled ? theme.disabledColor : backgroundColor,
        ),
        shape: WidgetStateProperty.all(shape ?? defaultShape),
      ),
      // Wenn isDisabled true ist, wird null übergeben, was den Button deaktiviert
      onPressed: isDisabled ? null : onPressed,
      child: SizedBox(
        height: height,
        child: Center(
          child: DefaultTextStyle.merge(
            style: theme.textTheme.headlineSmall?.copyWith(
              // Textfarbe bei disabled optional anpassen
              color: isDisabled
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
