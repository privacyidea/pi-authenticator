import 'token_scheme_processor.dart';

abstract class SchemeProcessor {
  const SchemeProcessor();
  Set<String> get supportedSchemes;
  Future<dynamic> process(Uri uri, {bool fromInit = false});

  static final List<SchemeProcessor> _processors = [
    ...TokenSchemeProcessor.implementations,
  ];
  static Future<dynamic> processUri(Uri uri, {bool fromInit = false}) async {
    for (SchemeProcessor processor in _processors) {
      if (processor.supportedSchemes.contains(uri.scheme)) {
        return await processor.process(uri);
      }
    }
    return null;
  }
}
