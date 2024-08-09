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
      appIcon: WidgetImage.fromJson(json['appIcon'] as Map<String, dynamic>),
      appImage: WidgetImage.fromJson(json['appImage'] as Map<String, dynamic>),
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
      'appIcon': instance.appIcon,
      'appImage': instance.appImage,
      'lightTheme': instance.lightTheme,
      'darkTheme': instance.darkTheme,
      'disabledFeatures': instance.disabledFeatures
          .map((e) => _$AppFeatureEnumMap[e]!)
          .toList(),
    };

const _$AppFeatureEnumMap = {
  AppFeature.patchNotes: 'patchNotes',
  AppFeature.introductions: 'introductions',
};
