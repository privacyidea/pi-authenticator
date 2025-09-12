// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WidgetImage _$WidgetImageFromJson(Map<String, dynamic> json) => WidgetImage(
  fileName: json['fileName'] as String,
  imageFormat: $enumDecode(_$ImageFormatEnumMap, json['imageFormat']),
  imageData: const Uint8ListConverter().fromJson(json['imageData'] as String),
);

Map<String, dynamic> _$WidgetImageToJson(WidgetImage instance) =>
    <String, dynamic>{
      'imageFormat': _$ImageFormatEnumMap[instance.imageFormat]!,
      'imageData': const Uint8ListConverter().toJson(instance.imageData),
      'fileName': instance.fileName,
    };

const _$ImageFormatEnumMap = {
  ImageFormat.svg: 'svg',
  ImageFormat.svgz: 'svgz',
  ImageFormat.png: 'png',
  ImageFormat.jpg: 'jpg',
  ImageFormat.jpeg: 'jpeg',
  ImageFormat.gif: 'gif',
  ImageFormat.bmp: 'bmp',
  ImageFormat.webp: 'webp',
};
