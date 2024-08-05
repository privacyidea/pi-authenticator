/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import '../../utils/home_widget_utils.dart';
import '../../utils/logger.dart';
import 'scheme_processor_interface.dart';

class HomeWidgetProcessor implements SchemeProcessor {
  const HomeWidgetProcessor();

  static final Map<String, Future<void> Function(Uri)> _processors = {
    'show': _showProcessor,
    'copy': _copyProcessor,
    'action': _actionProcessor,
  };

  @override
  Future<void> processUri(Uri uri, {bool fromInit = false}) async {
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
