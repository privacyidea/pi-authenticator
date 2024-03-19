import 'otp_auth_processor.dart';

import '../../../model/processor_result.dart';
import '../../../model/tokens/token.dart';

class FreeOtpPlusQrProcessor extends OtpAuthProcessor {
  static const String _steamTokenIssuer = "Steam";
  static const String _steamTokenHost = "steam";
  const FreeOtpPlusQrProcessor();

  @override
  Future<List<ProcessorResult<Token>>> processUri(Uri uri, {bool fromInit = false}) => _processOtpAuth(uri);

  Future<List<ProcessorResult<Token>>> _processOtpAuth(Uri uri) async {
    final results = <ProcessorResult<Token>>[];

    final issuer = _parseIssuer(uri);
    if (issuer == _steamTokenIssuer) {
      uri = uri.replace(host: _steamTokenHost);
    }
    final result = await super.processUri(uri);
    results.addAll(result);

    return results;
  }

  /// Parse the label and the issuer (if it exists) from the url.
  String _parseIssuer(Uri uri) {
    String param = uri.path.substring(1);
    param = Uri.decodeFull(param);
    try {
      if (param.contains(':')) {
        List split = param.split(':');
        return split[0];
      } else {
        return _parseIssuer(uri);
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Set<String> get supportedSchemes => const OtpAuthProcessor().supportedSchemes;
}
