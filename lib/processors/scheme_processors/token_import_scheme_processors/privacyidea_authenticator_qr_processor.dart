import '../../../model/processor_result.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/encryption/token_encryption.dart';
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
    if (!supportedSchemes.contains(uri.scheme) || uri.host != host) {
      Logger.warning('Unsupported scheme or host');
      return [];
    }
    Logger.info('Processing URI with scheme: ${uri.scheme}', name: 'PrivacyIDEAAuthenticatorQrProcessor#processUri');
    try {
      final token = TokenEncryption.fromExportUri(uri);
      Logger.info('Processing URI ${uri.scheme} succeded', name: 'PrivacyIDEAAuthenticatorQrProcessor#processUri');
      return [ProcessorResult.success(token)];
    } catch (e) {
      Logger.error('Error while processing URI ${uri.scheme}', error: e, name: 'PrivacyIDEAAuthenticatorQrProcessor#processUri');
      return [ProcessorResult.failed('Invalid URI')];
    }
  }
}
