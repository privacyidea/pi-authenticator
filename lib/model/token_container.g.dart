// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenContainerUninitializedImpl _$$TokenContainerUninitializedImplFromJson(Map<String, dynamic> json) => _$TokenContainerUninitializedImpl(
      serverName: json['serverName'] as String? ?? 'PrivacyIDEA',
      lastSyncAt: json['lastSyncAt'] == null ? null : DateTime.parse(json['lastSyncAt'] as String),
      serial: json['serial'] as String? ?? 'none',
      description: json['description'] as String? ?? 'Uninitialized',
      syncedTokenTemplates:
          (json['syncedTokenTemplates'] as List<dynamic>?)?.map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>?)?.map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TokenContainerUninitializedImplToJson(_$TokenContainerUninitializedImpl instance) => <String, dynamic>{
      'serverName': instance.serverName,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'serial': instance.serial,
      'description': instance.description,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'localTokenTemplates': instance.localTokenTemplates,
      'runtimeType': instance.$type,
    };

_$TokenContainerSyncedImpl _$$TokenContainerSyncedImplFromJson(Map<String, dynamic> json) => _$TokenContainerSyncedImpl(
      serverName: json['serverName'] as String? ?? 'PrivacyIDEA',
      lastSyncAt: DateTime.parse(json['lastSyncAt'] as String),
      serial: json['serial'] as String,
      description: json['description'] as String,
      syncedTokenTemplates: (json['syncedTokenTemplates'] as List<dynamic>).map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>)).toList(),
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>).map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>)).toList(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TokenContainerSyncedImplToJson(_$TokenContainerSyncedImpl instance) => <String, dynamic>{
      'serverName': instance.serverName,
      'lastSyncAt': instance.lastSyncAt.toIso8601String(),
      'serial': instance.serial,
      'description': instance.description,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'localTokenTemplates': instance.localTokenTemplates,
      'runtimeType': instance.$type,
    };

_$TokenContainerModifiedImpl _$$TokenContainerModifiedImplFromJson(Map<String, dynamic> json) => _$TokenContainerModifiedImpl(
      serverName: json['serverName'] as String? ?? 'PrivacyIDEA',
      lastSyncAt: json['lastSyncAt'] == null ? null : DateTime.parse(json['lastSyncAt'] as String),
      serial: json['serial'] as String,
      description: json['description'] as String,
      syncedTokenTemplates: (json['syncedTokenTemplates'] as List<dynamic>).map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>)).toList(),
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>).map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>)).toList(),
      lastModifiedAt: DateTime.parse(json['lastModifiedAt'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TokenContainerModifiedImplToJson(_$TokenContainerModifiedImpl instance) => <String, dynamic>{
      'serverName': instance.serverName,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'serial': instance.serial,
      'description': instance.description,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'localTokenTemplates': instance.localTokenTemplates,
      'lastModifiedAt': instance.lastModifiedAt.toIso8601String(),
      'runtimeType': instance.$type,
    };

_$TokenContainerUnsyncedImpl _$$TokenContainerUnsyncedImplFromJson(Map<String, dynamic> json) => _$TokenContainerUnsyncedImpl(
      serverName: json['serverName'] as String? ?? 'PrivacyIDEA',
      lastSyncAt: json['lastSyncAt'] == null ? null : DateTime.parse(json['lastSyncAt'] as String),
      serial: json['serial'] as String,
      description: json['description'] as String,
      syncedTokenTemplates: (json['syncedTokenTemplates'] as List<dynamic>).map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>)).toList(),
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>).map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>)).toList(),
      message: json['message'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TokenContainerUnsyncedImplToJson(_$TokenContainerUnsyncedImpl instance) => <String, dynamic>{
      'serverName': instance.serverName,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'serial': instance.serial,
      'description': instance.description,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'localTokenTemplates': instance.localTokenTemplates,
      'message': instance.message,
      'runtimeType': instance.$type,
    };

_$TokenContainerNotFoundImpl _$$TokenContainerNotFoundImplFromJson(Map<String, dynamic> json) => _$TokenContainerNotFoundImpl(
      serverName: json['serverName'] as String? ?? 'PrivacyIDEA',
      lastSyncAt: json['lastSyncAt'] == null ? null : DateTime.parse(json['lastSyncAt'] as String),
      serial: json['serial'] as String,
      description: json['description'] as String,
      syncedTokenTemplates: (json['syncedTokenTemplates'] as List<dynamic>).map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>)).toList(),
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>).map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>)).toList(),
      message: json['message'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TokenContainerNotFoundImplToJson(_$TokenContainerNotFoundImpl instance) => <String, dynamic>{
      'serverName': instance.serverName,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'serial': instance.serial,
      'description': instance.description,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'localTokenTemplates': instance.localTokenTemplates,
      'message': instance.message,
      'runtimeType': instance.$type,
    };

_$TokenContainerErrorImpl _$$TokenContainerErrorImplFromJson(Map<String, dynamic> json) => _$TokenContainerErrorImpl(
      serverName: json['serverName'] as String? ?? 'PrivacyIDEA',
      lastSyncAt: json['lastSyncAt'] == null ? null : DateTime.parse(json['lastSyncAt'] as String),
      serial: json['serial'] as String? ?? 'none',
      description: json['description'] as String? ?? 'Error',
      syncedTokenTemplates:
          (json['syncedTokenTemplates'] as List<dynamic>?)?.map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>?)?.map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      error: json['error'],
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TokenContainerErrorImplToJson(_$TokenContainerErrorImpl instance) => <String, dynamic>{
      'serverName': instance.serverName,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'serial': instance.serial,
      'description': instance.description,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'localTokenTemplates': instance.localTokenTemplates,
      'error': instance.error,
      'runtimeType': instance.$type,
    };

_$TokenTemplateImpl _$$TokenTemplateImplFromJson(Map<String, dynamic> json) => _$TokenTemplateImpl(
      data: json['data'] as Map<String, String>,
    );

Map<String, dynamic> _$$TokenTemplateImplToJson(_$TokenTemplateImpl instance) => <String, dynamic>{
      'data': instance.data,
    };
