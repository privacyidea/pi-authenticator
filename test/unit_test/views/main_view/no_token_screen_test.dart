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
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/no_token_screen.dart';

/// Phone portrait, where the title fills the width, and tablet landscape,
/// where the start of the hint would fit next to the title.
const _screens = {
  'phone': (physicalSize: Size(1080, 2400), devicePixelRatio: 2.625),
  'tablet': (physicalSize: Size(2560, 1600), devicePixelRatio: 2.0),
};

Future<AppLocalizations> _pumpScreen(
  WidgetTester tester,
  Locale locale,
  ({Size physicalSize, double devicePixelRatio}) screen,
) async {
  tester.view.physicalSize = screen.physicalSize;
  tester.view.devicePixelRatio = screen.devicePixelRatio;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: NoTokenScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return AppLocalizations.of(tester.element(find.byType(NoTokenScreen)))!;
}

void main() {
  group('NoTokenScreen', () {
    for (final MapEntry(key: screenName, value: screen) in _screens.entries) {
      for (final locale in AppLocalizations.supportedLocales) {
        testWidgets(
          'puts the hint on one line below the title ($locale, $screenName)',
          (tester) async {
            final l10n = await _pumpScreen(tester, locale, screen);

            final title = tester.getRect(find.text(l10n.noResultTitle));
            final start = tester.getRect(find.text(l10n.noResultText1));
            final icon = tester.getRect(
              find.byIcon(Icons.qr_code_scanner_outlined),
            );
            final end = tester.getRect(find.text(l10n.noResultText2));

            expect(start.top, greaterThanOrEqualTo(title.bottom));
            expect(end.top, moreOrLessEquals(start.top));
            expect(end.height, moreOrLessEquals(start.height));
            expect(icon.left, greaterThanOrEqualTo(start.right - 0.01));
            expect(end.left, greaterThanOrEqualTo(icon.right - 0.01));
            expect(
              icon.center.dy,
              moreOrLessEquals(start.center.dy, epsilon: 0.5),
            );
          },
        );

        testWidgets('centers the title and the hint ($locale, $screenName)', (
          tester,
        ) async {
          final l10n = await _pumpScreen(tester, locale, screen);

          final screenCenter = tester
              .getRect(find.byType(NoTokenScreen))
              .center
              .dx;
          final title = tester.getRect(find.text(l10n.noResultTitle));
          final start = tester.getRect(find.text(l10n.noResultText1));
          final end = tester.getRect(find.text(l10n.noResultText2));

          expect(title.center.dx, moreOrLessEquals(screenCenter, epsilon: 0.5));
          expect(
            (start.left + end.right) / 2,
            moreOrLessEquals(screenCenter, epsilon: 0.5),
          );
        });
      }
    }
  });
}
