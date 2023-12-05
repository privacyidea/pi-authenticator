import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/processors/scheme_processors/navigation_scheme_processor.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../utils/customizations.dart';
import '../utils/riverpod_providers.dart';

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: DeepLinkNavigator(
          child: EasyDynamicThemeWidget(
        child: child,
      )),
    );
  }
}

class DeepLinkNavigator extends ConsumerWidget {
  final Widget child;

  const DeepLinkNavigator({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uri = ref.watch(deeplinkProvider);
    Logger.warning('DeepLinkNavigator: $uri');
    if (uri != null) NavigationSchemeProcessor.processUri(uri, context: globalNavigatorKey.currentContext);
    return child;
  }
}
