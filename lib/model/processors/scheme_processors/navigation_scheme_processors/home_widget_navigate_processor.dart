import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import '../../../../views/splash_screen/splash_screen.dart';

import '../../../../utils/logger.dart';
import '../../../../views/link_home_widget_view/link_home_widget_view.dart';
import '../navigation_scheme_processor.dart';

class HomeWidgetNavigateProcessor extends NavigationSchemeProcessor {
  HomeWidgetNavigateProcessor();

  static final Map<String, Future<void> Function(Uri, BuildContext, {bool fromInit})> _processors = {
    'link': _linkHomeWidgetProcessor,
  };

  @override
  Future<void> process(Uri uri, {BuildContext? context, bool fromInit = false}) async {
    if (context == null) {
      Logger.error('HomeWidgetNavigateProcessor: Cannot Navigate without context',
          error: const InvalidConfigException('context is null'), stackTrace: StackTrace.current);
      return;
    }
    Logger.warning('HomeWidgetNavigateProcessor: Processing uri: $uri');
    return _processors[uri.host]?.call(uri, context, fromInit: fromInit);
  }

  @override
  Set<String> get supportedSchemes => {'homewidgetnavigate'};

  static Future<void> _linkHomeWidgetProcessor(Uri uri, BuildContext context, {bool fromInit = false}) async {
    if (uri.host != 'link') {
      Logger.warning('HomeWidgetNavigateProcessor: Invalid host for link: ${uri.host}');
      return;
    }
    if (uri.queryParameters['id'] == null) {
      Logger.warning('HomeWidgetNavigateProcessor: Invalid query parameters for link: ${uri.queryParameters}');
      return;
    }
    if (fromInit) {
      SplashScreen.setInitialView(
        LinkHomeWidgetView(homeWidgetId: uri.queryParameters['id']!),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LinkHomeWidgetView(homeWidgetId: uri.queryParameters['id']!),
        ),
      );
    }
  }
}
