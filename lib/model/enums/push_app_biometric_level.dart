/*
 * privacyIDEA Authenticator
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

import '../../utils/logger.dart';
import '../../utils/object_validator/object_validators.dart';

/// Biometric class requested by a privacyIDEA Push enrollment policy.
enum PushAppBiometricLevel { any, strong }

extension PushAppBiometricLevelX on PushAppBiometricLevel {
  static final validator = DefaultObjectValidator<PushAppBiometricLevel>(
    defaultValue: PushAppBiometricLevel.any,
    transformer: (value) {
      if (value is PushAppBiometricLevel) return value;
      final name = value.toString().split('.').last.toLowerCase();
      final level = PushAppBiometricLevel.values
          .where((candidate) => candidate.name == name)
          .firstOrNull;
      if (level == null) {
        Logger.warning('Unknown Push biometric level: $value');
        throw ArgumentError.value(value, 'push_app_biometric_level');
      }
      return level;
    },
  );
}
