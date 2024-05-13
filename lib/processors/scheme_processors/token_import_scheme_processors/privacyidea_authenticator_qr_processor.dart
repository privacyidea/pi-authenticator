import '../../../model/encryption/token_encryption.dart';
import '../../../model/processor_result.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/logger.dart';
import 'token_import_scheme_processor_interface.dart';

class PrivacyIDEAAuthenticatorQrProcessor extends TokenImportSchemeProcessor {
  const PrivacyIDEAAuthenticatorQrProcessor();
  static const scheme = 'pia';
  static const host = 'qrbackup';

  @override
  Set<String> get supportedSchemes => {scheme};

  @override
  Future<List<ProcessorResult<Token>>> processUri(Uri uri, {bool fromInit = false}) async {
    Logger.warning('Processing URI: $uri');
    if (!supportedSchemes.contains(uri.scheme) || uri.host != host) {
      Logger.warning('Unsupported scheme or host');
      return [];
    }

    try {
      final token = TokenEncryption.fromQrCodeUri(uri);

      return [ProcessorResult.success(token)];
    } catch (e) {
      return [ProcessorResult.failed('Invalid URI')];
    }
  }
}
