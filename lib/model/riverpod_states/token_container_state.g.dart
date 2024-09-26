// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CredentialsStateImpl _$$CredentialsStateImplFromJson(Map<String, dynamic> json) => _$CredentialsStateImpl(
      container: (json['container'] as List<dynamic>).map((e) => TokenContainer.fromJson(e as Map<String, dynamic>)).toList(),
    );

Map<String, dynamic> _$$CredentialsStateImplToJson(_$CredentialsStateImpl instance) => <String, dynamic>{
      'container': instance.containerList,
    };
