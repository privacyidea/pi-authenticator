// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContainerCredentials _$ContainerCredentialsFromJson(
        Map<String, dynamic> json) =>
    ContainerCredentials(
      serial: json['serial'] as String,
      id: json['id'] as String,
    );

Map<String, dynamic> _$ContainerCredentialsToJson(
        ContainerCredentials instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serial': instance.serial,
    };
