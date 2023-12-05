import '../../../tokens/token.dart';
import '../token_scheme_processor.dart';

class PiaProcessor extends TokenSchemeProcessor {
  const PiaProcessor();
  @override
  Set<String> get supportedSchemes => {'pia'};
  @override
  Future<List<Token>?> process(Uri uri) async => [];
}
