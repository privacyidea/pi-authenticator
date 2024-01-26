import '../../main_netknights.dart';
import '../token_origin.dart';

enum TokenOriginSourceType {
  link,
  manually,
  import,
  unknown,
}

extension TokenSourceTypeExtension on TokenOriginSourceType {
  TokenOrigin toTokenOrigin({String data = ''}) => TokenOrigin(source: this, data: data, appName: PrivacyIDEAAuthenticator.currentCustomization?.appName);
}
