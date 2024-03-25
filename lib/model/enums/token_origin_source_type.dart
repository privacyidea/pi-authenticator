import '../../mains/main_netknights.dart';
import '../token_import/token_origin_data.dart';
import '../tokens/token.dart';

enum TokenOriginSourceType {
  backupFile,
  qrScan,
  qrFile,
  qrScanImport,
  link,
  linkImport,
  manually,
  unknown,
}

extension TokenSourceTypeX on TokenOriginSourceType {
  TokenOriginData toTokenOrigin({String data = '', String? appName, bool? isPrivacyIdeaToken, DateTime? createdAt}) => TokenOriginData(
        source: this,
        data: data,
        appName: appName ?? PrivacyIDEAAuthenticator.currentCustomization?.appName,
        isPrivacyIdeaToken: isPrivacyIdeaToken,
        createdAt: createdAt ?? DateTime.now(),
      );

  Token addOriginToToken({required Token token, required String data, required bool? isPrivacyIdeaToken, String? appName, DateTime? createdAt}) =>
      token.copyWith(origin: toTokenOrigin(data: data, appName: appName, isPrivacyIdeaToken: isPrivacyIdeaToken, createdAt: createdAt));
}
