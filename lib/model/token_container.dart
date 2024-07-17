import 'package:json_annotation/json_annotation.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

part 'token_container.g.dart';

@JsonSerializable()
class TokenContainer {
  final String containerId;
  final String description;
  final String type;
  final List<TokenTemplate> tokenTemplates;

  const TokenContainer({
    required this.containerId,
    required this.description,
    required this.type,
    required this.tokenTemplates,
  });

  factory TokenContainer.fromJson(Map<String, dynamic> json) => _$TokenContainerFromJson(json);
  Map<String, dynamic> toJson() => _$TokenContainerToJson(this);

  TokenContainer copyWith({
    String? containerId,
    String? description,
    String? type,
    List<TokenTemplate>? tokenTemplates,
  }) {
    return TokenContainer(
      containerId: containerId ?? this.containerId,
      description: description ?? this.description,
      type: type ?? this.type,
      tokenTemplates: tokenTemplates ?? this.tokenTemplates,
    );
  }
}

@JsonSerializable()
class TokenTemplate {
  final Map<String, dynamic> data;

  String? get id {
    final id = data[TOKEN_ID];
    if (id is! String?) {
      Logger.error('TokenTemplate id is not a string');
    }
    return id;
  }

  TokenTemplate({required this.data});

  factory TokenTemplate.fromJson(Map<String, dynamic> json) => _$TokenTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$TokenTemplateToJson(this);
}
