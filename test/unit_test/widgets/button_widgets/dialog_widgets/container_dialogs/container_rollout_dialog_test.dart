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
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/token_template.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/container_rollout_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../../../tests_app_wrapper.dart';

TokenContainerFinalized createMockContainer({required String serial}) {
  return TokenContainerFinalized(
    serial: serial,
    issuer: 'privacyIDEA',
    nonce: 'nonce_sync_123',
    timestamp: DateTime.now(),
    serverUrl: Uri.parse('https://example.com'),
    ecKeyAlgorithm: EcKeyAlgorithm.prime256v1,
    hashAlgorithm: Algorithms.SHA256,
    sslVerify: true,
    publicClientKey: 'pub',
    privateClientKey: 'priv',
  );
}

class FakeToken extends Token {
  final String fakeLabel;
  final String fakeType;

  const FakeToken({required this.fakeLabel, required this.fakeType})
    : super(
        serial: 'serial_$fakeLabel',
        label: fakeLabel,
        type: fakeType,
        id: "id_${fakeLabel}_$fakeType",
      );

  @override
  Map<String, dynamic> toJson() => {};

  @override
  Token copyUpdateByTemplate(TokenTemplate template) {
    return FakeToken(fakeLabel: fakeLabel, fakeType: template.type ?? fakeType);
  }

  @override
  Token copyWith({
    String? Function()? serial,
    String? label,
    String? issuer,
    String? Function()? containerSerial,
    List<String>? checkedContainer,
    String? id,
    bool? isLocked,
    bool? isHidden,
    bool? pin,
    String? tokenImage,
    int? sortIndex,
    int? Function()? folderId,
    TokenOriginData? origin,
    bool? isOffline,
  }) {
    return FakeToken(fakeLabel: label ?? fakeLabel, fakeType: fakeType);
  }
}

void main() {
  final testContainer = createMockContainer(serial: 'PI_CON_01');

  group('ContainerSyncResultDialog - UI & Logic Tests', () {
    testWidgets(
      'Does not show dialog if both lists are empty (Static Method Check)',
      (tester) async {
        await tester.pumpWidget(
          TestsAppWrapper(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ContainerSyncResultDialog.showDialog(
                  container: testContainer,
                  addedTokens: [],
                  removedTokens: [],
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        expect(find.byType(ContainerSyncResultDialog), findsNothing);
      },
    );

    testWidgets('Displays added tokens grouped by type', (tester) async {
      final added = [
        FakeToken(fakeLabel: 'Token 1', fakeType: 'HOTP'),
        FakeToken(fakeLabel: 'Token 2', fakeType: 'HOTP'),
        FakeToken(fakeLabel: 'Token 3', fakeType: 'TOTP'),
      ];

      await tester.pumpWidget(
        TestsAppWrapper(
          child: ContainerSyncResultDialog(
            container: testContainer,
            addedTokens: added,
            removedTokens: const [],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('PI_CON_01'), findsOneWidget);

      expect(find.textContaining('2x HOTP'), findsOneWidget);
      expect(find.textContaining('1x TOTP'), findsOneWidget);

      expect(find.byIcon(Icons.add_circle), findsNWidgets(2));
    });

    testWidgets('Displays removed tokens with their labels', (tester) async {
      final removed = [
        FakeToken(fakeLabel: 'Old Token A', fakeType: 'HOTP'),
        FakeToken(fakeLabel: 'Old Token B', fakeType: 'TOTP'),
      ];

      await tester.pumpWidget(
        TestsAppWrapper(
          child: ContainerSyncResultDialog(
            container: testContainer,
            addedTokens: const [],
            removedTokens: removed,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Old Token A'), findsOneWidget);
      expect(find.textContaining('Old Token B'), findsOneWidget);

      expect(find.byIcon(Icons.remove_circle), findsNWidgets(2));
    });

    testWidgets('Displays both sections when tokens are added and removed', (
      tester,
    ) async {
      final added = [FakeToken(fakeLabel: 'New', fakeType: 'PUSH')];
      final removed = [FakeToken(fakeLabel: 'Old', fakeType: 'PUSH')];

      await tester.pumpWidget(
        TestsAppWrapper(
          child: ContainerSyncResultDialog(
            container: testContainer,
            addedTokens: added,
            removedTokens: removed,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ContainerSyncResultDialog));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.containerSyncDialogNewTokens), findsOneWidget);
      expect(find.text(l10n.containerSyncDialogRemovedTokens), findsOneWidget);

      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('OK button closes the dialog', (tester) async {
      final added = [const FakeToken(fakeLabel: 'T', fakeType: 'HOTP')];

      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ContainerSyncResultDialog.showDialog(
                container: testContainer,
                addedTokens: added,
                removedTokens: const [],
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byType(ContainerSyncResultDialog), findsOneWidget);

      final context = tester.element(find.byType(ContainerSyncResultDialog));
      final l10n = AppLocalizations.of(context)!;

      final okButton = find.descendant(
        of: find.byType(DefaultDialog),
        matching: find.text(l10n.ok),
      );

      expect(okButton, findsOneWidget);
      await tester.tap(okButton);
      await tester.pumpAndSettle();

      expect(find.byType(ContainerSyncResultDialog), findsNothing);
    });

    testWidgets('Visual consistency: typography and spacing', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: ContainerSyncResultDialog(
            container: testContainer,
            addedTokens: [
              const FakeToken(fakeLabel: 'Label', fakeType: 'Type'),
            ],
            removedTokens: const [],
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textFinder = find.textContaining('1x Type');
      expect(textFinder, findsAtLeastNWidgets(1));

      final textWidget = tester.widget<Text>(textFinder.first);
      final theme = Theme.of(
        tester.element(find.byType(ContainerSyncResultDialog)),
      );

      expect(textWidget.style?.fontSize, theme.textTheme.bodyLarge?.fontSize);

      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
    });

    testWidgets('Scrolls when there are many tokens', (tester) async {
      final added = List.generate(
        20,
        (i) => FakeToken(fakeLabel: 'T$i', fakeType: 'Type$i'),
      );

      await tester.pumpWidget(
        TestsAppWrapper(
          child: ContainerSyncResultDialog(
            container: testContainer,
            addedTokens: added,
            removedTokens: const [],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);

      final lastTokenFinder = find.textContaining('1x Type19');
      await tester.dragUntilVisible(
        lastTokenFinder,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );

      expect(lastTokenFinder, findsOneWidget);
    });

    testWidgets('Visual consistency: typography and spacing', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: ContainerSyncResultDialog(
            container: testContainer,
            addedTokens: [
              const FakeToken(fakeLabel: 'Label', fakeType: 'Type'),
            ],
            removedTokens: const [],
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textFinder = find.descendant(
        of: find.byType(ContainerSyncResultDialog),
        matching: find.textContaining('1x Type'),
      );

      final textWidget = tester.widget<Text>(textFinder.first);

      final theme = Theme.of(
        tester.element(find.byType(ContainerSyncResultDialog)),
      );

      expect(textWidget.style?.fontSize, theme.textTheme.bodyLarge?.fontSize);

      final columnFinder = find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Column),
      );

      final column = tester.widget<Column>(columnFinder);
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
    });

    testWidgets(
      'Static showDialog uses showAsyncDialog (Context Integration)',
      (tester) async {
        await tester.pumpWidget(
          TestsAppWrapper(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ContainerSyncResultDialog.showDialog(
                  container: testContainer,
                  addedTokens: [FakeToken(fakeLabel: 'A', fakeType: 'B')],
                  removedTokens: [],
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.byType(ContainerSyncResultDialog), findsOneWidget);
      },
    );
  });
}
