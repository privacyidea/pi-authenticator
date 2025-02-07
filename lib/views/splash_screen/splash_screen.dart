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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../model/enums/app_feature.dart';
import '../../utils/app_info_utils.dart';
import '../../utils/customization/application_customization.dart';
import '../../utils/home_widget_utils.dart';
import '../../utils/logger.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
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
      if (_customization.disabledFeatures.contains(AppFeature.introductions)) {
        ref.read(introductionNotifierProvider.notifier).completeAll();
      }
    });

    Logger.info('Starting app.');
    Future.delayed(_splashScreenDelay, () {
      if (mounted) setState(() => _appIconIsVisible = true);

      Future.wait(
        <Future>[
          Future.delayed(_splashScreenDuration),
          ref.read(tokenProvider.notifier).initState,
          InfoUtils.init(),
          HomeWidgetUtils().homeWidgetInit(),
        ],
        eagerError: true,
        cleanUp: (_) {
          _navigate();
        },
      ).catchError((error) async {
        Logger.error('Error while loading the app.', error: error, stackTrace: StackTrace.current);

        if (!mounted) return [];
        final tokenState = ref.read(tokenProvider);
        ref.read(tokenContainerProvider.notifier).sync(tokenState: tokenState, isManually: false);
        _navigate();
        return [];
      }).then((values) async {
        if (!mounted) return;
        final tokenState = ref.read(tokenProvider);
        ref.read(tokenContainerProvider.notifier).sync(tokenState: tokenState, isManually: false);
        return _navigate();
      });
    });
  }

  @override
  void dispose() {
    Logger.info('Disposing Splash Screen');
    super.dispose();
  }

  void _navigate() async {
    if (_customization.disabledFeatures.isNotEmpty) {
      Logger.info('Disabled features: ${_customization.disabledFeatures}');
    }
    // Idle until the splash screen is the top route.
    // By default it is the top route, but it can be overridden by pushing a new route before initializing the app, e.g. by a deep link.
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      return (ModalRoute.of(context)?.isCurrent == false);
    });
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacementNamed(context, MainView.routeName);
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
