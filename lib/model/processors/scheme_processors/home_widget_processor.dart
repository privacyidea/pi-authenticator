import '../scheme_processor_interface.dart';
import '../../../utils/home_widget_utils.dart';
import '../../../utils/logger.dart';

class HomeWidgetProcessor extends SchemeProcessor {
  const HomeWidgetProcessor();

  static final Map<String, Future<void> Function(Uri)> _processors = {
    'show': _showProcessor,
    'copy': _copyProcessor,
    'action': _actionProcessor,
  };

  @override
  Future<void> process(Uri uri, {bool fromInit = false}) async {
    Logger.warning('HomeWidgetProcessor: Processing uri: $uri');
    if (supportedSchemes.contains(uri.scheme) == false) return;
    return _processors[uri.host]?.call(uri);
  }

  @override
  Set<String> get supportedSchemes => {'homewidget'};

  static Future<void> _showProcessor(Uri uri, {bool fromInit = false}) async {
    Logger.warning('HomeWidgetProcessor: Processing uri show: $uri');
    if (uri.host != 'show') return;
    final widgetId = uri.queryParameters['widgetId'];
    if (widgetId == null) return;
    return HomeWidgetUtils().showOtp(widgetId);
  }

  static Future<void> _copyProcessor(Uri uri, {bool fromInit = false}) async {
    Logger.warning('HomeWidgetProcessor: Processing uri copy: $uri');
    if (uri.host != 'copy') return;
    final widgetId = uri.queryParameters['widgetId'];
    if (widgetId == null) return;
    return HomeWidgetUtils().copyOtp(widgetId);
  }

  static Future<void> _actionProcessor(Uri uri, {bool fromInit = false}) async {
    Logger.warning('HomeWidgetProcessor: Processing uri action: $uri');
    if (uri.host != 'action') return;
    final widgetId = uri.queryParameters['widgetId'];
    if (widgetId == null) return;
    return HomeWidgetUtils().performAction(widgetId);
  }
}
