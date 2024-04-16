import 'package:json_annotation/json_annotation.dart';

import '../version.dart';
import '../enums/token_origin_source_type.dart';

part 'token_origin_data.g.dart';

@JsonSerializable()
class TokenOriginData {
  final TokenOriginSourceType source;
  final String? appName;
  final String data;
  final bool? isPrivacyIdeaToken;
  final DateTime? createdAt;
  final Version? piServerVersion;
  const TokenOriginData._({
    required this.source,
    required this.data,
    this.appName,
    this.isPrivacyIdeaToken,
    this.createdAt,
    this.piServerVersion,
  });

  factory TokenOriginData({
    required TokenOriginSourceType source,
    required String data,
    String? appName,
    bool? isPrivacyIdeaToken,
    DateTime? createdAt,
    Version? piServerVersion,
  }) =>
      TokenOriginData._(
        source: source,
        appName: appName,
        data: data,
        isPrivacyIdeaToken: isPrivacyIdeaToken,
        createdAt: createdAt ?? DateTime.now(),
        piServerVersion: piServerVersion,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokenOriginData && other.source == source && other.appName == appName && other.data == data;
  }

  TokenOriginData copyWith({
    TokenOriginSourceType? source,
    String? data,
    String? appName,
    bool? isPrivacyIdeaToken,
    DateTime? createdAt,
    Version? piServerVersion,
  }) =>
      TokenOriginData(
        source: source ?? this.source,
        appName: appName ?? this.appName,
        data: data ?? this.data,
        isPrivacyIdeaToken: isPrivacyIdeaToken ?? this.isPrivacyIdeaToken,
        createdAt: createdAt ?? this.createdAt,
        piServerVersion: piServerVersion ?? this.piServerVersion,
      );

  @override
  int get hashCode => Object.hashAll([source, appName, data]);

  // toString prints not data because it contains the secret
  @override
  String toString() => 'TokenOrigin{source: $source, app: $appName, isPrivacyIdeaToken: $isPrivacyIdeaToken, createdAt: $createdAt, data: $data';

  factory TokenOriginData.fromJson(Map<String, dynamic> json) => _$TokenOriginDataFromJson(json);

  Map<String, dynamic> toJson() => _$TokenOriginDataToJson(this);
}
