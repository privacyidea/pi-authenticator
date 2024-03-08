import '../../mains/main_netknights.dart';
import '../token_origin.dart';
import '../tokens/token.dart';

enum TokenOriginSourceType {
  backupFile,
  qrScan,
  qrFile,
  link,
  manually,
  unknown,
}

extension TokenSourceTypeExtension on TokenOriginSourceType {
  TokenOriginData toTokenOrigin({String data = '', String? appName}) =>
      TokenOriginData(source: this, data: data, appName: appName ?? PrivacyIDEAAuthenticator.currentCustomization?.appName);

  Token addOriginToToken({required Token token, required String data, String? appName}) => token.copyWith(origin: toTokenOrigin(data: data, appName: appName));
}
