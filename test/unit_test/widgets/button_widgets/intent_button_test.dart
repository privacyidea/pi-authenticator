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
import 'package:privacyidea_authenticator/widgets/pi_progress_circle.dart';

void main() {
  const double mockControlHeight = 50.0;
  const double mockMinWidth = 120.0;
  const double mockBorderRadius = 8.0;
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        extensions: const [
          AppDimensions(
            controlHeight: mockControlHeight,
            controlMinWidth: mockMinWidth,
            borderRadius: mockBorderRadius,
            spacingMedium: 20,
            iconSizeMedium: 24,
            strokeWidth: 2,
          ),
        ],
      ),
      home: Scaffold(body: child),
    );
  }

  group('IntentButton - UI & Layout Tests', () {
    for (final intent in ActionIntent.values) {
      testWidgets('renders correct button type for intent: $intent', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrap(
            IntentButton(
              intent: intent,
              onPressed: () {},
              child: const Text('Test'),
            ),
          ),
        );
        if (intent == ActionIntent.confirm ||
            intent == ActionIntent.destructive) {
          expect(find.byType(ElevatedButton), findsOneWidget);
        } else if (intent == ActionIntent.info) {
          expect(find.byType(OutlinedButton), findsOneWidget);
        } else {
          expect(find.byType(TextButton), findsOneWidget);
        }
      });
    }
    testWidgets('ElevatedButton has correct dimensions and shape', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          IntentButton(
            intent: ActionIntent.confirm,
            onPressed: () {},
            child: const Text('DimTest'),
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style!;
      expect(
        style.minimumSize?.resolve({}),
        const Size(mockMinWidth, mockControlHeight),
      );
      final shape = style.shape?.resolve({}) as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(mockBorderRadius));
    });
    testWidgets('Destructive intent uses error colors', (tester) async {
      await tester.pumpWidget(
        wrap(
          IntentButton(
            intent: ActionIntent.destructive,
            onPressed: () {},
            child: const Text('Delete'),
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final theme = Theme.of(tester.element(find.byType(ElevatedButton)));
      expect(
        button.style!.backgroundColor?.resolve({}),
        theme.colorScheme.error,
      );
    });
  });
  group('IntentButton.icon - Specialized Tests', () {
    testWidgets('renders IconButton with correct intent color', (tester) async {
      await tester.pumpWidget(
        wrap(
          IntentButton.icon(
            intent: ActionIntent.destructive,
            onPressed: () {},
            icon: Icons.delete,
          ),
        ),
      );
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      final theme = Theme.of(tester.element(find.byType(IconButton)));
      expect(iconButton.color, theme.colorScheme.error);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
    testWidgets('applies custom iconSize', (tester) async {
      const double customSize = 42.0;
      await tester.pumpWidget(
        wrap(
          IntentButton.icon(
            intent: ActionIntent.info,
            onPressed: () {},
            icon: Icons.info,
            iconSize: customSize,
          ),
        ),
      );
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.iconSize, customSize);
    });
  });
  group('IntentButton - Async & Loading Logic', () {
    testWidgets('shows loading spinner when internal future is running', (
      tester,
    ) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        wrap(
          IntentButton(
            intent: ActionIntent.confirm,
            onPressed: () => completer.future,
            child: const Text('Submit'),
          ),
        ),
      );
      await tester.tap(find.byType(IntentButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit').hitTestable(), findsNothing);
      completer.complete();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Submit'), findsOneWidget);
    });
    testWidgets('isLoading prop overrides internal state', (tester) async {
      await tester.pumpWidget(
        wrap(
          IntentButton(
            intent: ActionIntent.confirm,
            onPressed: () {},
            isLoading: true,
            child: const Text('Manual Loading'),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
    testWidgets('button is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        wrap(
          const IntentButton(
            intent: ActionIntent.confirm,
            onPressed: null,
            child: Text('Disabled'),
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
  group('IntentButton - Cooldown Logic', () {
    testWidgets('prevents second tap during cooldownMs', (tester) async {
      int callCount = 0;
      await tester.pumpWidget(
        wrap(
          IntentButton(
            intent: ActionIntent.confirm,
            cooldownMs: 1000,
            onPressed: () => callCount++,
            child: const Text('Cooldown'),
          ),
        ),
      );
      await tester.tap(find.byType(IntentButton));
      await tester.pump();
      expect(callCount, 1);
      await tester.tap(find.byType(IntentButton));
      await tester.pump();
      expect(callCount, 1);
      await tester.pump(const Duration(milliseconds: 1001));
      await tester.tap(find.byType(IntentButton));
      await tester.pump();
      expect(callCount, 2);
    });
  });
  group('IntentButton - Delay (Countdown) Logic', () {
    testWidgets('shows countdown and prevents press until finished', (
      tester,
    ) async {
      int callCount = 0;
      await tester.pumpWidget(
        wrap(
          IntentButton(
            intent: ActionIntent.confirm,
            delaySeconds: 3,
            onPressed: () => callCount++,
            child: const Text('Delayed'),
          ),
        ),
      );
      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.byType(IntentButton));
      await tester.pump();
      expect(callCount, 0);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Delayed'), findsOneWidget);
      await tester.tap(find.byType(IntentButton));
      expect(callCount, 1);
    });
  });
  group('IntentButton - Accessibility & Semantics', () {
    testWidgets('applies semanticsLabel correctly', (tester) async {
      await tester.pumpWidget(
        wrap(
          IntentButton(
            intent: ActionIntent.confirm,
            onPressed: () {},
            semanticsLabel: 'SemanticSubmit',
            child: const Text('UI Text'),
          ),
        ),
      );
      final semanticsFinder = find.bySemanticsLabel('SemanticSubmit');
      expect(semanticsFinder, findsOneWidget);
    });
  });
  group('IntentButton - External Intent specialized UI', () {
    testWidgets('ActionIntent.external renders an additional icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          IntentButton(
            intent: ActionIntent.external,
            onPressed: () {},
            child: const Text('Open Link'),
          ),
        ),
      );
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
    });
  });
  group('ActionIntentX Extension Tests', () {
    test('priority mapping is correct', () {
      expect(ActionIntent.cancel.priority, 1);
      expect(ActionIntent.neutral.priority, 1);
      expect(ActionIntent.external.priority, 2);
      expect(ActionIntent.info.priority, 3);
      expect(ActionIntent.confirm.priority, 4);
      expect(ActionIntent.destructive.priority, 4);
    });
  });
  group('IntentButton - Deep Layout & Style Consistency', () {
    testWidgets('OutlinedButton for ActionIntent.info matches design spec', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          IntentButton(
            intent: ActionIntent.info,
            onPressed: () {},
            child: const Text('Info'),
          ),
        ),
      );
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final theme = Theme.of(tester.element(find.byType(OutlinedButton)));
      final side = button.style!.side!.resolve({})!;
      expect(side.color, theme.dividerColor);
      expect(
        button.style!.minimumSize!.resolve({}),
        const Size(mockMinWidth, mockControlHeight),
      );
    });
    testWidgets(
      'TextButton for ActionIntent.neutral has no background but correct foreground',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            IntentButton(
              intent: ActionIntent.neutral,
              onPressed: () {},
              child: const Text('Neutral'),
            ),
          ),
        );
        final button = tester.widget<TextButton>(find.byType(TextButton));
        final theme = Theme.of(tester.element(find.byType(TextButton)));
        expect(button.style!.backgroundColor?.resolve({}), isNull);
        expect(
          button.style!.foregroundColor?.resolve({}),
          theme.colorScheme.onSurface,
        );
      },
    );
    testWidgets(
      'Disabled state colors for ElevatedButton (ActionIntent.confirm)',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const IntentButton(
              intent: ActionIntent.confirm,
              onPressed: null,
              child: Text('Disabled'),
            ),
          ),
        );
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final theme = Theme.of(tester.element(find.byType(ElevatedButton)));
        final disabledBg = button.style?.backgroundColor?.resolve({
          WidgetState.disabled,
        });
        final disabledFg = button.style?.foregroundColor?.resolve({
          WidgetState.disabled,
        });
        expect(disabledBg, theme.colorScheme.onSurface.withValues(alpha: 0.12));
        expect(disabledFg, theme.colorScheme.onSurface.withValues(alpha: 0.38));
      },
    );
    testWidgets('IconButton uses specific intent colors for every intent', (
      tester,
    ) async {
      for (final intent in ActionIntent.values) {
        await tester.pumpWidget(
          wrap(
            IntentButton.icon(
              intent: intent,
              onPressed: () {},
              icon: Icons.star,
            ),
          ),
        );
        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        final theme = Theme.of(tester.element(find.byType(IconButton)));
        final expectedColor = switch (intent) {
          ActionIntent.destructive => theme.colorScheme.error,
          ActionIntent.confirm => theme.colorScheme.primary,
          ActionIntent.info => theme.colorScheme.secondary,
          ActionIntent.external => theme.colorScheme.tertiary,
          ActionIntent.neutral ||
          ActionIntent.cancel => theme.colorScheme.onSurfaceVariant,
        };
        expect(iconButton.color, expectedColor);
      }
    });
  });
  group('IntentButton - Complex Interaction & Timing Edge Cases', () {
    testWidgets(
      'Internal loading state does not trigger if onPressed is not a Future',
      (tester) async {
        bool called = false;
        await tester.pumpWidget(
          wrap(
            IntentButton(
              intent: ActionIntent.confirm,
              onPressed: () {
                called = true;
              },
              child: const Text('SyncCall'),
            ),
          ),
        );
        await tester.tap(find.byType(IntentButton));
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(called, isTrue);
      },
    );
    testWidgets(
      'State persists correctly when widget is updated during delay',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const IntentButton(
              intent: ActionIntent.confirm,
              onPressed: null,
              delaySeconds: 10,
              child: Text('Initial'),
            ),
          ),
        );
        expect(find.text('10'), findsOneWidget);
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('9'), findsOneWidget);
        await tester.pumpWidget(
          wrap(
            const IntentButton(
              intent: ActionIntent.confirm,
              onPressed: null,
              delaySeconds: 10,
              child: Text('Updated'),
            ),
          ),
        );
        expect(find.text('9'), findsOneWidget);
      },
    );
    testWidgets(
      'Rapid multiple taps only trigger Future once (Race Condition Check)',
      (tester) async {
        int callCount = 0;
        final completer = Completer<void>();
        await tester.pumpWidget(
          wrap(
            IntentButton(
              intent: ActionIntent.confirm,
              onPressed: () async {
                callCount++;
                await completer.future;
              },
              child: const Text('Submit'),
            ),
          ),
        );
        await tester.tap(find.byType(IntentButton));
        await tester.tap(find.byType(IntentButton));
        await tester.tap(find.byType(IntentButton));
        await tester.pump();
        expect(callCount, 1);
        completer.complete();
        await tester.pump();
      },
    );
    testWidgets(
      'Widget disposal cancels delay timers and prevents memory leaks',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const IntentButton(
              intent: ActionIntent.confirm,
              delaySeconds: 60,
              onPressed: null,
              child: Text('LongDelay'),
            ),
          ),
        );
        await tester.pumpWidget(wrap(const SizedBox.shrink()));
        await tester.pump(const Duration(seconds: 1));
      },
    );
  });
  group('IntentButton - Animation & Progress Tests', () {
    testWidgets(
      'PiCircularProgressIndicator swaps colors on every second in delay',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const IntentButton(
              intent: ActionIntent.confirm,
              delaySeconds: 2,
              onPressed: null,
              child: Text('SwapTest'),
            ),
          ),
        );
        Finder getIndicator() => find.byType(PiProgressCircle);
        final indicator1 = tester.widget<PiProgressCircle>(getIndicator());
        expect(indicator1.swapColors, isTrue);
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        final indicator2 = tester.widget<PiProgressCircle>(getIndicator());
        expect(indicator2.swapColors, isFalse);
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      },
    );
    testWidgets('Loading spinner uses correct dimensions and strokeWidth', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          IntentButton(
            intent: ActionIntent.confirm,
            isLoading: true,
            onPressed: () {},
            child: const Text('Loading'),
          ),
        ),
      );
      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final container = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(CircularProgressIndicator),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(spinner.strokeWidth, 2.0);
      expect(container.width, 24.0);
      expect(container.height, 24.0);
    });
  });
  group('IntentButton - Edge Case Child Rendering', () {
    testWidgets('Standard button hides child text during loading via Opacity', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          IntentButton(
            intent: ActionIntent.confirm,
            isLoading: true,
            onPressed: () {},
            child: const Text('VisibleText'),
          ),
        ),
      );
      final opacityWidget = tester.widget<Opacity>(
        find.ancestor(
          of: find.text('VisibleText'),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacityWidget.opacity, 0.0);
    });
    testWidgets('Icon button shows spinner instead of icon during loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          IntentButton.icon(
            intent: ActionIntent.confirm,
            isLoading: true,
            onPressed: () {},
            icon: Icons.add,
          ),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
      final opacityWidget = tester.widget<Opacity>(
        find.ancestor(
          of: find.byIcon(Icons.add),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacityWidget.opacity, 0.0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
