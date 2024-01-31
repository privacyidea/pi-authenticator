import 'package:privacyidea_authenticator/processors/scheme_processors/home_widget_processor.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/navigation_scheme_processors/navigation_scheme_processor_interface.dart';

import 'token_import_scheme_processors/token_import_scheme_processor_interface.dart';

abstract class SchemeProcessor {
  const SchemeProcessor();
  Set<String> get supportedSchemes;
  Future<dynamic> processUri(Uri uri, {bool fromInit = false});

  static final List<SchemeProcessor> implementations = [
    const HomeWidgetProcessor(),
    ...NavigationSchemeProcessor.implementations,
    ...TokenImportSchemeProcessor.implementations,
  ];
  static Future<dynamic> processUriByAny(Uri uri, {bool fromInit = false}) async {
    for (SchemeProcessor processor in implementations) {
      if (processor.supportedSchemes.contains(uri.scheme)) {
        return await processor.processUri(uri);
      }
    }
    return null;
  }
}
