import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../scheme_processor_interface.dart';
import 'navigation_scheme_processors/home_widget_navigate_processor.dart';

abstract class NavigationSchemeProcessor implements SchemeProcessor {
  const NavigationSchemeProcessor();
  static const Set<NavigationSchemeProcessor> implementations = {
    HomeWidgetNavigateProcessor(),
  };

  @override
  Future<void> process(Uri uri, {BuildContext? context});

  static Future<void> processUri(Uri uri, {BuildContext? context}) async {
    for (NavigationSchemeProcessor processor in implementations) {
      Logger.warning('Supported schemes: ${processor.supportedSchemes}');
      if (processor.supportedSchemes.contains(uri.scheme)) {
        Logger.warning('Processing uri: $uri');
        return await processor.process(uri, context: context);
      }
    }
  }
}
