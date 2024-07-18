import 'package:json_annotation/json_annotation.dart';

import '../token_container.dart';

part 'token_container_state.g.dart';

sealed class TokenContainerState extends TokenContainer {
  final DateTime? lastSyncedAt;

  const TokenContainerState({
    required this.lastSyncedAt,
    // TokenContainer
    required super.containerId,
    required super.description,
    required super.type,
    required super.tokenTemplates,
  });

  factory TokenContainerState.uninitialized() => const TokenContainerStateUninitialized();

  factory TokenContainerState.fromJson(Map<String, dynamic> json) => switch (json['type']) {
        const ('TokenContainerStateUninitialized') => _$TokenContainerStateUninitializedFromJson(json),
        const ('TokenContainerStateModified') => _$TokenContainerStateModifiedFromJson(json),
        const ('TokenContainerStateSynced') => _$TokenContainerStateSyncedFromJson(json),
        const ('TokenContainerStateSyncing') => _$TokenContainerStateSyncingFromJson(json),
        const ('TokenContainerStateUnsynced') => _$TokenContainerStateUnsyncedFromJson(json),
        const ('TokenContainerStateError') => _$TokenContainerStateErrorFromJson(json),
        const ('TokenContainerStateDeactivated') => _$TokenContainerStateDeactivatedFromJson(json),
        const ('TokenContainerStateDeleted') => _$TokenContainerStateDeletedFromJson(json),
        _ => throw UnimplementedError(json['type']),
      };

  factory TokenContainerState.fromTypeString({
    required String stateType,
    dynamic data,
    DateTime? dateTime,
    String? containerId,
    String? description,
    String? type,
    List<TokenTemplate> tokenTemplates = const [],
    DateTime? lastSyncedAt,
  }) =>
      switch (stateType) {
        'TokenContainerStateUninitialized' => const TokenContainerStateUninitialized(),
        'TokenContainerStateModified' => TokenContainerStateModified(
            lastModifiedAt: dateTime ?? DateTime.now(),
            highPriority: data ?? false,
            lastSyncedAt: lastSyncedAt ?? DateTime.now(),
            containerId: containerId ?? '',
            description: description ?? '',
            type: type ?? '',
            tokenTemplates: tokenTemplates,
          ),
        'TokenContainerStateSynced' => TokenContainerStateSynced(
            lastSyncedAt: lastSyncedAt ?? DateTime.now(),
            containerId: containerId ?? '',
            description: description ?? '',
            type: type ?? '',
            tokenTemplates: tokenTemplates,
          ),
        'TokenContainerStateSyncing' => TokenContainerStateSyncing(
            syncStartedAt: dateTime ?? DateTime.now(),
            lastSyncedAt: lastSyncedAt,
            containerId: containerId ?? '',
            description: description ?? '',
            type: type ?? '',
            tokenTemplates: tokenTemplates,
          ),
        'TokenContainerStateUnsynced' => TokenContainerStateUnsynced(
            syncAttempts: data is num ? data.floor() : 1,
            lastSyncedAt: lastSyncedAt,
            containerId: containerId ?? '',
            description: description ?? '',
            type: type ?? '',
            tokenTemplates: tokenTemplates,
          ),
        'TokenContainerStateError' => TokenContainerStateError(
            error: data,
            lastSyncedAt: lastSyncedAt,
            containerId: containerId ?? '',
            description: description ?? '',
            type: type ?? '',
            tokenTemplates: tokenTemplates,
          ),
        'TokenContainerStateDeactivated' => TokenContainerStateDeactivated(
            reason: data,
            deactivatedAt: dateTime ?? DateTime.now(),
            lastSyncedAt: lastSyncedAt,
            containerId: containerId ?? '',
            description: description ?? '',
            type: type ?? '',
            tokenTemplates: tokenTemplates,
          ),
        'TokenContainerStateDeleted' => TokenContainerStateDeleted(
            reason: data,
            deletedAt: dateTime ?? DateTime.now(),
            lastSyncedAt: lastSyncedAt,
            containerId: containerId ?? '',
            description: description ?? '',
            type: type ?? '',
            tokenTemplates: tokenTemplates,
          ),
        _ => throw UnimplementedError(stateType),
      };

