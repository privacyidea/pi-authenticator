import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/default_token_actions/default_edit_action_dialog.dart';
import 'package:privacyidea_authenticator/widgets/enable_text_edit_after_many_taps.dart';

import '../../tests_app_wrapper.dart';

void main() {
  group('EnableTextEditAfterManyTaps Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController(text: 'Initial Text');
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('enables editing after exact number of taps', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: EnableTextEditAfterManyTaps(
            controller: controller,
            labelText: 'Test Label',
            maxTaps: 3,
          ),
        ),
      );

      final readOnlyFinder = find.byType(ReadOnlyTextFormField);

      for (int i = 0; i < 3; i++) {
        await tester.tap(readOnlyFinder);

        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pump();
      expect(find.byType(TextFormField), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('handles double taps correctly', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: EnableTextEditAfterManyTaps(
            controller: controller,
            labelText: 'Test Label',
            maxTaps: 2,
          ),
        ),
      );

      final detector = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );
      detector.onDoubleTap!();

      await tester.pump();
      expect(find.byType(TextFormField), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
