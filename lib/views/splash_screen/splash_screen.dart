import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/platform_info/platform_info_imp/package_info_plus_platform_info.dart';
import '../../utils/riverpod_providers.dart';
import '../main_view/main_view.dart';
import '../onboarding_view/onboarding_view.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const routeName = '/';

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
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      ref.read(platformInfoProvider.notifier).state = await PackageInfoPlusPlatformInfo.loadInfos();
    }
    await Future.delayed(_splashScreenDuration + _splashScreenDelay * 2);
    final isFirstRun = ref.read(settingsProvider).isFirstRun;
    final ConsumerStatefulWidget nextView;
    if (isFirstRun) {
      nextView = const OnboardingView();
    } else {
      nextView = const MainView();
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
    final applicationCustomizer = ref.read(applicationCustomizerProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: AnimatedOpacity(
          opacity: _appIconIsVisible ? 1.0 : 0.0,
          duration: _splashScreenDuration,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: applicationCustomizer.appImage,
          ),
        ),
      ),
    );
  }
}
