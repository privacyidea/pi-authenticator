import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';

import '../../../mains/main_netknights.dart';
import '../../enums/token_origin_source_type.dart';
import '../../token_import/token_origin_data.dart';
import '../../tokens/token.dart';
import '../../version.dart';

extension TokenSourceTypeX on TokenOriginSourceType {
  TokenOriginData toTokenOrigin({
    String data = '',
    String? originName,
    bool? isPrivacyIdeaToken,
    DateTime? createdAt,
    String? creator,
    Version? piServerVersion,
  }) {
    return TokenOriginData(
      source: this,
      data: data,
      originName: originName ?? PrivacyIDEAAuthenticator.currentCustomization?.appName ?? ApplicationCustomization.defaultCustomization.appName,
      isPrivacyIdeaToken: isPrivacyIdeaToken,
      createdAt: createdAt ?? DateTime.now(),
      creator: creator,
      piServerVersion: piServerVersion,
    );
  }

  T addOriginToToken<T extends Token>({
    required T token,
    required String data,
    required bool? isPrivacyIdeaToken,
    String? appName,
    DateTime? createdAt,
    String? creator,
    Version? piServerVersion,
  }) {
    return token.copyWith(
        origin: toTokenOrigin(
      data: data,
      originName: appName,
      isPrivacyIdeaToken: isPrivacyIdeaToken,
      createdAt: createdAt,
      creator: creator,
      piServerVersion: piServerVersion,
    )) as T;
  }
}
