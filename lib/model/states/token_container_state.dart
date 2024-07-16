import 'package:json_annotation/json_annotation.dart';

import '../token_container.dart';
import '../tokens/token.dart';

part 'token_container_state.g.dart';

sealed class TokenContainerState extends TokenContainer {
  final DateTime? lastSyncedAt;

  const TokenContainerState({
    required this.lastSyncedAt,
    // TokenContainer
    required super.containerId,
    required super.description,
    required super.type,
    required super.tokens,
  });

  factory TokenContainerState.uninitialized() => const TokenContainerStateUninitialized(
        containerId: '',
        description: '',
        type: '',
        tokens: [],
      );

  factory TokenContainerState.fromJson(Map<String, dynamic> json) => switch (json['type']) {
        const ('TokenContainerStateUninitialized') => _$TokenContainerStateUninitializedFromJson(json),
        const ('TokenContainerStateSynced') => _$TokenContainerStateSyncedFromJson(json),
        const ('TokenContainerStateSyncing') => _$TokenContainerStateSyncingFromJson(json),
        const ('TokenContainerStateUnsynced') => _$TokenContainerStateUnsyncedFromJson(json),
        const ('TokenContainerStateError') => _$TokenContainerStateErrorFromJson(json),
        const ('TokenContainerStateDeactivated') => _$TokenContainerStateDeactivatedFromJson(json),
        const ('TokenContainerStateDeleted') => _$TokenContainerStateDeletedFromJson(json),
        _ => throw UnimplementedError(json['type']),
      };

  @override
  Map<String, dynamic> toJson() {
    final json = switch (this) {
      TokenContainerStateUninitialized() => _$TokenContainerStateUninitializedToJson(this as TokenContainerStateUninitialized),
      TokenContainerStateSynced() => _$TokenContainerStateSyncedToJson(this as TokenContainerStateSynced),
      TokenContainerStateSyncing() => _$TokenContainerStateSyncingToJson(this as TokenContainerStateSyncing),
      TokenContainerStateUnsynced() => _$TokenContainerStateUnsyncedToJson(this as TokenContainerStateUnsynced),
      TokenContainerStateError() => _$TokenContainerStateErrorToJson(this as TokenContainerStateError),
      TokenContainerStateDeactivated() => _$TokenContainerStateDeactivatedToJson(this as TokenContainerStateDeactivated),
      TokenContainerStateDeleted() => _$TokenContainerStateDeletedToJson(this as TokenContainerStateDeleted),
    };
    json['type'] = runtimeType.toString();
    return json;
  }

  T copyStateWith<T extends TokenContainerState>({
    dynamic data,
    DateTime? dateTime,
    DateTime? lastSyncedAt,
    String? containerId,
    String? description,
    String? type,
    List<Token>? tokens,
  }) {
    final copied = copyWith(
      containerId: containerId,
      description: description,
      type: type,
      tokens: tokens,
    ) as TokenContainerState;
    return copied.as<T>(data: data, dateTime: dateTime);
  }

  T as<T extends TokenContainerState>({dynamic data, DateTime? dateTime}) => switch (T) {
        const (TokenContainerStateUninitialized) => TokenContainerStateUninitialized(
            containerId: containerId,
            description: description,
            type: type,
            tokens: tokens,
          ) as T,
        const (TokenContainerStateSynced) => TokenContainerStateSynced(
            lastSyncedAt: lastSyncedAt ?? DateTime.now(),
            containerId: containerId,
            description: description,
            type: type,
            tokens: tokens,
          ) as T,
        const (TokenContainerStateSyncing) => TokenContainerStateSyncing(
            lastSyncedAt: lastSyncedAt,
            syncStartedAt: dateTime ?? DateTime.now(),
            containerId: containerId,
            description: description,
            type: type,
            tokens: tokens,
          ) as T,
        const (TokenContainerStateUnsynced) => this is TokenContainerStateUnsynced
            ? (this as TokenContainerStateUnsynced).withIncrementedSyncAttempts() as T
            : TokenContainerStateUnsynced(
                lastSyncedAt: lastSyncedAt,
                syncAttempts: data is num ? data.floor() : 1,
                containerId: containerId,
                description: description,
                type: type,
                tokens: tokens,
              ) as T,
        const (TokenContainerStateError) => TokenContainerStateError(
            error: data,
            lastSyncedAt: lastSyncedAt,
            containerId: containerId,
            description: description,
            type: type,
            tokens: tokens,
          ) as T,
        const (TokenContainerStateDeactivated) => TokenContainerStateDeactivated(
            reason: data,
            deactivatedAt: dateTime ?? DateTime.now(),
            lastSyncedAt: lastSyncedAt,
            containerId: containerId,
            description: description,
            type: type,
            tokens: tokens,
          ) as T,
        const (TokenContainerStateDeleted) => TokenContainerStateDeleted(
            reason: data,
            deletedAt: dateTime ?? DateTime.now(),
            lastSyncedAt: lastSyncedAt,
            containerId: containerId,
            description: description,
            type: type,
            tokens: tokens,
          ) as T,
        _ => throw UnimplementedError(),
      };
}

