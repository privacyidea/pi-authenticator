/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>

  Copyright (c) 2017-2023 NetKnights GmbH

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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/platform_info/platform_info_imp/package_info_plus_platform_info.dart';
import 'package:privacyidea_authenticator/utils/app_customizer.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/themes.dart';
import 'package:privacyidea_authenticator/views/add_token_manually_view/add_token_manually_view.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view.dart';
import 'package:privacyidea_authenticator/views/onboarding_view/onboarding_view.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  Logger.init(appRunner: () async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const AppWrapper(child: PrivacyIDEAAuthenticator()));
  });
}

class PrivacyIDEAAuthenticator extends ConsumerWidget {
  const PrivacyIDEAAuthenticator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    globalRef = ref;
    final state = ref.watch(settingsProvider);
    final locale = state.currentLocale;
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      navigatorKey: Logger.navigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      title: ApplicationCustomizer.appName,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      scaffoldMessengerKey: snackbarKey, // <= this
      themeMode: EasyDynamicTheme.of(context).themeMode,
      initialRoute: SplashScreen.routeName,
      routes: {
        MainView.routeName: (context) => const MainView(title: ApplicationCustomizer.appName),
        SplashScreen.routeName: (context) => const SplashScreen(),
        OnboardingView.routeName: (context) => const OnboardingView(),
        SettingsView.routeName: (context) => const SettingsView(),
        AddTokenManuallyView.routeName: (context) => const AddTokenManuallyView(),
      },
    );
  }
}

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: EasyDynamicThemeWidget(child: child),
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  static const routeName = '/splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  var _appIconIsVisible = false;
  final _splashScreenDuration = const Duration(milliseconds: 400);
  final _splashScreenDelay = const Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();

    Future.delayed(_splashScreenDelay, () {
      if (mounted) {
        setState(() {
          _appIconIsVisible = true;
        });
      }
    });
    _init();
  }

  Future<void> _init() async {
    ref.read(platformInfoProvider.notifier).state = await PackageInfoPlusPlatformInfo.loadInfos();
    ref.read(sharedPreferencesProvider.notifier).state = await SharedPreferences.getInstance();
    await Future.delayed(_splashScreenDuration + _splashScreenDelay * 2);
    final isFirstRun = ref.read(settingsProvider).isFirstRun;
    final ConsumerStatefulWidget nextView;
    if (isFirstRun) {
      nextView = const OnboardingView();
    } else {
      nextView = const MainView(
        title: ApplicationCustomizer.appName,
      );
    }
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextView,
        transitionDuration: _splashScreenDuration * 2,
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _appIconIsVisible ? 1.0 : 0.0,
          curve: Curves.easeInOut,
          duration: _splashScreenDuration,
          child: Image.asset(
            ApplicationCustomizer.appIcon,
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
