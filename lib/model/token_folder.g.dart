// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenFolder _$TokenFolderFromJson(Map<String, dynamic> json) => TokenFolder(
      label: json['label'] as String,
      folderId: json['folderId'] as int,
      isExpanded: json['isExpanded'] as bool? ?? true,
      isLocked: json['isLocked'] as bool? ?? false,
      sortIndex: json['sortIndex'] as int?,
    );

Map<String, dynamic> _$TokenFolderToJson(TokenFolder instance) => <String, dynamic>{
      'label': instance.label,
      'folderId': instance.folderId,
      'isExpanded': instance.isExpanded,
      'isLocked': instance.isLocked,
      'sortIndex': instance.sortIndex,
    };
