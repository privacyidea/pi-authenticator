// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WidgetImage _$WidgetImageFromJson(Map<String, dynamic> json) => WidgetImage(
      fileType: $enumDecode(_$ImageFileTypeEnumMap, json['fileType']),
      imageData:
          const Uint8ListConverter().fromJson(json['imageData'] as String),
    );

Map<String, dynamic> _$WidgetImageToJson(WidgetImage instance) =>
    <String, dynamic>{
      'fileType': _$ImageFileTypeEnumMap[instance.fileType]!,
      'imageData': const Uint8ListConverter().toJson(instance.imageData),
    };

const _$ImageFileTypeEnumMap = {
  ImageFileType.svg: 'svg',
  ImageFileType.svgz: 'svgz',
  ImageFileType.png: 'png',
  ImageFileType.jpg: 'jpg',
  ImageFileType.jpeg: 'jpeg',
  ImageFileType.gif: 'gif',
};
