// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CredentialsStateImpl _$$CredentialsStateImplFromJson(
        Map<String, dynamic> json) =>
    _$CredentialsStateImpl(
      credentials: (json['credentials'] as List<dynamic>)
          .map((e) => ContainerCredential.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CredentialsStateImplToJson(
        _$CredentialsStateImpl instance) =>
    <String, dynamic>{
      'credentials': instance.credentials,
    };
