/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/mains/app_init.dart';

import '../../../../../../../utils/customization/application_customization.dart';
import '../l10n/app_localizations.dart';
import '../model/riverpod_states/settings_state.dart';
import '../utils/globals.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/app_constraints_notifier.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/app_customization_notifier.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../views/splash_screen/splash_screen.dart';
import '../widgets/app_wrapper.dart';
import 'app_routes.dart';

void main() async {
  await initializeApp();
  runApp(
    AppWrapper(
      child: CustomizationAuthenticator(
        initialCustomization: ApplicationCustomization.defaultCustomization,
      ),
    ),
  );
}

class CustomizationAuthenticator extends ConsumerWidget {
  final ApplicationCustomization initialCustomization;
  const CustomizationAuthenticator({
    required this.initialCustomization,
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationCustomizer = ref
        .watch(appCustomizationProvider)
        .maybeWhen(data: (data) => data, orElse: () => initialCustomization);
    final routeBuilders = buildAppRoutes(applicationCustomizer);
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async =>
              ref.read(appConstraintsProvider.notifier).update(constraints),
        );
        return MaterialApp(
          scrollBehavior: ScrollConfiguration.of(context).copyWith(
            physics: const ClampingScrollPhysics(),
            overscroll: false,
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
            },
          ),
          navigatorKey: globalNavigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale:
              ref
                  .watch(settingsProvider)
                  .whenOrNull(data: (data) => data.currentLocale) ??
              SettingsState.localeDefault,
          title: applicationCustomizer.appName,
          theme: applicationCustomizer.generateLightTheme(),
          darkTheme: applicationCustomizer.generateDarkTheme(),
          scaffoldMessengerKey: globalSnackbarKey,
          themeMode: EasyDynamicTheme.of(context).themeMode,
          initialRoute: SplashScreen.routeName,
          onGenerateRoute: (settings) {
            final builder = routeBuilders[settings.name];
            if (builder == null) return null;
            return MaterialPageRoute(builder: builder, settings: settings);
          },
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (context) =>
                SplashScreen(customization: applicationCustomizer),
          ),
        );
      },
    );
  }
}
