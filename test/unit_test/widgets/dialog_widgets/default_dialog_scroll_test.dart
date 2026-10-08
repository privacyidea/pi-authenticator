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
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../tests_app_wrapper.dart';

const _lineCount = 60;

Widget _longContent() => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [for (var i = 0; i < _lineCount; i++) Text('Line $i')],
);

List<DialogAction> _actions({VoidCallback? onConfirm}) => [
  DialogAction(
    label: 'Confirm',
    intent: ActionIntent.confirm,
    onPressed: onConfirm,
  ),
  DialogAction(label: 'Cancel', intent: ActionIntent.cancel, onPressed: () {}),
];

void main() {
  setUpAll(() async {
    await setupMocks();
  });

  void setScreen(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> showDialogOf(WidgetTester tester, Widget dialog) async {
    await tester.pumpWidget(
      TestsAppWrapper(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showDialog<void>(context: context, builder: (_) => dialog),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Rect screenOf(WidgetTester tester) =>
      Offset.zero & tester.view.physicalSize / tester.view.devicePixelRatio;

  void expectFullyOnScreen(WidgetTester tester, Finder finder) {
    expect(finder, findsOneWidget);
    final rect = tester.getRect(finder);
    final screen = screenOf(tester);
    expect(rect.top, greaterThanOrEqualTo(screen.top), reason: '$finder top');
    expect(
      rect.bottom,
      lessThanOrEqualTo(screen.bottom),
      reason: '$finder bottom',
    );
    expect(
      rect.left,
      greaterThanOrEqualTo(screen.left),
      reason: '$finder left',
    );
    expect(
      rect.right,
      lessThanOrEqualTo(screen.right),
      reason: '$finder right',
    );
  }

  ScrollableState scrollable(WidgetTester tester) =>
      tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(DefaultDialog),
          matching: find.byType(Scrollable),
        ),
      );

  group('DefaultDialog with scrollable content (default)', () {
    for (final size in const [Size(320, 480), Size(480, 320)]) {
      final label = '${size.width.toInt()}x${size.height.toInt()}';

      testWidgets('long content scrolls and nothing overflows at $label', (
        tester,
      ) async {
        setScreen(tester, size);
        await showDialogOf(
          tester,
          DefaultDialog(
            title: const Text('Dialog title'),
            content: _longContent(),
            actions: _actions(),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(scrollable(tester).position.maxScrollExtent, greaterThan(0));
        expect(find.text('Line 0'), findsOneWidget);
        expect(
          find.text('Line ${_lineCount - 1}').hitTestable(),
          findsNothing,
          reason: 'the last line is only reachable by scrolling',
        );
      });

      testWidgets('title and actions stay visible while scrolling at $label', (
        tester,
      ) async {
        setScreen(tester, size);
        await showDialogOf(
          tester,
          DefaultDialog(
            title: const Text('Dialog title'),
            content: _longContent(),
            actions: _actions(),
          ),
        );
        final titleBefore = tester.getRect(find.text('Dialog title'));
        final confirmBefore = tester.getRect(
          find.widgetWithText(IntentButton, 'Confirm'),
        );

        expectFullyOnScreen(tester, find.text('Dialog title'));
        expectFullyOnScreen(
          tester,
          find.widgetWithText(IntentButton, 'Confirm'),
        );
        expectFullyOnScreen(
          tester,
          find.widgetWithText(IntentButton, 'Cancel'),
        );

        await tester.drag(find.text('Line 0'), const Offset(0, -2000));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Line 0').hitTestable(), findsNothing);
        expect(
          find.text('Line ${_lineCount - 1}').hitTestable(),
          findsOneWidget,
        );
        expect(tester.getRect(find.text('Dialog title')), titleBefore);
        expect(
          tester.getRect(find.widgetWithText(IntentButton, 'Confirm')),
          confirmBefore,
        );
        expectFullyOnScreen(tester, find.text('Dialog title'));
        expectFullyOnScreen(
          tester,
          find.widgetWithText(IntentButton, 'Confirm'),
        );
      });

      testWidgets('the actions stay tappable after scrolling at $label', (
        tester,
      ) async {
        setScreen(tester, size);
        var confirmed = 0;
        await showDialogOf(
          tester,
          DefaultDialog(
            title: const Text('Dialog title'),
            content: _longContent(),
            actions: _actions(onConfirm: () => confirmed++),
          ),
        );

        await tester.drag(find.text('Line 0'), const Offset(0, -2000));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(IntentButton, 'Confirm'));
        await tester.pump();

        expect(confirmed, 1);
      });
    }

    testWidgets('a long title is ellipsized without overflow', (tester) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf(
        tester,
        DefaultDialog(
          title: Text('Very long dialog title ' * 20),
          content: const Text('short'),
          actions: _actions(),
        ),
      );

      expect(tester.takeException(), isNull);
      final title = tester.widget<Text>(find.textContaining('Very long'));
      expect(title.data, isNotEmpty);
      expectFullyOnScreen(tester, find.textContaining('Very long'));
    });

    testWidgets('short content does not scroll', (tester) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf(
        tester,
        DefaultDialog(
          title: const Text('Dialog title'),
          content: const Text('short'),
          actions: _actions(),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(scrollable(tester).position.maxScrollExtent, 0);
      expectFullyOnScreen(tester, find.text('short'));
    });

    testWidgets('no content and no actions still builds', (tester) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf(tester, const DefaultDialog());

      expect(tester.takeException(), isNull);
      expect(find.byType(DefaultDialog), findsOneWidget);
      expect(find.byType(IntentButton), findsNothing);
    });

    testWidgets('keeps the dialog inside the screen with a huge content', (
      tester,
    ) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf(
        tester,
        DefaultDialog(
          title: const Text('Dialog title'),
          content: _longContent(),
          actions: _actions(),
        ),
      );

      expectFullyOnScreen(tester, find.byType(AlertDialog));
    });

    testWidgets('sorts the actions by priority, cancel left of confirm', (
      tester,
    ) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf(
        tester,
        DefaultDialog(
          title: const Text('Dialog title'),
          content: const Text('short'),
          actions: _actions(),
        ),
      );

      expect(
        tester.getCenter(find.widgetWithText(IntentButton, 'Cancel')).dx,
        lessThan(
          tester.getCenter(find.widgetWithText(IntentButton, 'Confirm')).dx,
        ),
      );
    });

    testWidgets('the close button closes the dialog', (tester) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf(
        tester,
        DefaultDialog(
          hasCloseButton: true,
          title: const Text('Dialog title'),
          content: const Text('short'),
          actions: _actions(),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(DefaultDialog), findsNothing);
    });
  });

  group('DefaultDialog with scrollableContent false', () {
    testWidgets('does not wrap the content in a scroll view', (tester) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf(
        tester,
        DefaultDialog(
          scrollableContent: false,
          title: const Text('Dialog title'),
          content: const Text('short'),
          actions: _actions(),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(DefaultDialog),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
    });

    testWidgets('lets a Flexible child shrink to the available height', (
      tester,
    ) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf(
        tester,
        DefaultDialog(
          scrollableContent: false,
          title: const Text('Dialog title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('intro'),
              Flexible(child: Container(key: const Key('flex'), height: 5000)),
            ],
          ),
          actions: _actions(),
        ),
      );

      expect(tester.takeException(), isNull);
      expectFullyOnScreen(tester, find.byKey(const Key('flex')));
      expectFullyOnScreen(tester, find.widgetWithText(IntentButton, 'Confirm'));
    });

    testWidgets('a bounded child such as a ListView scrolls by itself', (
      tester,
    ) async {
      setScreen(tester, const Size(320, 480));
      await showDialogOf(
        tester,
        DefaultDialog(
          scrollableContent: false,
          title: const Text('Dialog title'),
          content: SizedBox(
            width: 200,
            height: 200,
            child: ListView(
              children: [for (var i = 0; i < 50; i++) Text('Row $i')],
            ),
          ),
          actions: _actions(),
        ),
      );

      expect(tester.takeException(), isNull);
      await tester.drag(find.text('Row 0'), const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.text('Row 0').hitTestable(), findsNothing);
      expectFullyOnScreen(tester, find.widgetWithText(IntentButton, 'Confirm'));
    });
  });
}
