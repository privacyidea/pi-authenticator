// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenTemplateWithSerialImpl _$$TokenTemplateWithSerialImplFromJson(
        Map<String, dynamic> json) =>
    _$TokenTemplateWithSerialImpl(
      otpAuthMap: json['otpAuthMap'] as Map<String, dynamic>,
      serial: json['serial'] as String,
      additionalData:
          json['additionalData'] as Map<String, dynamic>? ?? const {},
      container: json['container'] == null
          ? null
          : TokenContainer.fromJson(json['container'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TokenTemplateWithSerialImplToJson(
        _$TokenTemplateWithSerialImpl instance) =>
    <String, dynamic>{
      'otpAuthMap': instance.otpAuthMap,
      'serial': instance.serial,
      'additionalData': instance.additionalData,
      'container': instance.container,
      'runtimeType': instance.$type,
    };

_$TokenTemplateWithOtpsImpl _$$TokenTemplateWithOtpsImplFromJson(
        Map<String, dynamic> json) =>
    _$TokenTemplateWithOtpsImpl(
      otpAuthMap: json['otpAuthMap'] as Map<String, dynamic>,
      otps: (json['otps'] as List<dynamic>).map((e) => e as String).toList(),
      additionalData:
          json['additionalData'] as Map<String, dynamic>? ?? const {},
      container: json['container'] == null
          ? null
          : TokenContainer.fromJson(json['container'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TokenTemplateWithOtpsImplToJson(
        _$TokenTemplateWithOtpsImpl instance) =>
    <String, dynamic>{
      'otpAuthMap': instance.otpAuthMap,
      'otps': instance.otps,
      'additionalData': instance.additionalData,
      'container': instance.container,
      'runtimeType': instance.$type,
    };
