// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Version _$VersionFromJson(Map<String, dynamic> json) => Version(
      json['major'] as int,
      json['minor'] as int,
      json['patch'] as int,
    );

Map<String, dynamic> _$VersionToJson(Version instance) => <String, dynamic>{
      'major': instance.major,
      'minor': instance.minor,
      'patch': instance.patch,
    };
