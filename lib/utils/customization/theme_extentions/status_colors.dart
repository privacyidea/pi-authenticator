/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

class StatusColors extends ThemeExtension<StatusColors> {
  final Color error;
  final Color warning;
  final Color success;

  const StatusColors({
    required this.error,
    required this.warning,
    required this.success,
  });

  @override
  ThemeExtension<StatusColors> copyWith({
    Color? error,
    Color? warning,
    Color? success,
  }) =>
      StatusColors(
        error: error ?? this.error,
        warning: warning ?? this.warning,
        success: success ?? this.success,
      );

  @override
  ThemeExtension<StatusColors> lerp(covariant ThemeExtension<ThemeExtension>? other, double t) {
    if (other is StatusColors) {
      return StatusColors(
        error: Color.lerp(error, other.error, t)!,
        warning: Color.lerp(warning, other.warning, t)!,
        success: Color.lerp(success, other.success, t)!,
      );
    }
    return this;
  }
}
