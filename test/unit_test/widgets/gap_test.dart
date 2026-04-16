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
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/app_dimensions.dart';
import 'package:privacyidea_authenticator/widgets/gap.dart';

import '../../tests_app_wrapper.dart';

void main() {
  group('Gap Widget Tests', () {
    testWidgets('uses explicit size when provided', (tester) async {
      const double customSize = 24.0;
      await tester.pumpWidget(
        const TestsAppWrapper(child: Gap(size: customSize)),
      );
      final SizedBox sizedBox = tester.widget(find.byType(SizedBox));
      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);
    });

    testWidgets('uses spacingSmall from AppDimensions theme extension', (
      tester,
    ) async {
      const double themeSpacing = 12.0;

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [],
          child: Builder(
            builder: (context) {
              return Theme(
                data: ThemeData.light().copyWith(
                  extensions: [AppDimensions(spacingSmall: themeSpacing)],
                ),
                child: const Gap(),
              );
            },
          ),
        ),
      );

      final SizedBox sizedBox = tester.widget(find.byType(SizedBox));
      expect(sizedBox.width, themeSpacing);
      expect(sizedBox.height, themeSpacing);
    });

    testWidgets(
      'defaults to 8.0 when no size and no theme extension are present',
      (tester) async {
        await tester.pumpWidget(
          Theme(
            data: ThemeData.light(),
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: Gap(),
            ),
          ),
        );

        final SizedBox sizedBox = tester.widget(find.byType(SizedBox));
        expect(sizedBox.width, 8.0);
        expect(sizedBox.height, 8.0);
      },
    );
  });
}
