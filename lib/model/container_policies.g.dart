// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_policies.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContainerPoliciesImpl _$$ContainerPoliciesImplFromJson(
        Map<String, dynamic> json) =>
    _$ContainerPoliciesImpl(
      rolloverAllowed: json['rolloverAllowed'] as bool,
      initialTokenAssignment: json['initialTokenAssignment'] as bool,
      disabledTokenDeletion: json['disabledTokenDeletion'] as bool,
      disabledUnregister: json['disabledUnregister'] as bool,
    );

Map<String, dynamic> _$$ContainerPoliciesImplToJson(
        _$ContainerPoliciesImpl instance) =>
    <String, dynamic>{
      'rolloverAllowed': instance.rolloverAllowed,
      'initialTokenAssignment': instance.initialTokenAssignment,
      'disabledTokenDeletion': instance.disabledTokenDeletion,
      'disabledUnregister': instance.disabledUnregister,
    };
