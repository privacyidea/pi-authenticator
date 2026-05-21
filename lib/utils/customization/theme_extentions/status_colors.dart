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
  final Color success;
  final Color warning;
  final Color error;
  final Color neutral;

  const StatusColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.neutral,
  });

  @override
  ThemeExtension<StatusColors> copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? neutral,
  }) => StatusColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    neutral: neutral ?? this.neutral,
  );

  @override
  ThemeExtension<StatusColors> lerp(
    covariant ThemeExtension<ThemeExtension>? other,
    double t,
  ) {
    if (other is StatusColors) {
      return StatusColors(
        success: Color.lerp(success, other.success, t)!,
        warning: Color.lerp(warning, other.warning, t)!,
        error: Color.lerp(error, other.error, t)!,
        neutral: Color.lerp(neutral, other.neutral, t)!,
      );
    }
    return this;
  }
}
