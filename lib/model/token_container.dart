import 'package:json_annotation/json_annotation.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import 'tokens/token.dart';

part 'token_container.g.dart';

@JsonSerializable()
class TokenContainer {
  final String serial;
  final String description;
  final String type;
  final List<TokenTemplate> syncedTokenTemplates;
  final List<TokenTemplate> localTokenTemplates;

  const TokenContainer({
    required this.serial,
    required this.description,
    required this.type,
    required this.syncedTokenTemplates,
    required this.localTokenTemplates,
  });

  factory TokenContainer.fromJson(Map<String, dynamic> json) => _$TokenContainerFromJson(json);
  Map<String, dynamic> toJson() => _$TokenContainerToJson(this);

  TokenContainer copyWith({
    String? serial,
    String? description,
    String? type,
    List<TokenTemplate>? syncedTokenTemplates,
    List<TokenTemplate>? localTokenTemplates,
  }) {
    return TokenContainer(
      serial: serial ?? this.serial,
      description: description ?? this.description,
      type: type ?? this.type,
      syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
      localTokenTemplates: localTokenTemplates ?? this.localTokenTemplates,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TokenTemplate && other.data == data;
  }

  @override
  int get hashCode => Object.hashAll([data, runtimeType]);

  factory TokenTemplate.fromJson(Map<String, dynamic> json) => _$TokenTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$TokenTemplateToJson(this);

  Token toToken() => Token.fromUriMap(data);

  TokenTemplate copyWith(Map<String, dynamic> replace) {
    return TokenTemplate(
      data: Map<String, dynamic>.from(data)..addAll(replace),
    );
  }


}
