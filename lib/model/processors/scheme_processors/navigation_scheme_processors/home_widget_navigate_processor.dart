import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/processors/scheme_processors/navigation_scheme_processor.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../../../views/link_home_widget_view/link_home_widget_view.dart';

class HomeWidgetNavigateProcessor extends NavigationSchemeProcessor {
  const HomeWidgetNavigateProcessor();

  static final Map<String, Future<void> Function(Uri, BuildContext)> _processors = {
    'link': _linkHomeWidgetProcessor,
  };

  @override
  Future<void> process(Uri uri, {BuildContext? context}) async {
    if (context == null) return;
    Logger.warning('HomeWidgetNavigateProcessor: Processing uri: $uri');
    return _processors[uri.host]?.call(uri, context);
  }

  @override
  Set<String> get supportedSchemes => {'homewidgetnavigate'};

  static Future<void> _linkHomeWidgetProcessor(Uri uri, BuildContext context) async {
    if (uri.host != 'link') return;
    if (uri.queryParameters['id'] == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LinkHomeWidgetView(homeWidgetId: uri.queryParameters['id']!),
      ),
    );
  }
}
