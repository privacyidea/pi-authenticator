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
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/push_request_theme.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/required_theme_extensions.dart';

void main() {
  group('Required Theme Extensions Test', () {
    test('generated themes register all required extensions', () {
      final customization = ApplicationCustomization.defaultCustomization;
      expect(
        customization.generateLightTheme().extensions.keys,
        containsAll(RequiredThemeExtensions.requiredExtensions),
      );
      expect(
        customization.generateDarkTheme().extensions.keys,
        containsAll(RequiredThemeExtensions.requiredExtensions),
      );
    });
    test('debugAssertHasRequiredExtensions passes for a generated theme', () {
      expect(
        ApplicationCustomization.defaultCustomization
            .generateLightTheme()
            .debugAssertHasRequiredExtensions(),
        isTrue,
      );
    });
    test(
      'debugAssertHasRequiredExtensions throws if an extension is missing',
      () {
        expect(
          () => ThemeData().debugAssertHasRequiredExtensions('testTheme'),
          throwsA(
            isA<FlutterError>().having(
              (error) => error.message,
              'message',
              allOf(contains('testTheme'), contains('PushRequestTheme')),
            ),
          ),
        );
      },
    );
    test(
      'debugAssertHasRequiredExtensions names only the missing extensions',
      () {
        final theme = ApplicationCustomization.defaultCustomization
            .generateLightTheme();
        final withoutPushRequestTheme = theme.copyWith(
          extensions: theme.extensions.values.where(
            (extension) => extension is! PushRequestTheme,
          ),
        );
        expect(
          withoutPushRequestTheme.debugAssertHasRequiredExtensions,
          throwsA(
            isA<FlutterError>().having(
              (error) => error.message,
              'message',
              allOf(
                contains('PushRequestTheme'),
                isNot(contains('TokenTileTheme')),
              ),
            ),
          ),
        );
      },
    );
  });
}
