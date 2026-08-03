/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>

  Copyright (c) 2017-2026 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/firebase_options/default_firebase_options.dart';
import 'package:privacyidea_authenticator/mains/app_init.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/localization_notifier.dart';

import '../../../../model/riverpod_states/settings_state.dart';
import '../l10n/app_localizations.dart';
import '../utils/customization/application_customization.dart';
import '../utils/globals.dart';
import '../utils/logger.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/app_constraints_notifier.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../views/splash_screen/splash_screen.dart';
import '../widgets/app_wrapper.dart';
import 'app_routes.dart';

void main() async {
  Logger.init(
    navigatorKey: globalNavigatorKey,
    appRunner: () async {
      await initializeApp();
      appFirebaseOptions = DefaultFirebaseOptions.currentPlatformOf(
        'netknights',
      );
      runApp(
        AppWrapper(
          child: PrivacyIDEAAuthenticator(
            ApplicationCustomization.defaultCustomization,
          ),
        ),
      );
    },
  );
}

class PrivacyIDEAAuthenticator extends ConsumerWidget {
  static ApplicationCustomization? currentCustomization;
  final ApplicationCustomization _customization;

  factory PrivacyIDEAAuthenticator(
    ApplicationCustomization customization, {
    Key? key,
  }) {
    PrivacyIDEAAuthenticator.currentCustomization = customization;
    return PrivacyIDEAAuthenticator._(customization: customization, key: key);
  }
  const PrivacyIDEAAuthenticator._({required this._customization, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    globalRef = ref;
    final routeBuilders = buildAppRoutes(
      _customization,
      includeContainerView: true,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final localizations = AppLocalizations.of(context);
          if (localizations != null) {
            ref.read(localizationProvider.notifier).update(localizations);
          }
          ref.read(appConstraintsProvider.notifier).update(constraints);
        });
        return MaterialApp(
          scrollBehavior: ScrollConfiguration.of(
            context,
          ).copyWith(physics: const ClampingScrollPhysics(), overscroll: false),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale:
              ref
                  .watch(settingsProvider)
                  .whenOrNull(data: (data) => data.currentLocale) ??
              SettingsState.localeDefault,
          title: _customization.appName,
          theme: _customization.generateLightTheme(),
          darkTheme: _customization.generateDarkTheme(),
          scaffoldMessengerKey: globalSnackbarKey,
          navigatorKey: globalNavigatorKey,
          themeMode: EasyDynamicTheme.of(context).themeMode,
          initialRoute: SplashScreen.routeName,
          onGenerateRoute: (settings) {
            final builder = routeBuilders[settings.name];
            if (builder == null) return null;
            return MaterialPageRoute(builder: builder, settings: settings);
          },
          onUnknownRoute: (settings) {
            Logger.warning('MaterialApp.onUnknownRoute ignored spurious route: ${settings.name}');
            return PageRouteBuilder<void>(
              settings: settings,
              opaque: false,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (context, _, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final navigator = Navigator.maybeOf(context);
                  if (navigator?.canPop() == true) navigator!.pop();
                });
                return const SizedBox.shrink();
              },
            );
          },
        );
      },
    );
  }
}
