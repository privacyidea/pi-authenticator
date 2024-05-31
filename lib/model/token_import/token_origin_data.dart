import 'package:json_annotation/json_annotation.dart';

import '../enums/token_origin_source_type.dart';
import '../version.dart';

part 'token_origin_data.g.dart';

@JsonSerializable()
class TokenOriginData {
  final TokenOriginSourceType source;
  final String appName; // Name of the app where the token comes from.
  final String data; // The data that was used to create the token. Contains the secret!!
  final DateTime createdAt; // The time when the token was created. If imported from another app, this is the time of the import
  final bool? isPrivacyIdeaToken; // True if the token was created by a privacyIDEA server. Null if unknown. False if not created by a privacyIDEA server
  final String? creator; // like issuer, but only for privacyIDEA servers. This is only set if the token was created by a privacyIDEA server
  final Version?
      piServerVersion; // The version of the privacyIDEA server that created the token. This is only set if the token was created by a privacyIDEA server
  const TokenOriginData._({
    required this.source,
    required this.appName,
    required this.data,
    required this.createdAt,
    this.isPrivacyIdeaToken,
    this.creator,
    this.piServerVersion,
  });

  factory TokenOriginData({
    required TokenOriginSourceType source,
    required String appName,
    required String data,
    DateTime? createdAt,
    bool? isPrivacyIdeaToken,
    String? creator,
    Version? piServerVersion,
  }) =>
      TokenOriginData._(
        source: source,
        appName: appName,
        data: data,
        createdAt: createdAt ?? DateTime.now(),
        isPrivacyIdeaToken: isPrivacyIdeaToken,
        creator: creator,
        piServerVersion: piServerVersion,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokenOriginData &&
        other.source == source &&
        other.appName == appName &&
        other.createdAt == createdAt &&
        other.data == data &&
        other.isPrivacyIdeaToken == isPrivacyIdeaToken &&
        other.creator == creator &&
        other.piServerVersion == piServerVersion;
  }

  TokenOriginData copyWith({
    TokenOriginSourceType? source,
    String? data,
    String? appName,
    DateTime? createdAt,
    bool? Function()? isPrivacyIdeaToken,
    String? Function()? creator,
    Version? Function()? piServerVersion,
  }) =>
      TokenOriginData(
        source: source ?? this.source,
        data: data ?? this.data,
        appName: appName ?? this.appName,
        createdAt: createdAt ?? this.createdAt,
        isPrivacyIdeaToken: isPrivacyIdeaToken != null ? isPrivacyIdeaToken() : this.isPrivacyIdeaToken,
        creator: creator != null ? creator() : this.creator,
        piServerVersion: piServerVersion != null ? piServerVersion() : this.piServerVersion,
      );

  @override
  int get hashCode => Object.hashAll([source, data, appName, isPrivacyIdeaToken, creator, createdAt, piServerVersion]);

  // toString prints not data because it contains the secret
  @override
  String toString() =>
      'TokenOrigin{source: $source, appName: $appName, isPrivacyIdeaToken: $isPrivacyIdeaToken, creator: $creator, createdAt: $createdAt, piServerVersion: $piServerVersion}';

  factory TokenOriginData.fromJson(Map<String, dynamic> json) => _$TokenOriginDataFromJson(json);

  Map<String, dynamic> toJson() => _$TokenOriginDataToJson(this);
}
