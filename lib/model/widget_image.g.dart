// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WidgetImage _$WidgetImageFromJson(Map<String, dynamic> json) => WidgetImage(
      fileType: json['fileType'] as String,
      imageData:
          const Uint8ListConverter().fromJson(json['imageData'] as String),
    );

Map<String, dynamic> _$WidgetImageToJson(WidgetImage instance) =>
    <String, dynamic>{
      'fileType': instance.fileType,
      'imageData': const Uint8ListConverter().toJson(instance.imageData),
    };
