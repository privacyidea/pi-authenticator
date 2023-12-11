import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../../utils/customizations.dart';
import '../scheme_processor_interface.dart';
import 'navigation_scheme_processors/home_widget_navigate_processor.dart';

abstract class NavigationSchemeProcessor implements SchemeProcessor {
  const NavigationSchemeProcessor();

  static Set<NavigationSchemeProcessor> implementations = {
    HomeWidgetNavigateProcessor(),
  };

  @override
  Future<void> process(Uri uri, {BuildContext? context});

  static Future<void> processUri(Uri uri, {BuildContext? context}) async {
    if (context == null) {
      Logger.info('Current context is null, waiting for navigator context', name: 'processUri#NavigationSchemeProcessor');
      final key = await contextedGlobalNavigatorKey;
      context = key.currentContext;
    }
    Logger.info('Processing scheme: ${uri.scheme}', name: 'processUri#NavigationSchemeProcessor');
    final futures = <Future<void>>[];
    for (final processor in implementations) {
      Logger.info('Supported schemes [${processor.supportedSchemes}] for processor ${processor.runtimeType}', name: 'processUri#NavigationSchemeProcessor');
      if (processor.supportedSchemes.contains(uri.scheme)) {
        Logger.info('Processing scheme ${uri.scheme} with ${processor.runtimeType}', name: 'processUri#NavigationSchemeProcessor');
        // ignoring use_build_context_synchronously is ok because we got the context after the await. The Context cannot be expired.
        // ignore: use_build_context_synchronously
        futures.add(processor.process(uri, context: context));
      }
    }
    await Future.wait(futures);
    return;
  }
}
