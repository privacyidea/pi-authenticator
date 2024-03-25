import 'package:json_annotation/json_annotation.dart';
import 'package:privacyidea_authenticator/utils/version.dart';

import '../enums/token_origin_source_type.dart';

part 'token_origin_data.g.dart';

@JsonSerializable()
class TokenOriginData {
  final TokenOriginSourceType source;
  final String? appName;
  final String data;
  final bool? isPrivacyIdeaToken;
  final DateTime createdAt;
  final Version? piServerVersion;
  const TokenOriginData(
      {required this.source, required this.data, required this.isPrivacyIdeaToken, this.appName, required this.createdAt, this.piServerVersion});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokenOriginData && other.source == source && other.appName == appName && other.data == data;
  }

  TokenOriginData copyWith({TokenOriginSourceType? source, String? appName, String? data, bool? isPrivacyIdeaToken, DateTime? createdAt}) => TokenOriginData(
        source: source ?? this.source,
        appName: appName ?? this.appName,
        data: data ?? this.data,
        isPrivacyIdeaToken: isPrivacyIdeaToken ?? this.isPrivacyIdeaToken,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  int get hashCode => Object.hashAll([source, appName, data]);

  // toString prints not data because it contains the secret
  @override
  String toString() => 'TokenOrigin{source: $source, app: $appName, isPrivacyIdeaToken: $isPrivacyIdeaToken, createdAt: $createdAt}';

  factory TokenOriginData.fromJson(Map<String, dynamic> json) => _$TokenOriginDataFromJson(json);

  Map<String, dynamic> toJson() => _$TokenOriginDataToJson(this);
}
