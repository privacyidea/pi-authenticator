import '../../../mains/main_netknights.dart';
import '../../enums/token_origin_source_type.dart';
import '../../token_import/token_origin_data.dart';
import '../../tokens/token.dart';

extension TokenSourceTypeX on TokenOriginSourceType {
  TokenOriginData toTokenOrigin({String data = '', String? appName, bool? isPrivacyIdeaToken, DateTime? createdAt}) => TokenOriginData(
        source: this,
        data: data,
        appName: appName ?? PrivacyIDEAAuthenticator.currentCustomization?.appName,
        isPrivacyIdeaToken: isPrivacyIdeaToken,
        createdAt: createdAt ?? DateTime.now(),
      );

  T addOriginToToken<T extends Token>({required T token, required String data, required bool? isPrivacyIdeaToken, String? appName, DateTime? createdAt}) =>
      token.copyWith(origin: toTokenOrigin(data: data, appName: appName, isPrivacyIdeaToken: isPrivacyIdeaToken, createdAt: createdAt)) as T;
}
