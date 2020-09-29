// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirebaseConfig _$FirebaseConfigFromJson(Map<String, dynamic> json) {
  return FirebaseConfig(
    projectID: json['projectID'] as String,
    projectNumber: json['projectNumber'] as String,
    appID: json['appID'] as String,
    apiKey: json['apiKey'] as String,
  );
}

Map<String, dynamic> _$FirebaseConfigToJson(FirebaseConfig instance) =>
    <String, dynamic>{
      'projectID': instance.projectID,
      'projectNumber': instance.projectNumber,
      'appID': instance.appID,
      'apiKey': instance.apiKey,
    };
