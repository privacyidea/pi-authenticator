// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_policies.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContainerPoliciesImpl _$$ContainerPoliciesImplFromJson(
        Map<String, dynamic> json) =>
    _$ContainerPoliciesImpl(
      rolloverAllowed: json['rolloverAllowed'] as bool,
      initialTokenTransfer: json['initialTokenTransfer'] as bool,
      tokensDeletable: json['tokensDeletable'] as bool,
      unregisterAllowed: json['unregisterAllowed'] as bool,
    );

Map<String, dynamic> _$$ContainerPoliciesImplToJson(
        _$ContainerPoliciesImpl instance) =>
    <String, dynamic>{
      'rolloverAllowed': instance.rolloverAllowed,
      'initialTokenTransfer': instance.initialTokenTransfer,
      'tokensDeletable': instance.tokensDeletable,
      'unregisterAllowed': instance.unregisterAllowed,
    };
