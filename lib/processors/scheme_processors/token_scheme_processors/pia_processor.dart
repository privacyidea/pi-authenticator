import '../../../model/tokens/token.dart';
import 'token_scheme_processor_interface.dart';

class PiaProcessor extends TokenSchemeProcessor {
  const PiaProcessor();
  @override
  Set<String> get supportedSchemes => {'pia'};

  @override
  Future<List<Token>> processUri(Uri uri, {bool fromInit = false}) async => [];
}
