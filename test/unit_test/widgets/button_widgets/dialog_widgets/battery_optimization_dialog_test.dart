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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/app_dimensions.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/status_colors.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/battery_optimization_dialog.dart';

/// The native side is mocked on the `pi_authenticator/settings` method channel.
/// `defaultTargetPlatform` is switched with `debugDefaultTargetPlatformOverride`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('pi_authenticator/settings');
  final l = AppLocalizationsEn();

  late List<MethodCall> channelLog;
  Future<Object?> Function(MethodCall call) nativeHandler = (_) async => true;

  setUp(() {
    channelLog = [];
    nativeHandler = (_) async => true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          channelLog.add(call);
          return nativeHandler(call);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  List<String> methods() => channelLog.map((c) => c.method).toList();

    // flutter_test verifies that debugDefaultTargetPlatformOverride is unset
    // right after the test body (before tearDown), so reset it in a finally.
    void androidWidgetTest(
      String name,
      Future<void> Function(WidgetTester tester) body,
    ) {
      testWidgets(name, (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        try {
          await body(tester);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: globalNavigatorKey,
          theme: ThemeData(
            extensions: [
              const AppDimensions(),
              StatusColors(
                success: const Color(0xFF4CAF50),
                warning: const Color(0xFFFF9800),
                error: const Color(0xFFF44336),
                neutral: const Color(0xFF9E9E9E),
              ),
            ],
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const ProviderScope(child: Scaffold(body: Text('home'))),
        ),
      );
    }

    group('BatteryOptimizationDialog', () {
      androidWidgetTest('shows title, body and both buttons', (tester) async {
        await pumpApp(tester);

        BatteryOptimizationDialog.showDialog();
        await tester.pumpAndSettle();

        expect(find.text(l.batteryOptimizationTitle), findsOneWidget);
        expect(find.text(l.batteryOptimizationDialogBody), findsOneWidget);
        expect(find.text(l.cancel), findsOneWidget);
        expect(find.text(l.disableButton), findsOneWidget);
        expect(channelLog, isEmpty, reason: 'opening must not talk to native');
      });

      androidWidgetTest('Disable requests the exemption and closes the dialog', (tester) async {
        await pumpApp(tester);
        BatteryOptimizationDialog.showDialog();
        await tester.pumpAndSettle();

        await tester.tap(find.text(l.disableButton));
        await tester.pumpAndSettle();

        expect(methods(), ['requestIgnoreBatteryOptimizations']);
        expect(find.byType(BatteryOptimizationDialog), findsNothing);
        expect(find.text('home'), findsOneWidget);
      });

      androidWidgetTest('Disable still closes the dialog when native fails', (tester) async {
        nativeHandler = (_) async => throw PlatformException(code: 'ERR');
        await pumpApp(tester);
        BatteryOptimizationDialog.showDialog();
        await tester.pumpAndSettle();

        await tester.tap(find.text(l.disableButton));
        await tester.pumpAndSettle();

        expect(methods(), ['requestIgnoreBatteryOptimizations']);
        expect(find.byType(BatteryOptimizationDialog), findsNothing);
      });

      androidWidgetTest('Cancel closes the dialog without calling native', (tester) async {
        await pumpApp(tester);
        BatteryOptimizationDialog.showDialog();
        await tester.pumpAndSettle();

        await tester.tap(find.text(l.cancel));
        await tester.pumpAndSettle();

        expect(channelLog, isEmpty);
        expect(find.byType(BatteryOptimizationDialog), findsNothing);
      });

      androidWidgetTest('showDialog without a mounted navigator completes without showing anything', (tester) async {
        // No app pumped: globalNavigatorKey has no context.
        await expectLater(BatteryOptimizationDialog.showDialog(), completes);
        expect(find.byType(BatteryOptimizationDialog), findsNothing);
      });
    });

    group('BatteryOptimizationAlreadyDisabledDialog', () {
      androidWidgetTest('shows title, body and both buttons', (tester) async {
        await pumpApp(tester);

        BatteryOptimizationAlreadyDisabledDialog.showDialog();
        await tester.pumpAndSettle();

        expect(find.text(l.batteryOptimizationTitle), findsOneWidget);
        expect(find.text(l.batteryOptimizationAlreadyDisabledBody), findsOneWidget);
        expect(find.text(l.ok), findsOneWidget);
        expect(find.text(l.batteryOptimizationSettingsButton), findsOneWidget);
        expect(channelLog, isEmpty);
      });

      androidWidgetTest('settings button opens the battery settings and closes the dialog', (tester) async {
        await pumpApp(tester);
        BatteryOptimizationAlreadyDisabledDialog.showDialog();
        await tester.pumpAndSettle();

        await tester.tap(find.text(l.batteryOptimizationSettingsButton));
        await tester.pumpAndSettle();

        expect(methods(), ['openBatteryOptimizationSettings']);
        expect(find.byType(BatteryOptimizationAlreadyDisabledDialog), findsNothing);
      });

      androidWidgetTest('settings button still closes the dialog when native fails', (tester) async {
        nativeHandler = (_) async => throw PlatformException(code: 'ERR');
        await pumpApp(tester);
        BatteryOptimizationAlreadyDisabledDialog.showDialog();
        await tester.pumpAndSettle();

        await tester.tap(find.text(l.batteryOptimizationSettingsButton));
        await tester.pumpAndSettle();

        expect(methods(), ['openBatteryOptimizationSettings']);
        expect(find.byType(BatteryOptimizationAlreadyDisabledDialog), findsNothing);
      });

      androidWidgetTest('Ok closes the dialog without calling native', (tester) async {
        await pumpApp(tester);
        BatteryOptimizationAlreadyDisabledDialog.showDialog();
        await tester.pumpAndSettle();

        await tester.tap(find.text(l.ok));
        await tester.pumpAndSettle();

        expect(channelLog, isEmpty);
        expect(find.byType(BatteryOptimizationAlreadyDisabledDialog), findsNothing);
      });
    });
}
