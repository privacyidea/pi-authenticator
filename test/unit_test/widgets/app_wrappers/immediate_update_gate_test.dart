/*
 * privacyIDEA Authenticator
 *
 * Author: Krzysztof Wielgosz <14099566+frankii91@users.noreply.github.com>
 *
 * Copyright (c) 2026 Krzysztof Wielgosz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/widgets/app_wrappers/immediate_update_gate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows only the required update title and update action', (
    tester,
  ) async {
    final client = _FakeImmediateUpdateClient(
      availability: ImmediateUpdateAvailability.available,
    );

    await _pumpGate(tester, client);

    expect(find.text('Update required'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(Text),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('system back cannot dismiss the required update prompt', (
    tester,
  ) async {
    final client = _FakeImmediateUpdateClient(
      availability: ImmediateUpdateAvailability.available,
    );

    await _pumpGate(tester, client);
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(client.performCount, 0);
  });

  testWidgets('update action starts the immediate update and keeps the gate', (
    tester,
  ) async {
    final client = _FakeImmediateUpdateClient(
      availability: ImmediateUpdateAvailability.available,
    );

    await _pumpGate(tester, client);
    await tester.tap(find.byKey(ImmediateUpdateGate.updateButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(client.performCount, 1);
  });

  testWidgets('failed update keeps the required update prompt visible', (
    tester,
  ) async {
    final client = _FakeImmediateUpdateClient(
      availability: ImmediateUpdateAvailability.available,
      failUpdate: true,
    );

    await _pumpGate(tester, client);
    await tester.tap(find.byKey(ImmediateUpdateGate.updateButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(client.performCount, 1);
  });

  testWidgets('resumes an immediate update already in progress', (
    tester,
  ) async {
    final client = _FakeImmediateUpdateClient(
      availability: ImmediateUpdateAvailability.inProgress,
    );

    await _pumpGate(tester, client);

    expect(find.byType(AlertDialog), findsNothing);
    expect(client.performCount, 1);
  });

  testWidgets('does nothing when an update is unavailable', (tester) async {
    final client = _FakeImmediateUpdateClient(
      availability: ImmediateUpdateAvailability.unavailable,
    );

    await _pumpGate(tester, client);

    expect(find.byType(AlertDialog), findsNothing);
    expect(client.performCount, 0);
  });
}

Future<void> _pumpGate(
  WidgetTester tester,
  ImmediateUpdateClient client,
) async {
  final navigatorKey = GlobalKey<NavigatorState>();

  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ImmediateUpdateGate(
        client: client,
        navigatorKey: navigatorKey,
        child: const Scaffold(body: SizedBox()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeImmediateUpdateClient implements ImmediateUpdateClient {
  final ImmediateUpdateAvailability availability;
  final bool failUpdate;
  int performCount = 0;

  _FakeImmediateUpdateClient({
    required this.availability,
    this.failUpdate = false,
  });

  @override
  Future<ImmediateUpdateAvailability> checkAvailability() async => availability;

  @override
  Future<void> performImmediateUpdate() async {
    performCount++;
    if (failUpdate) throw StateError('Update failed');
  }
}
