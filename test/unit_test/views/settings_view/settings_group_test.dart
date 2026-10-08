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
import 'package:privacyidea_authenticator/views/settings_view/settings_view_widgets/settings_group.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';

import '../../../tests_app_wrapper.dart';

void main() {
  Future<void> pumpGroup(
    WidgetTester tester, {
    bool isActive = true,
    VoidCallback? onPressed,
    IconData? trailingIcon,
    Widget? trailingWidget,
    List<Widget> children = const [],
  }) async {
    await tester.pumpWidget(
      TestsAppWrapper(
        child: SettingsGroup(
          title: 'Group title',
          isActive: isActive,
          onPressed: onPressed,
          trailingIcon: trailingIcon,
          trailingWidget: trailingWidget,
          children: children,
        ),
      ),
    );
    await tester.pump();
  }

  Color? titleColor(WidgetTester tester) =>
      tester.widget<Text>(find.text('Group title')).style?.color;

  ListTile tile(WidgetTester tester) =>
      tester.widget<ListTile>(find.byType(ListTile));

  group('SettingsGroup active', () {
    testWidgets('tapping the row calls onPressed once', (tester) async {
      var calls = 0;
      await pumpGroup(tester, onPressed: () => calls++);

      await tester.tap(find.text('Group title'));
      await tester.pump();

      expect(calls, 1);
    });

    testWidgets('tapping the trailing button calls onPressed once', (
      tester,
    ) async {
      var calls = 0;
      await pumpGroup(tester, onPressed: () => calls++);

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(calls, 1);
    });

    testWidgets('shows the default arrow when no trailing icon is given', (
      tester,
    ) async {
      await pumpGroup(tester, onPressed: () {});

      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('shows the given trailing icon instead of the arrow', (
      tester,
    ) async {
      await pumpGroup(tester, onPressed: () {}, trailingIcon: Icons.language);

      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
    });

    testWidgets('does not grey the title', (tester) async {
      await pumpGroup(tester, onPressed: () {});

      expect(titleColor(tester), isNot(Colors.grey));
    });

    testWidgets('tapping the row also works with a trailing widget', (
      tester,
    ) async {
      var calls = 0;
      await pumpGroup(
        tester,
        onPressed: () => calls++,
        trailingWidget: const Text('trailing'),
      );

      expect(find.text('trailing'), findsOneWidget);
      expect(find.byType(IntentButton), findsNothing);

      await tester.tap(find.text('trailing'));
      await tester.pump();

      expect(calls, 1);
    });

    testWidgets('shows the children below the title', (tester) async {
      await pumpGroup(
        tester,
        onPressed: () {},
        children: const [Text('child one'), Text('child two')],
      );

      expect(find.text('child one'), findsOneWidget);
      expect(find.text('child two'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('child one')).dy,
        greaterThan(tester.getBottomLeft(find.text('Group title')).dy),
      );
    });
  });

  group('SettingsGroup inactive', () {
    testWidgets('tapping the row does not call onPressed', (tester) async {
      var calls = 0;
      await pumpGroup(tester, isActive: false, onPressed: () => calls++);

      expect(tile(tester).onTap, isNull);
      await tester.tap(find.text('Group title'));
      await tester.pump();

      expect(calls, 0);
    });

    testWidgets('tapping the trailing button does not call onPressed', (
      tester,
    ) async {
      var calls = 0;
      await pumpGroup(tester, isActive: false, onPressed: () => calls++);

      expect(
        tester.widget<IconButton>(find.byType(IconButton)).onPressed,
        isNull,
      );
      await tester.tap(find.byType(IconButton), warnIfMissed: false);
      await tester.pump();

      expect(calls, 0);
    });

    testWidgets('the trailing button is disabled, not removed', (tester) async {
      await pumpGroup(
        tester,
        isActive: false,
        onPressed: () {},
        trailingIcon: Icons.notifications,
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(
        tester.widget<IconButton>(find.byType(IconButton)).onPressed,
        isNull,
      );
    });

    testWidgets('greys the title', (tester) async {
      await pumpGroup(tester, isActive: false, onPressed: () {});

      expect(titleColor(tester), Colors.grey);
    });

    testWidgets('greys the title without onPressed as well', (tester) async {
      await pumpGroup(tester, isActive: false);

      expect(titleColor(tester), Colors.grey);
    });

    testWidgets(
      'tapping the row does not call onPressed with a trailing widget',
      (tester) async {
        var calls = 0;
        await pumpGroup(
          tester,
          isActive: false,
          onPressed: () => calls++,
          trailingWidget: const Text('trailing'),
        );

        expect(tile(tester).onTap, isNull);
        await tester.tap(find.text('Group title'));
        await tester.tap(find.text('trailing'));
        await tester.pump();

        expect(calls, 0);
      },
    );

    testWidgets('still shows the children', (tester) async {
      await pumpGroup(
        tester,
        isActive: false,
        onPressed: () {},
        children: const [Text('child one')],
      );

      expect(find.text('child one'), findsOneWidget);
    });

    testWidgets('becomes tappable again when it is activated', (tester) async {
      var calls = 0;
      await pumpGroup(tester, isActive: false, onPressed: () => calls++);
      await tester.tap(find.text('Group title'));
      await tester.pump();
      expect(calls, 0);

      await pumpGroup(tester, onPressed: () => calls++);
      await tester.tap(find.text('Group title'));
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(calls, 2);
      expect(titleColor(tester), isNot(Colors.grey));
    });
  });

  group('SettingsGroup without onPressed', () {
    testWidgets('is not tappable and has no trailing button', (tester) async {
      await pumpGroup(tester, trailingIcon: Icons.language);

      expect(tile(tester).onTap, isNull);
      expect(find.byType(IconButton), findsNothing);
      expect(find.text('Group title'), findsOneWidget);
    });
  });

  group('SettingsGroup arguments', () {
    test('rejects a trailing icon together with a trailing widget', () {
      expect(
        () => SettingsGroup(
          title: 'x',
          trailingIcon: Icons.language,
          trailingWidget: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });
  });
}
