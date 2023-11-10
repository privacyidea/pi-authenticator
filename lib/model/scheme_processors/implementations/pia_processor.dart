import '../../tokens/token.dart';
import '../scheme_processor_interface.dart';

class PiaProcessor extends SchemeProcessor {
  PiaProcessor();
  @override
  Set<String> supportedScheme = {'pia'};
  @override
  Future<List<Token>?> process(Uri uri) async {}
}
