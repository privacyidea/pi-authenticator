import 'package:json_annotation/json_annotation.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';

part 'container_credentials.g.dart';

@JsonSerializable()
class ContainerCredential extends PushToken {
  ContainerCredential({required super.serial, required super.id});

  factory ContainerCredential.fromUriMap(Map<String, dynamic> uriMap) => throw UnimplementedError(); // PushToken.fromUriMap(uriMap);

  factory ContainerCredential.fromJson(Map<String, dynamic> json) => _$ContainerCredentialFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ContainerCredentialToJson(this);

  @override
  String toString() => 'ContainerCredential{serial: $serial, id: $id}';
}
