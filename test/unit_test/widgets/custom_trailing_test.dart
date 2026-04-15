import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/widgets/custom_trailing.dart';

void main() {
  group('CustomTrailing Tests', () {
    testWidgets('respects maxPixelsWidth when parent is large', (tester) async {
      const double maxPixels = 50.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 1000, // Very wide parent
                child: CustomTrailing(
                  maxPixelsWidth: maxPixels,
                  maxPercentWidth: 20, // 20% of 1000 = 200
                  child: SizedBox(width: 100, height: 100),
                ),
              ),
            ),
          ),
        ),
      );

      final containerFinder = find
          .descendant(
            of: find.byType(CustomTrailing),
            matching: find.byType(SizedBox),
          )
          .first;

      final SizedBox sizedBox = tester.widget(containerFinder);
      expect(sizedBox.width, maxPixels);
      expect(sizedBox.height, maxPixels);
    });

    testWidgets('respects maxPercentWidth when parent is small', (
      tester,
    ) async {
      const double parentWidth = 200.0;
      const double percent = 10.0; // 10% of 200 = 20

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: parentWidth,
                child: CustomTrailing(
                  maxPercentWidth: percent,
                  maxPixelsWidth: 100,
                  child: SizedBox(width: 50, height: 50),
                ),
              ),
            ),
          ),
        ),
      );

      final containerFinder = find
          .descendant(
            of: find.byType(CustomTrailing),
            matching: find.byType(SizedBox),
          )
          .first;

      final SizedBox sizedBox = tester.widget(containerFinder);
      expect(sizedBox.width, 20.0);
      expect(sizedBox.height, 20.0);
    });

    testWidgets('uses default values when none are provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 1000,
                child: CustomTrailing(child: Icon(Icons.check, size: 24)),
              ),
            ),
          ),
        ),
      );

      final containerFinder = find
          .descendant(
            of: find.byType(CustomTrailing),
            matching: find.byType(SizedBox),
          )
          .first;

      final SizedBox sizedBox = tester.widget(containerFinder);
      // Default maxPixelsWidth is 85
      expect(sizedBox.width, 85.0);
    });

    testWidgets('applies right padding from dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CustomTrailing(child: Text('Padding Test'))),
        ),
      );

      // Verify the Padding widget exists inside the CustomTrailing
      final Padding paddingWidget = tester.widget(
        find.descendant(
          of: find.byType(CustomTrailing),
          matching: find.byType(Padding),
        ),
      );

      expect(paddingWidget.padding, isInstanceOf<EdgeInsets>());
      expect((paddingWidget.padding as EdgeInsets).right, isNonNegative);
    });

    testWidgets('wraps child in FittedBox with correct fit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTrailing(fit: BoxFit.cover, child: Icon(Icons.add)),
          ),
        ),
      );

      // Verify FittedBox property
      final FittedBox fittedBox = tester.widget(
        find.descendant(
          of: find.byType(CustomTrailing),
          matching: find.byType(FittedBox),
        ),
      );

      expect(fittedBox.fit, BoxFit.cover);
    });
  });
}
