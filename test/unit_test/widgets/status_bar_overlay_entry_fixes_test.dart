import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/widgets/status_bar.dart';

import '../../tests_app_wrapper.dart';

void main() {
  Widget wrap(Widget child) => TestsAppWrapper(child: Stack(children: [child]));

  testWidgets('removing the widget disposes the controller without exceptions', (tester) async {
    await tester.pumpWidget(wrap(StatusBarOverlayEntry(statusText: 'Main', statusSubText: 'Sub', type: StatusMessageType.success, onDismissed: (_) {})));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));

    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping pauses and shows the sub text without line limit', (tester) async {
    const sub = 'A long sub text that goes on and on';
    await tester.pumpWidget(wrap(StatusBarOverlayEntry(statusText: 'Main', statusSubText: sub, type: StatusMessageType.success, onDismissed: (_) {})));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.widget<Text>(find.text(sub)).maxLines, 2);

    await tester.tap(find.text('Main'));
    await tester.pump();
    expect(tester.widget<Text>(find.text(sub)).maxLines, isNull);

    // second tap resumes
    await tester.tap(find.text('Main'));
    await tester.pump();
    expect(tester.widget<Text>(find.text(sub)).maxLines, 2);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    expect(tester.takeException(), isNull);
  });
}
