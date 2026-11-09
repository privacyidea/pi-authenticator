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
import 'package:flutter/material.dart';

import 'action_theme.dart';
import 'app_dimensions.dart';
import 'elevated_delete_button_theme.dart';
import 'extended_text_theme.dart';
import 'push_request_theme.dart';
import 'status_colors.dart';

extension RequiredThemeExtensions on ThemeData {
  /// The [ThemeExtension]s every generated [ThemeData] has to register.
  /// Widgets read most of them with a null check (`extension<T>()!`), so a missing
  /// registration would either throw somewhere deep inside the widget tree or -
  /// even harder to spot - let a widget silently fall back to a default color.
  static const requiredExtensions = <Type>[
    AppDimensions,
    ElevatedDeleteButtonTheme,
    ExtendedTextTheme,
    PushRequestTheme,
    StatusColors,
    TokenTileTheme,
  ];

  /// Throws if any of the [requiredExtensions] is not registered.
  /// Meant to be called inside an `assert(...)` while a [ThemeData] is generated,
  /// so a missing extension surfaces at app start in debug builds and the check
  /// is stripped from release builds. Always returns true.
  bool debugAssertHasRequiredExtensions([String? themeName]) {
    final missing = requiredExtensions
        .where((type) => !extensions.containsKey(type))
        .toList();
    if (missing.isNotEmpty) {
      throw FlutterError(
        'ThemeData${themeName != null ? ' ($themeName)' : ''} is missing the '
        'required ThemeExtension${missing.length > 1 ? 's' : ''}: '
        '${missing.join(', ')}.\n'
        'Add them to the extensions of ThemeCustomization.generateTheme.',
      );
    }
    return true;
  }
}
