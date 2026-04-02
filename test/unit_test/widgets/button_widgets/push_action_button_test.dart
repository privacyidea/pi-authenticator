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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/app_dimensions.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/push_action_button.dart';

void main() {
  const double mockControlHeight = 60.0;
  const double mockMinWidth = 150.0;
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        extensions: const [
          AppDimensions(
            controlHeight: mockControlHeight,
            controlMinWidth: mockMinWidth,
            borderRadius: 12.0,
            spacingMedium: 20,
            iconSizeMedium: 24,
            strokeWidth: 2,
          ),
        ],
      ),
      home: Scaffold(body: child),
    );
  }

  group('PushActionButton - Structural & Delegation Tests', () {
    testWidgets('renders an IntentButton as its core', (tester) async {
      await tester.pumpWidget(
        wrap(PushActionButton(onPressed: () {}, child: const Text('Push'))),
      );
      expect(find.byType(IntentButton), findsOneWidget);
    });
    testWidgets('delegates intent correctly to IntentButton', (tester) async {
      await tester.pumpWidget(
        wrap(
          PushActionButton(
            onPressed: () {},
            intent: ActionIntent.destructive,
            child: const Text('Delete'),
          ),
        ),
      );
      final intentButton = tester.widget<IntentButton>(
        find.byType(IntentButton),
      );
      expect(intentButton.intent, ActionIntent.destructive);
    });
    testWidgets('delegates minThreshold as cooldownMs to IntentButton', (
      tester,
    ) async {
      const int customThreshold = 2500;
      await tester.pumpWidget(
        wrap(
          PushActionButton(
            onPressed: () {},
            minThreshold: customThreshold,
            child: const Text('Cooldown'),
          ),
        ),
      );
      final intentButton = tester.widget<IntentButton>(
        find.byType(IntentButton),
      );
      expect(intentButton.cooldownMs, customThreshold);
    });
  });
  group('PushActionButton - Typography & Styling Tests', () {
    testWidgets('uses headlineSmall typography for the child', (tester) async {
      await tester.pumpWidget(
        wrap(
          PushActionButton(onPressed: () {}, child: const Text('Styled Text')),
        ),
      );
      final textWidget = tester.widget<Text>(find.text('Styled Text'));
      expect(textWidget.style, isNull);
      final theme = Theme.of(tester.element(find.text('Styled Text')));
      final defaultTextStyle = DefaultTextStyle.of(
        tester.element(find.text('Styled Text')),
      );
      expect(
        defaultTextStyle.style.fontSize,
        theme.textTheme.headlineSmall?.fontSize,
      );
      expect(
        defaultTextStyle.style.fontWeight,
        theme.textTheme.headlineSmall?.fontWeight,
      );
    });
    testWidgets('applies onPrimary color when enabled', (tester) async {
      await tester.pumpWidget(
        wrap(
          PushActionButton(
            onPressed: () {},
            child: const Text('Enabled Color'),
          ),
        ),
      );
      final theme = Theme.of(tester.element(find.text('Enabled Color')));
      final text = tester.widget<Text>(find.text('Enabled Color'));
      expect(text.style, isNull);
      final defaultTextStyle = DefaultTextStyle.of(
        tester.element(find.text('Enabled Color')),
      );
      expect(defaultTextStyle.style.color, theme.colorScheme.onPrimary);
    });
    testWidgets(
      'applies disabled color (onSurface alpha 0.38) when onPressed is null',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const PushActionButton(
              onPressed: null,
              child: Text('Disabled Color'),
            ),
          ),
        );
        final theme = Theme.of(tester.element(find.text('Disabled Color')));
        final defaultTextStyle = DefaultTextStyle.of(
          tester.element(find.text('Disabled Color')),
        );
        expect(
          defaultTextStyle.style.color,
          theme.colorScheme.onSurface.withValues(alpha: 0.38),
        );
      },
    );
    testWidgets('wraps child in a Center widget', (tester) async {
      await tester.pumpWidget(
        wrap(PushActionButton(onPressed: () {}, child: const Text('Centered'))),
      );
      expect(
        find.ancestor(of: find.text('Centered'), matching: find.byType(Center)),
        findsOneWidget,
      );
    });
  });
  group('PushActionButton - Interaction & Lifecycle Tests', () {
    testWidgets('triggers onPressed callback when tapped', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        wrap(
          PushActionButton(
            onPressed: () => called = true,
            child: const Text('Tap Me'),
          ),
        ),
      );
      await tester.tap(find.byType(PushActionButton));
      await tester.pump();
      expect(called, isTrue);
    });
    testWidgets('honors minThreshold to prevent double taps', (tester) async {
      int callCount = 0;
      await tester.pumpWidget(
        wrap(
          PushActionButton(
            onPressed: () => callCount++,
            child: const Text('Double Tap'),
          ),
        ),
      );
      await tester.tap(find.byType(PushActionButton));
      await tester.pump();
      expect(callCount, 1);
      await tester.tap(find.byType(PushActionButton));
      await tester.pump(const Duration(milliseconds: 500));
      expect(callCount, 1);
      await tester.pump(const Duration(milliseconds: 501));
      await tester.tap(find.byType(PushActionButton));
      await tester.pump();
      expect(callCount, 2);
    });
    testWidgets(
      'handles async onPressed with loading state (via IntentButton)',
      (tester) async {
        final completer = Completer<void>();
        await tester.pumpWidget(
          wrap(
            PushActionButton(
              onPressed: () => completer.future,
              child: const Text('Async'),
            ),
          ),
        );
        await tester.tap(find.byType(PushActionButton));
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        completer.complete();
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });
  group('PushActionButton - Edge Cases & Robustness', () {
    testWidgets('works correctly with different ActionIntents', (tester) async {
      for (final intent in ActionIntent.values) {
        await tester.pumpWidget(
          wrap(
            PushActionButton(
              intent: intent,
              onPressed: () {},
              child: Text('Intent $intent'),
            ),
          ),
        );
        expect(find.text('Intent $intent'), findsOneWidget);
        final intentBtn = tester.widget<IntentButton>(
          find.byType(IntentButton),
        );
        expect(intentBtn.intent, intent);
      }
    });
    testWidgets('maintains custom child hierarchy', (tester) async {
      await tester.pumpWidget(
        wrap(
          PushActionButton(
            onPressed: () {},
            child: const Row(children: [Icon(Icons.check), Text('Approve')]),
          ),
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
    });
    testWidgets('reacts to external isLoading state if parent rebuilds', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PushActionButton(onPressed: () {}, child: const Text('StateChange')),
        ),
      );
      await tester.pumpWidget(
        wrap(
          const PushActionButton(onPressed: null, child: Text('StateChange')),
        ),
      );
      final defaultTextStyle = DefaultTextStyle.of(
        tester.element(find.text('StateChange')),
      );
      final theme = Theme.of(tester.element(find.text('StateChange')));
      expect(
        defaultTextStyle.style.color,
        theme.colorScheme.onSurface.withValues(alpha: 0.38),
      );
    });
    testWidgets('cleans up resources on dispose (via IntentButton timers)', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PushActionButton(
            onPressed: () {},
            minThreshold: 5000,
            child: const Text('Cleanup'),
          ),
        ),
      );
      await tester.tap(find.byType(PushActionButton));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 6));
    });
  });
}