  T as<T extends TokenContainerState>({dynamic data, DateTime? dateTime}) => switch (T) {
        const (TokenContainerStateUninitialized) => const TokenContainerStateUninitialized() as T,
        const (TokenContainerStateSynced) => TokenContainerStateSynced(
            lastSyncedAt: lastSyncedAt ?? lastSyncedAt ?? DateTime.now(),
            containerId: containerId,
            description: description,
            type: type,
            tokenTemplates: tokenTemplates,
          ) as T,
        const (TokenContainerStateSyncing) => TokenContainerStateSyncing(
            lastSyncedAt: lastSyncedAt,
            syncStartedAt: dateTime ?? lastSyncedAt ?? DateTime.now(),
            containerId: containerId,
            description: description,
            type: type,
            tokenTemplates: tokenTemplates,
          ) as T,
        const (TokenContainerStateUnsynced) => this is TokenContainerStateUnsynced
            ? (this as TokenContainerStateUnsynced).withIncrementedSyncAttempts() as T
            : TokenContainerStateUnsynced(
                lastSyncedAt: lastSyncedAt,
                syncAttempts: data is num ? data.floor() : 1,
                containerId: containerId,
                description: description,
                type: type,
                tokenTemplates: tokenTemplates,
              ) as T,
        const (TokenContainerStateError) => TokenContainerStateError(
            error: data,
            lastSyncedAt: lastSyncedAt,
            containerId: containerId,
            description: description,
            type: type,
            tokenTemplates: tokenTemplates,
          ) as T,
        const (TokenContainerStateDeactivated) => TokenContainerStateDeactivated(
            reason: data,
            deactivatedAt: dateTime ?? lastSyncedAt ?? DateTime.now(),
            lastSyncedAt: lastSyncedAt,
            containerId: containerId,
            description: description,
            type: type,
            tokenTemplates: tokenTemplates,
          ) as T,
        const (TokenContainerStateDeleted) => TokenContainerStateDeleted(
            reason: data,
            deletedAt: dateTime ?? lastSyncedAt ?? DateTime.now(),
            lastSyncedAt: lastSyncedAt,
            containerId: containerId,
            description: description,
            type: type,
            tokenTemplates: tokenTemplates,
          ) as T,
        _ => throw UnimplementedError(),
      };

  @override
  Map<String, dynamic> toJson() {
    final json = switch (this) {
      TokenContainerStateUninitialized() => _$TokenContainerStateUninitializedToJson(this as TokenContainerStateUninitialized),
      TokenContainerStateModified() => _$TokenContainerStateModifiedToJson(this as TokenContainerStateModified),
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

  @override
  TokenContainerState copyWith({
    String? containerId,
    String? description,
    String? type,
    List<TokenTemplate>? tokenTemplates,
    DateTime? lastSyncedAt,
  });

  T copyTransformInto<T extends TokenContainerState>({
    dynamic data,
    DateTime? dateTime,
    DateTime? lastSyncedAt,
    String? containerId,
    String? description,
    String? type,
    List<TokenTemplate>? tokenTemplates,
  }) {
    final copied = copyWith(
      containerId: containerId,
      description: description,
      type: type,
      tokenTemplates: tokenTemplates,
    );
    return copied.as<T>(data: data, dateTime: dateTime);
  }


}

/// ContainerState is not initialized
@JsonSerializable()
class TokenContainerStateUninitialized extends TokenContainerState {
  const TokenContainerStateUninitialized()
      : super(
          lastSyncedAt: null,
          containerId: '',
          description: '',
          type: '',
          tokenTemplates: const [],
        );

  @override
  TokenContainerStateUnsynced copyWith({
    String? containerId,
    String? description,
    String? type,
    List<TokenTemplate>? tokenTemplates,
    DateTime? lastSyncedAt,
  }) {
    return TokenContainerStateUnsynced(
      lastSyncedAt: lastSyncedAt ?? lastSyncedAt,
      containerId: containerId ?? this.containerId,
      description: description ?? this.description,
      type: type ?? this.type,
      tokenTemplates: tokenTemplates ?? this.tokenTemplates,
    );
  }
}

/// ContainerState is modified
@JsonSerializable()
class TokenContainerStateModified extends TokenContainerState {
  DateTime lastModifiedAt;
  bool highPriority;
  TokenContainerStateModified({
    required this.lastModifiedAt,
    required this.highPriority,
    required DateTime lastSyncedAt,
    required super.containerId,
    required super.description,
    required super.type,
    required super.tokenTemplates,
  }) : super(lastSyncedAt: lastSyncedAt);

  @override
  TokenContainerStateModified copyWith({
    String? containerId,
    String? description,
    String? type,
    List<TokenTemplate>? tokenTemplates,
    DateTime? lastSyncedAt,
    DateTime? lastModifiedAt,
    bool? highPriority,
  }) {
    return TokenContainerStateModified(
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      highPriority: highPriority ?? this.highPriority,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt ?? DateTime.now(),
      containerId: containerId ?? this.containerId,
      description: description ?? this.description,
      type: type ?? this.type,
      tokenTemplates: tokenTemplates ?? this.tokenTemplates,
    );
  }
}

/// ContainerState is successfully synced with repo
@JsonSerializable()
class TokenContainerStateSynced extends TokenContainerState {
  TokenContainerStateSynced({
    required DateTime lastSyncedAt,
    required super.containerId,
    required super.description,
    required super.type,
    required super.tokenTemplates,
  }) : super(lastSyncedAt: lastSyncedAt);

  @override
  TokenContainerStateSynced copyWith({
    String? containerId,
    String? description,
    String? type,
    List<TokenTemplate>? tokenTemplates,
    DateTime? lastSyncedAt,
  }) {
    return TokenContainerStateSynced(
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt ?? DateTime.now(),
      containerId: containerId ?? this.containerId,
      description: description ?? this.description,
      type: type ?? this.type,
      tokenTemplates: tokenTemplates ?? this.tokenTemplates,
    );
  }
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
    required super.tokenTemplates,
  });

