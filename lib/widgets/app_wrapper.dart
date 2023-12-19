import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/riverpod_providers.dart';
import '../utils/riverpod_state_listener.dart';
import 'app_wrappers/single_touch_recognizer.dart';
import 'app_wrappers/state_observer.dart';

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleTouchRecognizer(
      child: ProviderScope(
        child: StateObserver(
          listeners: [
            NavigationDeepLinkListener(deeplinkProvider: deeplinkProvider),
            HomeWidgetTokenStateListener(tokenProvider: tokenProvider),
          ],
          child: EasyDynamicThemeWidget(
            child: child,
          ),
        ),
      ),
    );
  }
}
