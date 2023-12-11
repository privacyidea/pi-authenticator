import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';
import '../utils/riverpod_state_listener.dart';
import '../utils/riverpod_providers.dart';

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: StateObserver(
        listeners: [
          NavigationDeepLinkListener(
              provider: deeplinkProvider, context: globalNavigatorKey.currentContext), // TODO: replace context with a context that provides a Navigator
          //  HomeWidgetDeepLinkListener(provider: deeplinkProvider),
        ],
        child: EasyDynamicThemeWidget(
          child: child,
        ),
      ),
    );
  }
}
