import 'package:json_annotation/json_annotation.dart';

import 'tokens/token.dart';

part 'token_container.g.dart';

@JsonSerializable()
class TokenContainer {
  final String containerId;
  final String description;
  final String type;
  final List<Token> tokens;

  const TokenContainer({
    required this.containerId,
    required this.description,
    required this.type,
    required this.tokens,
  });

  factory TokenContainer.fromJson(Map<String, dynamic> json) => _$TokenContainerFromJson(json);
  Map<String, dynamic> toJson() => _$TokenContainerToJson(this);

  TokenContainer copyWith({
    String? containerId,
    String? description,
    String? type,
    List<Token>? tokens,
  }) {
    return TokenContainer(
      containerId: containerId ?? this.containerId,
      description: description ?? this.description,
      type: type ?? this.type,
      tokens: tokens ?? this.tokens,
    );
  }
}
