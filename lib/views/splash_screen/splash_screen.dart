/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/allow_screenshot_notifier.dart';

import '../../../../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../model/enums/app_feature.dart';
import '../../model/riverpod_states/token_state.dart';
import '../../utils/app_info_utils.dart';
import '../../utils/customization/application_customization.dart';
import '../../utils/home_widget_utils.dart';
import '../../utils/logger.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../main_view/main_view.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const routeName = '/';
  final ApplicationCustomization customization;
  const SplashScreen({required this.customization, super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  var _appIconIsVisible = false;
  final _splashScreenDuration = const Duration(milliseconds: 400);
  final _splashScreenDelay = const Duration(milliseconds: 250);
  late final ApplicationCustomization _customization;

  @override
  void initState() {
    super.initState();
    _customization = widget.customization;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_customization.disabledFeatures.contains(AppFeature.introductions)) {
        ref.read(introductionNotifierProvider.notifier).completeAll();
      }
    });

    Logger.info('Starting app.');
    unawaited(_startApp());
  }

  /// Shows the app icon, loads everything the app needs and navigates to the
  /// main view afterwards. Navigation happens exactly once, also when loading
  /// or syncing failed.
  Future<void> _startApp() async {
    await Future.delayed(_splashScreenDelay);
    if (!mounted) return;
    setState(() => _appIconIsVisible = true);

    try {
      await Future.wait(<Future>[
        Future.delayed(_splashScreenDuration),
        ref.read(tokenProvider.future),
        AppInfoUtils.init(),
        HomeWidgetUtils().homeWidgetInit(),
        ref.read(allowScreenshotProvider.future),
        ref.read(tokenFolderProvider.notifier).initState,
      ], eagerError: true);
    } catch (e, s) {
      Logger.error('Error while loading the app.', error: e, stackTrace: s);
    }
    if (!mounted) return;

    try {
      final tokenState = await ref.read(tokenProvider.future);
      if (mounted) unawaited(_syncContainers(tokenState));
    } catch (e, s) {
      Logger.error(
        'Error while loading the token state.',
        error: e,
        stackTrace: s,
      );
    }

    try {
      await _navigate();
    } catch (e, s) {
      Logger.error(
        'Error while navigating to the main view.',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Syncs the token containers. Runs in the background so that starting the
  /// app is not delayed by it.
  Future<void> _syncContainers(TokenState tokenState) async {
    try {
      await ref
          .read(tokenContainerProvider.notifier)
          .syncContainers(tokenState: tokenState, isManually: false);
    } catch (e, s) {
      Logger.error('Error while syncing containers.', error: e, stackTrace: s);
    }
  }

  @override
  void dispose() {
    Logger.info('Disposing Splash Screen');
    super.dispose();
  }

  Future<void> _navigate() async {
    if (_customization.disabledFeatures.isNotEmpty) {
      Logger.info('Disabled features: ${_customization.disabledFeatures}');
    }
    if (!mounted) return;
    final splashRoute = ModalRoute.of(context);
    // Idle until the splash screen is the top route.
    // By default it is the top route, but it can be overridden by pushing a new route before initializing the app, e.g. by a deep link.
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      return (ModalRoute.of(context)?.isCurrent == false);
    });
    if (!mounted) return;
    if (splashRoute == null || splashRoute.isCurrent) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacementNamed(context, MainView.routeName);
    } else {
      Navigator.of(context).removeRoute(splashRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: AnimatedOpacity(
          opacity: _appIconIsVisible ? 1.0 : 0.0,
          duration: _splashScreenDuration,
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SizedBox(
              height: 99999,
              width: 99999,
              child: _customization.splashScreenImage.getWidget,
            ),
          ),
        ),
      ),
    );
  }
}
