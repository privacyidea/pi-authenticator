import '../../main_netknights.dart';
import '../token_origin.dart';

enum TokenOriginSourceType {
  backupFile,
  link,
  manually,
  unknown,
}

extension TokenSourceTypeExtension on TokenOriginSourceType {
  TokenOriginData toTokenOrigin({String data = ''}) =>
      TokenOriginData(source: this, data: data, appName: PrivacyIDEAAuthenticator.currentCustomization?.appName);
}
