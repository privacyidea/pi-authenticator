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

import '../../tests_app_wrapper.dart';

/// Shared layout helpers for the dialog tests that check that a dialog fits on small screens.

const dialogLayoutSizes = <String, Size>{
  '320x480 portrait': Size(320, 480),
  '480x320 landscape': Size(480, 320),
  '568x320 landscape': Size(568, 320),
  '360x640 portrait': Size(360, 640),
};

void setScreen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> showDialogOf<T>(
  WidgetTester tester,
  Widget dialog, {
  void Function(T? result)? onResult,
}) async {
  await tester.pumpWidget(
    TestsAppWrapper(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final result = await showDialog<T>(
              context: context,
              builder: (_) => dialog,
            );
            onResult?.call(result);
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Finder qrOf(Type dialog) =>
    find.descendant(of: find.byType(dialog), matching: find.byType(Image));

void expectOnScreen(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);
  final rect = tester.getRect(finder);
  final screen = Offset.zero & tester.view.physicalSize;
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

Finder surfaceOf() => find
    .descendant(of: find.byType(Dialog), matching: find.byType(Material))
    .first;

void expectInsideSurface(WidgetTester tester, Finder surface, Finder inner) {
  final outer = tester.getRect(surface);
  final rect = tester.getRect(inner);
  expect(outer.contains(rect.topLeft), isTrue, reason: '$inner top left');
  expect(
    outer.contains(rect.bottomRight - const Offset(0.01, 0.01)),
    isTrue,
    reason: '$inner bottom right',
  );
}

void expectSquare(WidgetTester tester, Finder finder) {
  final size = tester.getSize(finder);
  expect(size.width, greaterThan(0));
  expect(size.height, greaterThan(0));
  expect(size.width, closeTo(size.height, 0.5));
}
