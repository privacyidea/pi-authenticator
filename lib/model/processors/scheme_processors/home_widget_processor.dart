import 'package:privacyidea_authenticator/model/processors/scheme_processor_interface.dart';
import 'package:privacyidea_authenticator/utils/home_widget_utils.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

class HomeWidgetProcessor extends SchemeProcessor {
  const HomeWidgetProcessor();

  static final Map<String, Future<void> Function(Uri)> _processors = {
    'show': _showProcessor,
  };

  @override
  Future<void> process(Uri uri) async {
    Logger.warning('HomeWidgetProcessor: Processing uri: $uri');
    if (supportedSchemes.contains(uri.scheme) == false) return;
    return _processors[uri.host]?.call(uri);
  }

  @override
  Set<String> get supportedSchemes => {'homewidget'};

  static Future<void> _showProcessor(Uri uri) async {
    Logger.warning('HomeWidgetProcessor: Processing uri: $uri');
    if (uri.host != 'show') return;
    final widgetId = uri.queryParameters['widgetId'];
    final tokenId = uri.queryParameters['tokenId'];
    if (widgetId == null || tokenId == null) return;
    return homeWidgetShowOtp(widgetId, tokenId);
  }
}
