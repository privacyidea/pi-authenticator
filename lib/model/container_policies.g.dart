// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_policies.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContainerPolicies _$ContainerPoliciesFromJson(Map<String, dynamic> json) =>
    _ContainerPolicies(
      rolloverAllowed: json['rolloverAllowed'] as bool,
      initialTokenAssignment: json['initialTokenAssignment'] as bool,
      disabledTokenDeletion: json['disabledTokenDeletion'] as bool,
      disabledUnregister: json['disabledUnregister'] as bool,
    );

Map<String, dynamic> _$ContainerPoliciesToJson(_ContainerPolicies instance) =>
    <String, dynamic>{
      'rolloverAllowed': instance.rolloverAllowed,
      'initialTokenAssignment': instance.initialTokenAssignment,
      'disabledTokenDeletion': instance.disabledTokenDeletion,
      'disabledUnregister': instance.disabledUnregister,
    };