/// ContainerState is not initialized
@JsonSerializable()
class TokenContainerStateUninitialized extends TokenContainerState {
  const TokenContainerStateUninitialized({
    required super.containerId,
    required super.description,
    required super.type,
    required super.tokens,
  }) : super(lastSyncedAt: null);
}

/// ContainerState is successfully synced with repo
@JsonSerializable()
class TokenContainerStateSynced extends TokenContainerState {
  TokenContainerStateSynced({
    required DateTime lastSyncedAt,
    required super.containerId,
    required super.description,
    required super.type,
    required super.tokens,
  }) : super(lastSyncedAt: lastSyncedAt);
}

/// ContainerState is currently syncing
@JsonSerializable()
class TokenContainerStateSyncing extends TokenContainerState {
  final DateTime syncStartedAt;
  final Duration timeOut;
  get isSyncing => DateTime.now().difference(syncStartedAt) < timeOut;
  get isTimedOut => DateTime.now().difference(syncStartedAt) > timeOut;
  const TokenContainerStateSyncing({
    required this.syncStartedAt,
    this.timeOut = const Duration(seconds: 30),
    required super.lastSyncedAt,
    required super.containerId,
    required super.description,
    required super.type,
    required super.tokens,
  });
}

/// ContainerState is failed last sync attempt
@JsonSerializable()
class TokenContainerStateUnsynced extends TokenContainerState {
  final int syncAttempts;
  final dynamic lastError;

  TokenContainerStateUnsynced({
    this.syncAttempts = 1,
    this.lastError,
    required super.lastSyncedAt,
    required super.containerId,
    required super.description,
    required super.type,
    required super.tokens,
  });

  TokenContainerStateUnsynced withIncrementedSyncAttempts() => withSyncAttempts(syncAttempts + 1);
  TokenContainerStateUnsynced withSyncAttempts(int syncAttempts) => TokenContainerStateUnsynced(
        syncAttempts: syncAttempts,
        lastSyncedAt: lastSyncedAt,
        containerId: containerId,
        description: description,
        type: type,
        tokens: tokens,
      );
}

/// ContainerState is in error state
@JsonSerializable()
class TokenContainerStateError extends TokenContainerState {
  final dynamic error;
  TokenContainerStateError({
    required this.error,
    required super.lastSyncedAt,
    required super.containerId,
    required super.description,
    required super.type,
    required super.tokens,
  });
}

/// ContainerState is deactivated
@JsonSerializable()
class TokenContainerStateDeactivated extends TokenContainerState {
  final DateTime deactivatedAt;
  final dynamic reason;
  TokenContainerStateDeactivated({
    required this.reason,
    required this.deactivatedAt,
    required super.lastSyncedAt,
    required super.containerId,
    required super.description,
    required super.type,
    required super.tokens,
  });
}

/// ContainerState is deleted repo-side
@JsonSerializable()
class TokenContainerStateDeleted extends TokenContainerState {
  final DateTime deletedAt;
  final dynamic reason;
  TokenContainerStateDeleted({
    required this.reason,
    required this.deletedAt,
    required super.lastSyncedAt,
    required super.containerId,
    required super.description,
    required super.type,
    required super.tokens,
  });
}