  @override
  TokenContainerStateSyncing copyWith({
    String? containerId,
    String? description,
    String? type,
    List<TokenTemplate>? tokenTemplates,
    DateTime? lastSyncedAt,
    DateTime? syncStartedAt,
    Duration? timeOut,
  }) {
    return TokenContainerStateSyncing(
      syncStartedAt: syncStartedAt ?? this.syncStartedAt,
      timeOut: timeOut ?? this.timeOut,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      containerId: containerId ?? this.containerId,
      description: description ?? this.description,
      type: type ?? this.type,
      tokenTemplates: tokenTemplates ?? this.tokenTemplates,
    );
  }
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
    required super.tokenTemplates,
  });

  TokenContainerStateUnsynced withIncrementedSyncAttempts() => withSyncAttempts(syncAttempts + 1);
  TokenContainerStateUnsynced withSyncAttempts(int syncAttempts) => TokenContainerStateUnsynced(
        syncAttempts: syncAttempts,
        lastSyncedAt: lastSyncedAt,
        containerId: containerId,
        description: description,
        type: type,
        tokenTemplates: tokenTemplates,
      );

  @override
  TokenContainerStateUnsynced copyWith({
    String? containerId,
    String? description,
    String? type,
    List<TokenTemplate>? tokenTemplates,
    DateTime? lastSyncedAt,
    int? syncAttempts,
  }) {
    return TokenContainerStateUnsynced(
      syncAttempts: syncAttempts ?? this.syncAttempts,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      containerId: containerId ?? this.containerId,
      description: description ?? this.description,
      type: type ?? this.type,
      tokenTemplates: tokenTemplates ?? this.tokenTemplates,
    );
  }
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
    required super.tokenTemplates,
  });

  @override
  TokenContainerStateError copyWith({
    String? containerId,
    String? description,
    String? type,
    List<TokenTemplate>? tokenTemplates,
    DateTime? lastSyncedAt,
    dynamic error,
  }) {
    return TokenContainerStateError(
      error: error ?? this.error,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      containerId: containerId ?? this.containerId,
      description: description ?? this.description,
      type: type ?? this.type,
      tokenTemplates: tokenTemplates ?? this.tokenTemplates,
    );
  }
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
    required super.tokenTemplates,
  });

  @override
  TokenContainerStateDeactivated copyWith({
    String? containerId,
    String? description,
    String? type,
    List<TokenTemplate>? tokenTemplates,
    DateTime? lastSyncedAt,
    DateTime? deactivatedAt,
    dynamic reason,
  }) {
    return TokenContainerStateDeactivated(
      reason: reason ?? this.reason,
      deactivatedAt: deactivatedAt ?? deactivatedAt ?? DateTime.now(),
      lastSyncedAt: lastSyncedAt ?? lastSyncedAt,
      containerId: containerId ?? this.containerId,
      description: description ?? this.description,
      type: type ?? this.type,
      tokenTemplates: tokenTemplates ?? this.tokenTemplates,
    );
  }
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
    required super.tokenTemplates,
  });

  @override
  TokenContainerStateDeleted copyWith({
    String? containerId,
    String? description,
    String? type,
    List<TokenTemplate>? tokenTemplates,
    DateTime? lastSyncedAt,
    DateTime? deletedAt,
    dynamic reason,
  }) {
    return TokenContainerStateDeleted(
      reason: reason ?? this.reason,
      deletedAt: deletedAt ?? this.deletedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      containerId: containerId ?? this.containerId,
      description: description ?? this.description,
      type: type ?? this.type,
      tokenTemplates: tokenTemplates ?? this.tokenTemplates,
    );
  }
}
