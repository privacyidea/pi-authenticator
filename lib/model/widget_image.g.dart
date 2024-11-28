// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WidgetImage _$WidgetImageFromJson(Map<String, dynamic> json) => WidgetImage(
      fileType: $enumDecode(_$ImageFileTypeEnumMap, json['fileType']),
      imageData: const Uint8ListConverter().fromJson(json['imageData'] as String),
      fileName: json['fileName'] as String,
    );

Map<String, dynamic> _$WidgetImageToJson(WidgetImage instance) => <String, dynamic>{
      'fileType': _$ImageFileTypeEnumMap[instance.fileType]!,
      'imageData': const Uint8ListConverter().toJson(instance.imageData),
      'fileName': instance.fileName,
    };

const _$ImageFileTypeEnumMap = {
  ImageFormat.svg: 'svg',
  ImageFormat.svgz: 'svgz',
  ImageFormat.png: 'png',
  ImageFormat.jpg: 'jpg',
  ImageFormat.jpeg: 'jpeg',
  ImageFormat.gif: 'gif',
  ImageFormat.bmp: 'bmp',
  ImageFormat.webp: 'webp',
};
