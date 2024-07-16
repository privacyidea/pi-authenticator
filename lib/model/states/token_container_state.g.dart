// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenContainerStateUninitialized _$TokenContainerStateUninitializedFromJson(
        Map<String, dynamic> json) =>
    TokenContainerStateUninitialized(
      containerId: json['containerId'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => Token.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateUninitializedToJson(
        TokenContainerStateUninitialized instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'description': instance.description,
      'type': instance.type,
      'tokens': instance.tokens,
    };

TokenContainerStateSynced _$TokenContainerStateSyncedFromJson(
        Map<String, dynamic> json) =>
    TokenContainerStateSynced(
      lastSyncedAt: DateTime.parse(json['lastSyncedAt'] as String),
      containerId: json['containerId'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => Token.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateSyncedToJson(
        TokenContainerStateSynced instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'description': instance.description,
      'type': instance.type,
      'tokens': instance.tokens,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
    };

TokenContainerStateSyncing _$TokenContainerStateSyncingFromJson(
        Map<String, dynamic> json) =>
    TokenContainerStateSyncing(
      syncStartedAt: DateTime.parse(json['syncStartedAt'] as String),
      timeOut: json['timeOut'] == null
          ? const Duration(seconds: 30)
          : Duration(microseconds: (json['timeOut'] as num).toInt()),
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      containerId: json['containerId'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => Token.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateSyncingToJson(
        TokenContainerStateSyncing instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'description': instance.description,
      'type': instance.type,
      'tokens': instance.tokens,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'syncStartedAt': instance.syncStartedAt.toIso8601String(),
      'timeOut': instance.timeOut.inMicroseconds,
    };

TokenContainerStateUnsynced _$TokenContainerStateUnsyncedFromJson(
        Map<String, dynamic> json) =>
    TokenContainerStateUnsynced(
      syncAttempts: (json['syncAttempts'] as num?)?.toInt() ?? 1,
      lastError: json['lastError'],
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      containerId: json['containerId'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => Token.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateUnsyncedToJson(
        TokenContainerStateUnsynced instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'description': instance.description,
      'type': instance.type,
      'tokens': instance.tokens,
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
      containerId: json['containerId'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => Token.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateErrorToJson(
        TokenContainerStateError instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'description': instance.description,
      'type': instance.type,
      'tokens': instance.tokens,
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
      containerId: json['containerId'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => Token.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateDeactivatedToJson(
        TokenContainerStateDeactivated instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'description': instance.description,
      'type': instance.type,
      'tokens': instance.tokens,
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
      containerId: json['containerId'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => Token.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateDeletedToJson(
        TokenContainerStateDeleted instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'description': instance.description,
      'type': instance.type,
      'tokens': instance.tokens,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt.toIso8601String(),
      'reason': instance.reason,
    };
