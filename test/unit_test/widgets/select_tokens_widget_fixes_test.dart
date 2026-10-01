import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/widgets/select_tokens_widget.dart';

import '../../tests_app_wrapper.dart';

HOTPToken _token(String id) => HOTPToken(
  label: 'label$id',
  issuer: 'issuer$id',
  id: id,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'CDLDLKLUMPDR2IJJZJHF5XKFKBABU4XR',
);

void main() {
  late Token a, b, c;
  setUp(() {
    a = _token('a');
    b = _token('b');
    c = _token('c');
  });

  Widget build(Set<Token> tokens, void Function(Set<Token>, Set<Token>) onSelect, {bool multi = true}) => TestsAppWrapper(
    child: Scaffold(
      body: SingleChildScrollView(
        child: SelectTokensWidget(tokens: tokens, onSelect: onSelect, multiSelect: multi),
      ),
    ),
  );

  group('SelectTokensWidget fixes', () {
    testWidgets('selecting a token does not mutate the input set', (tester) async {
      final input = <Token>{a, b, c};
      Set<Token>? selected, unselected;
      await tester.pumpWidget(
        build(input, (s, u) {
          selected = {...s};
          unselected = {...u};
        }, multi: false),
      );
      await tester.pump();

      await tester.tap(find.text('labela'));
      await tester.pump();

      expect(selected, {a});
      expect(unselected, {b, c});
      expect(input, {a, b, c});
    });

    testWidgets('select all then deselect restores without mutating input', (tester) async {
      final input = <Token>{a, b, c};
      Set<Token>? selected, unselected;
      await tester.pumpWidget(
        build(input, (s, u) {
          selected = {...s};
          unselected = {...u};
        }),
      );
      await tester.pump();

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(selected, {a, b, c});
      expect(unselected, isEmpty);
      expect(input, {a, b, c});

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(selected, isEmpty);
      expect(unselected, {a, b, c});
      expect(input, {a, b, c});
    });

    testWidgets('updating the widget drops selections that are no longer present', (tester) async {
      Set<Token>? selected, unselected;
      void onSelect(Set<Token> s, Set<Token> u) {
        selected = {...s};
        unselected = {...u};
      }

      await tester.pumpWidget(build({a, b, c}, onSelect));
      await tester.pump();
      await tester.tap(find.text('labela'));
      await tester.pump();
      await tester.tap(find.text('labelb'));
      await tester.pump();
      expect(selected, {a, b});

      // b removed, a stays selected
      await tester.pumpWidget(build({a, c}, onSelect));
      await tester.pump();
      expect(find.text('labelb'), findsNothing);

      // Toggling c reports the resynced state: b is gone, a still selected.
      await tester.tap(find.text('labelc'));
      await tester.pump();
      expect(selected, {a, c});
      expect(unselected, isEmpty);
    });
  });
}
