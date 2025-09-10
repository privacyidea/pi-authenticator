// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TokenTemplateWithSerial _$TokenTemplateWithSerialFromJson(
  Map<String, dynamic> json,
) => _TokenTemplateWithSerial(
  otpAuthMap: json['otpAuthMap'] as Map<String, dynamic>,
  serial: json['serial'] as String,
  additionalData: json['additionalData'] as Map<String, dynamic>? ?? const {},
  container: json['container'] == null
      ? null
      : TokenContainer.fromJson(json['container'] as Map<String, dynamic>),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$TokenTemplateWithSerialToJson(
  _TokenTemplateWithSerial instance,
) => <String, dynamic>{
  'otpAuthMap': instance.otpAuthMap,
  'serial': instance.serial,
  'additionalData': instance.additionalData,
  'container': instance.container,
  'runtimeType': instance.$type,
};

_TokenTemplateWithOtps _$TokenTemplateWithOtpsFromJson(
  Map<String, dynamic> json,
) => _TokenTemplateWithOtps(
  otpAuthMap: json['otpAuthMap'] as Map<String, dynamic>,
  otps: (json['otps'] as List<dynamic>).map((e) => e as String).toList(),
  additionalData: json['additionalData'] as Map<String, dynamic>? ?? const {},
  container: json['container'] == null
      ? null
      : TokenContainer.fromJson(json['container'] as Map<String, dynamic>),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$TokenTemplateWithOtpsToJson(
  _TokenTemplateWithOtps instance,
) => <String, dynamic>{
  'otpAuthMap': instance.otpAuthMap,
  'otps': instance.otps,
  'additionalData': instance.additionalData,
  'container': instance.container,
  'runtimeType': instance.$type,
};
