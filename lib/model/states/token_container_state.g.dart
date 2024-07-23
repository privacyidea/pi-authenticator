// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenContainerStateUninitialized _$TokenContainerStateUninitializedFromJson(
        Map<String, dynamic> json) =>
    TokenContainerStateUninitialized(
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateUninitializedToJson(
        TokenContainerStateUninitialized instance) =>
    <String, dynamic>{
      'localTokenTemplates': instance.localTokenTemplates,
    };

TokenContainerStateModified _$TokenContainerStateModifiedFromJson(
        Map<String, dynamic> json) =>
    TokenContainerStateModified(
      lastModifiedAt: DateTime.parse(json['lastModifiedAt'] as String),
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      serial: json['serial'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      syncedTokenTemplates: (json['syncedTokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateModifiedToJson(
        TokenContainerStateModified instance) =>
    <String, dynamic>{
      'serial': instance.serial,
      'description': instance.description,
      'type': instance.type,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'localTokenTemplates': instance.localTokenTemplates,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'lastModifiedAt': instance.lastModifiedAt.toIso8601String(),
    };

TokenContainerStateSynced _$TokenContainerStateSyncedFromJson(
        Map<String, dynamic> json) =>
    TokenContainerStateSynced(
      serial: json['serial'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      syncedTokenTemplates: (json['syncedTokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
    );

Map<String, dynamic> _$TokenContainerStateSyncedToJson(
        TokenContainerStateSynced instance) =>
    <String, dynamic>{
      'serial': instance.serial,
      'description': instance.description,
      'type': instance.type,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
    };

TokenContainerStateUnsynced _$TokenContainerStateUnsyncedFromJson(
        Map<String, dynamic> json) =>
    TokenContainerStateUnsynced(
      syncAttempts: (json['syncAttempts'] as num?)?.toInt() ?? 1,
      lastError: json['lastError'],
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      serial: json['serial'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      syncedTokenTemplates: (json['syncedTokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateUnsyncedToJson(
        TokenContainerStateUnsynced instance) =>
    <String, dynamic>{
      'serial': instance.serial,
      'description': instance.description,
      'type': instance.type,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'localTokenTemplates': instance.localTokenTemplates,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'syncAttempts': instance.syncAttempts,
      'lastError': instance.lastError,
    };

TokenContainerStateError _$TokenContainerStateErrorFromJson(
        Map<String, dynamic> json) =>
    TokenContainerStateError(
      error: json['error'],
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      serial: json['serial'] as String? ?? 'Error',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'Error',
      syncedTokenTemplates: (json['syncedTokenTemplates'] as List<dynamic>?)
              ?.map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>?)
              ?.map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TokenContainerStateErrorToJson(
        TokenContainerStateError instance) =>
    <String, dynamic>{
      'serial': instance.serial,
      'description': instance.description,
      'type': instance.type,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'localTokenTemplates': instance.localTokenTemplates,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'error': instance.error,
    };

TokenContainerStateDeactivated _$TokenContainerStateDeactivatedFromJson(
        Map<String, dynamic> json) =>
    TokenContainerStateDeactivated(
      reason: json['reason'],
      deactivatedAt: DateTime.parse(json['deactivatedAt'] as String),
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      serial: json['serial'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      syncedTokenTemplates: (json['syncedTokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateDeactivatedToJson(
        TokenContainerStateDeactivated instance) =>
    <String, dynamic>{
      'serial': instance.serial,
      'description': instance.description,
      'type': instance.type,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'localTokenTemplates': instance.localTokenTemplates,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'deactivatedAt': instance.deactivatedAt.toIso8601String(),
      'reason': instance.reason,
    };

TokenContainerStateDeleted _$TokenContainerStateDeletedFromJson(
        Map<String, dynamic> json) =>
    TokenContainerStateDeleted(
      reason: json['reason'],
      deletedAt: DateTime.parse(json['deletedAt'] as String),
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      serial: json['serial'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      syncedTokenTemplates: (json['syncedTokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateDeletedToJson(
        TokenContainerStateDeleted instance) =>
    <String, dynamic>{
      'serial': instance.serial,
      'description': instance.description,
      'type': instance.type,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'localTokenTemplates': instance.localTokenTemplates,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt.toIso8601String(),
      'reason': instance.reason,
    };
