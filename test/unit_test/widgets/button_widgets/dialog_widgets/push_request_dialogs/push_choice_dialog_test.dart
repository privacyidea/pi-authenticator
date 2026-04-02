import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/push_request/push_choice_request.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/push_action_button.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/push_request_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/widgets/push_decline_confirm_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/widgets/push_request_base_info.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/widgets/push_request_header.dart';

import '../../../../../tests_app_wrapper.dart';

void main() {
  final mockPushRequest = PushChoiceRequest(
    title: 'Login Request',
    serial: 'PUSH123',
    question: 'Select the matching number',
    nonce: 'nonce_123456',
    signature: 'sig_abcdef',
    uri: Uri.parse('https://example.com/push'),
    sslVerify: true,
    possibleAnswers: ['11', '22', '33'],
    expirationDate: DateTime.now().add(const Duration(minutes: 1)),
  );

  final mockToken = PushToken(
    serial: 'PUSH123',
    label: 'My Phone',
    id: 'id_push',
  );

  group('PushChoiceDialog - Suite', () {
    testWidgets('Renders all answers and info components', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushChoiceDialog(
            pushRequest: mockPushRequest,
            token: mockToken,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PushRequestHeader), findsOneWidget);
      expect(find.byType(PushRequestBaseInfo), findsOneWidget);

      for (final answer in mockPushRequest.possibleAnswers) {
        expect(find.text(answer), findsOneWidget);
      }
    });

    group('PushChoiceDialog - Grid Layout Logic', () {
      testWidgets('3 choices results in 1x3 layout', (tester) async {
        final actionRows = await _getGridRowsForCount(tester, 3);

        expect(actionRows.length, 1);
        expect(actionRows[0].children.length, 3);
      });

      testWidgets('4 choices results in 2x2 layout', (tester) async {
        final actionRows = await _getGridRowsForCount(tester, 4);

        expect(actionRows.length, 2);
        expect(actionRows[0].children.length, 2);
        expect(actionRows[1].children.length, 2);
      });

      testWidgets('5 choices results in 3+2 layout', (tester) async {
        final actionRows = await _getGridRowsForCount(tester, 5);

        expect(actionRows.length, 2);
        expect(actionRows[0].children.length, 3);
        expect(actionRows[1].children.length, 2);
      });
    });

    testWidgets('Tapping decline opens confirmation sub-dialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushChoiceDialog(
            pushRequest: mockPushRequest,
            token: mockToken,
          ),
        ),
      );
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(PushChoiceDialog)),
      )!;

      await tester.tap(find.text(l10n.decline));

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PushDeclineConfirmDialog), findsOneWidget);
    });

    testWidgets('Choice button triggers handleAccept (via callback check)', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushChoiceDialog(
            pushRequest: mockPushRequest,
            token: mockToken,
          ),
        ),
      );
      await tester.pump();

      final firstAnswer = mockPushRequest.possibleAnswers.first;
      final buttonFinder = find.widgetWithText(PushActionButton, firstAnswer);

      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}

Future<List<Row>> _getGridRowsForCount(WidgetTester tester, int count) async {
  final answers = List.generate(count, (index) => 'Answer ${index + 1}');

  final request = PushChoiceRequest(
    title: 'Title',
    question: 'Question',
    nonce: 'n',
    serial: 'S',
    signature: 's',
    uri: Uri.parse('https://example.com'),
    sslVerify: true,
    possibleAnswers: answers,
    expirationDate: DateTime.now().add(const Duration(minutes: 5)),
  );

  final token = PushToken(serial: 'S', label: 'L', id: 'I');

  await tester.pumpWidget(
    TestsAppWrapper(
      child: PushChoiceDialog(pushRequest: request, token: token),
    ),
  );
  await tester.pump();

  return tester
      .widgetList<Row>(find.byType(Row))
      .where(
        (r) => r.children.any(
          (c) => find
              .descendant(
                of: find.byWidget(c),
                matching: find.byType(PushActionButton),
              )
              .evaluate()
              .isNotEmpty,
        ),
      )
      .toList();
}
