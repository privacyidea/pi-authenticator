// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_customization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationCustomization _$ApplicationCustomizationFromJson(
        Map<String, dynamic> json) =>
    ApplicationCustomization(
      appName: json['appName'] as String,
      websiteLink: json['websiteLink'] as String,
      appIconUint8List: _$JsonConverterFromJson<List<int>, Uint8List>(
          json['appIconUint8List'], const Uint8ListJsonConverter().fromJson),
      appIconSvgUint8List: _$JsonConverterFromJson<List<int>, Uint8List>(
          json['appIconSvgUint8List'], const Uint8ListJsonConverter().fromJson),
      appImageUint8List: _$JsonConverterFromJson<List<int>, Uint8List>(
          json['appImageUint8List'], const Uint8ListJsonConverter().fromJson),
      appImageSvgUint8List: _$JsonConverterFromJson<List<int>, Uint8List>(
          json['appImageSvgUint8List'],
          const Uint8ListJsonConverter().fromJson),
      lightTheme: ThemeCustomization.fromJson(
          json['lightTheme'] as Map<String, dynamic>),
      darkTheme: ThemeCustomization.fromJson(
          json['darkTheme'] as Map<String, dynamic>),
      disabledFeatures: (json['disabledFeatures'] as List<dynamic>)
          .map((e) => $enumDecode(_$AppFeatureEnumMap, e))
          .toSet(),
    );

Map<String, dynamic> _$ApplicationCustomizationToJson(
        ApplicationCustomization instance) =>
    <String, dynamic>{
      'appName': instance.appName,
      'websiteLink': instance.websiteLink,
      'appIconUint8List': _$JsonConverterToJson<List<int>, Uint8List>(
          instance.appIconUint8List, const Uint8ListJsonConverter().toJson),
      'appIconSvgUint8List': _$JsonConverterToJson<List<int>, Uint8List>(
          instance.appIconSvgUint8List, const Uint8ListJsonConverter().toJson),
      'appImageUint8List': _$JsonConverterToJson<List<int>, Uint8List>(
          instance.appImageUint8List, const Uint8ListJsonConverter().toJson),
      'appImageSvgUint8List': _$JsonConverterToJson<List<int>, Uint8List>(
          instance.appImageSvgUint8List, const Uint8ListJsonConverter().toJson),
      'lightTheme': instance.lightTheme,
      'darkTheme': instance.darkTheme,
      'disabledFeatures': instance.disabledFeatures
          .map((e) => _$AppFeatureEnumMap[e]!)
          .toList(),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

const _$AppFeatureEnumMap = {
  AppFeature.patchNotes: 'patchNotes',
  AppFeature.introductions: 'introductions',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
