import '../../../utils/utils.dart';
import '../../enums/token_origin_source_type.dart';
import '../../token_import/token_origin_data.dart';
import '../../tokens/token.dart';
import '../../version.dart';

extension TokenSourceTypeX on TokenOriginSourceType {
  TokenOriginData _toTokenOrigin({
    String data = '',
    String? originName,
    bool? isPrivacyIdeaToken,
    DateTime? createdAt,
    String? creator,
    Version? piServerVersion,
  }) =>
      TokenOriginData(
        source: this,
        data: data,
        appName: originName ?? getCurrentAppName(),
        isPrivacyIdeaToken: isPrivacyIdeaToken,
        createdAt: createdAt ?? DateTime.now(),
        creator: creator,
        piServerVersion: piServerVersion,
      );

  TokenOriginData toTokenOrigin({
    String data = '',
    String? originName,
    bool? isPrivacyIdeaToken,
    DateTime? createdAt,
    String? creator,
    Version? piServerVersion,
  }) =>
      _toTokenOrigin(
        data: data,
        originName: originName,
        isPrivacyIdeaToken: isPrivacyIdeaToken,
        createdAt: createdAt,
        creator: creator,
        piServerVersion: piServerVersion,
      );

  T addOriginToToken<T extends Token>({
    required T token,
    required String data,
    required bool? isPrivacyIdeaToken,
    String? appName,
    DateTime? createdAt,
    String? creator,
    Version? piServerVersion,
  }) =>
      token.copyWith(
          origin: _toTokenOrigin(
        data: data,
        originName: appName,
        isPrivacyIdeaToken: isPrivacyIdeaToken,
        createdAt: createdAt,
        creator: creator,
        piServerVersion: piServerVersion,
      )) as T;
}
