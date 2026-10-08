import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/mains/main_customizer.dart';
import 'package:privacyidea_authenticator/model/enums/app_feature.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import 'package:privacyidea_authenticator/views/splash_screen/splash_screen.dart';

import '../../tests_app_wrapper.dart';

class _FakeIntroductionNotifier extends IntroductionNotifier {
  int completeAllCalls = 0;

  @override
  Future<IntroductionState> build({required repo}) async =>
      const IntroductionState();

  @override
  Future<void> completeAll() async {
    completeAllCalls++;
    state = AsyncValue.data(IntroductionState.withAllCompleted());
  }
}

void main() {
  final customization = ApplicationCustomization.defaultCustomization;

  group('CustomizationAuthenticator onUnknownRoute', () {
    late _FakeIntroductionNotifier introductionNotifier;

    setUp(() async {
      await setupMocks();
      introductionNotifier = _FakeIntroductionNotifier();
    });

    // Only the first moments of the splash screen are run: it counts itself
    // with introductionNotifier.completeAll() in its first post frame callback
    // when the introductions feature is disabled, and navigates to the (heavy)
    // main view only after 650 ms.
    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            introductionNotifierProvider.overrideWith(
              () => introductionNotifier,
            ),
          ],
          child: EasyDynamicThemeWidget(
            initialThemeMode: ThemeMode.system,
            child: CustomizationAuthenticator(
              initialCustomization: customization.copyWith(
                disabledFeatures: {AppFeature.introductions},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }

    Future<void> shutDown(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      // let the pending 250 ms delays of the splash screens run out
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('the app starts on exactly one splash screen', (tester) async {
      await pumpApp(tester);

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(introductionNotifier.completeAllCalls, 1);

      await shutDown(tester);
    });

    testWidgets('an unknown route is shown as a splash screen', (tester) async {
      await pumpApp(tester);

      globalNavigatorKey.currentState!.pushNamed('/does-not-exist');
      await tester.pump(const Duration(milliseconds: 50));

      // Characterization: the unknown route is answered with a new SplashScreen
      // (instead of being ignored like in main_netknights.dart).
      expect(find.byType(SplashScreen, skipOffstage: false), findsNWidgets(2));

      await shutDown(tester);
    });

    testWidgets(
      'an unknown route does not start the app a second time',
      (tester) async {
        await pumpApp(tester);

        globalNavigatorKey.currentState!.pushNamed('/does-not-exist');
        await tester.pump(const Duration(milliseconds: 50));

        // Every SplashScreen runs _startApp (load, home widget init, container
        // sync, navigation) in its initState, so a second one starts the app
        // a second time.
        expect(introductionNotifier.completeAllCalls, 1);

        await shutDown(tester);
      },
      skip:
          true, // BUG: main_customizer.dart:96 onUnknownRoute builds a new SplashScreen whose initState runs _startApp a second time (main_netknights.dart ignores unknown routes)
    );
  });
}
