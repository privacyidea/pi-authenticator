import 'package:json_annotation/json_annotation.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';

part 'container_credentials.g.dart';

@JsonSerializable()
class ContainerCredentials extends PushToken {
  ContainerCredentials({required super.serial, required super.id});

  factory ContainerCredentials.fromUriMap(Map<String, dynamic> uriMap) => throw UnimplementedError(); // PushToken.fromUriMap(uriMap);

  factory ContainerCredentials.fromJson(Map<String, dynamic> json) => _$ContainerCredentialsFromJson(json);
  Map<String, dynamic> toJson() => _$ContainerCredentialsToJson(this);
}
