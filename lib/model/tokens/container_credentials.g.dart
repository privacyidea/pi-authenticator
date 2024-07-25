// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContainerCredential _$ContainerCredentialFromJson(Map<String, dynamic> json) =>
    ContainerCredential(
      serial: json['serial'] as String,
      id: json['id'] as String,
    );

Map<String, dynamic> _$ContainerCredentialToJson(
        ContainerCredential instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serial': instance.serial,
    };
