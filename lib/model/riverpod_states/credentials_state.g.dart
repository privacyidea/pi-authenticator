// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredentialsState _$CredentialsStateFromJson(Map<String, dynamic> json) =>
    CredentialsState(
      credentials: (json['credentials'] as List<dynamic>)
          .map((e) => ContainerCredential.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CredentialsStateToJson(CredentialsState instance) =>
    <String, dynamic>{
      'credentials': instance.credentials.map((e) => e.toJson()).toList(),
    };
