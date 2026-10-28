import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:privacyidea_authenticator/views/qr_scanner_view/qr_scanner_view_widgets/qr_scanner_widget.dart';

import '../../../tests_app_wrapper.dart';

void main() {
  // QRScannerWidget replaces ErrorWidget.builder while it builds; the test
  // binding requires the default back at the end of every test body.
  final defaultErrorWidgetBuilder = ErrorWidget.builder;
  void restoreErrorWidgetBuilder() =>
      ErrorWidget.builder = defaultErrorWidgetBuilder;

  group('QRScannerWidget gallery button', () {
    testWidgets('a second tap while the picker is open does not open it again', (
      tester,
    ) async {
      final picks = <Completer<XFile?>>[];
      await tester.pumpWidget(
        TestsAppWrapper(
          child: QRScannerWidget(
            pickImage: () {
              final pick = Completer<XFile?>();
              picks.add(pick);
              return pick.future;
            },
            readQrCode: (_) async => Code(),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.image));
      await tester.tap(find.byIcon(Icons.image));
      await tester.pump();
      expect(picks, hasLength(1));

      picks.single.complete(null);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.image));
      await tester.pump();
      expect(picks, hasLength(2), reason: 'a closed picker opens again');
      picks.last.complete(null);
      await tester.pump();
      restoreErrorWidgetBuilder();
    });

    testWidgets('a QR code in the picked image closes the scanner with its text', (
      tester,
    ) async {
      const uri = 'otpauth://totp/gallery?secret=JBSWY3DPEHPK3PXP';
      String? result;
      await tester.pumpWidget(
        _opener((value) => result = value, Code(text: uri, isValid: true)),
      );
      await _openScanner(tester);

      await tester.tap(find.byIcon(Icons.image));
      await _settleRoute(tester);

      expect(result, uri);
      expect(find.byType(QRScannerWidget), findsNothing);
      restoreErrorWidgetBuilder();
    });

    testWidgets('an image without a QR code keeps the scanner open', (
      tester,
    ) async {
      String? result;
      await tester.pumpWidget(_opener((value) => result = value, Code()));
      await _openScanner(tester);

      await tester.tap(find.byIcon(Icons.image));
      await _settleRoute(tester);

      expect(result, isNull);
      expect(find.byType(QRScannerWidget), findsOneWidget);
      restoreErrorWidgetBuilder();
    });
  });
}

/// A page with a button that pushes the scanner and hands its result to
/// [onResult]; the scanner reads [readResult] from every picked image.
Widget _opener(void Function(String?) onResult, Code readResult) =>
    TestsAppWrapper(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () async => onResult(
            await Navigator.of(context).push<String>(
              MaterialPageRoute(
                builder: (_) => QRScannerWidget(
                  pickImage: () async => XFile('picked.png'),
                  readQrCode: (_) async => readResult,
                ),
              ),
            ),
          ),
          child: const Text('open'),
        ),
      ),
    );

Future<void> _openScanner(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await _settleRoute(tester);
}

/// A push or pop: the first frame starts the route transition, the second
/// one, 500 ms later, ends it.
Future<void> _settleRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}
