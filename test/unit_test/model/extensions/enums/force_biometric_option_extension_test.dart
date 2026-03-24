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

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/force_biometric_option_extension.dart';

void main() {
  group('ForceBiometricOptionX Tests', () {
    test('fromString parses valid strings case-insensitively', () {
      expect(
        ForceBiometricOptionX.fromString('none'),
        ForceBiometricOption.none,
      );
      expect(
        ForceBiometricOptionX.fromString('NONE'),
        ForceBiometricOption.none,
      );
      expect(ForceBiometricOptionX.fromString('any'), ForceBiometricOption.any);
    });

    test('fromString returns null for null input', () {
      expect(ForceBiometricOptionX.fromString(null), isNull);
    });

    test('fromString throws ArgumentError for invalid string', () {
      expect(
        () => ForceBiometricOptionX.fromString('invalid'),
        throwsArgumentError,
      );
    });

    test('validator transformer handles ForceBiometricOption type', () {
      final result = ForceBiometricOptionX.validator.transformer!(
        ForceBiometricOption.any,
      );
      expect(result, ForceBiometricOption.any);
    });

    test('validator transformer handles String type', () {
      final result = ForceBiometricOptionX.validator.transformer!('any');
      expect(result, ForceBiometricOption.any);
    });

    test(
      'validator transformer throws ArgumentError for unsupported types',
      () {
        expect(
          () => ForceBiometricOptionX.validator.transformer!(123),
          throwsArgumentError,
        );
        expect(
          () => ForceBiometricOptionX.validator.transformer!(true),
          throwsArgumentError,
        );
      },
    );

    test('validator uses defaultValue for null input', () {
      expect(
        ForceBiometricOptionX.validator.transform(null, 'TestField'),
        ForceBiometricOption.none,
      );
    });
  });
}
