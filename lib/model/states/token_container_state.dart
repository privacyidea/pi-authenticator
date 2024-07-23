import 'package:json_annotation/json_annotation.dart';

import '../token_container.dart';

part 'token_container_state.g.dart';

sealed class TokenContainerState extends TokenContainer {
  final DateTime? lastSyncedAt;

  const TokenContainerState({
    required this.lastSyncedAt,
    // TokenContainer
    required super.serial,
    required super.description,
    required super.type,
    required super.syncedTokenTemplates,
    required super.localTokenTemplates,
  });

  factory TokenContainerState.uninitialized(List<TokenTemplate> localTokenTemplates) =>
      TokenContainerStateUninitialized(localTokenTemplates: localTokenTemplates);

  factory TokenContainerState.fromJson(Map<String, dynamic> json) => switch (json['type']) {
        const ('TokenContainerStateUninitialized') => _$TokenContainerStateUninitializedFromJson(json),
        const ('TokenContainerStateModified') => _$TokenContainerStateModifiedFromJson(json),
        const ('TokenContainerStateSynced') => _$TokenContainerStateSyncedFromJson(json),
        // const ('TokenContainerStateSyncing') => _$TokenContainerStateSyncingFromJson(json),
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
    String? serial,
    String? description,
    String? type,
    List<TokenTemplate> syncedTokenTemplates = const [],
    List<TokenTemplate> localTokenTemplates = const [],
    DateTime? lastSyncedAt,
  }) =>
      switch (stateType) {
        'TokenContainerStateUninitialized' => TokenContainerStateUninitialized(localTokenTemplates: localTokenTemplates),
        'TokenContainerStateModified' => TokenContainerStateModified(
            lastModifiedAt: dateTime ?? DateTime.now(),
            lastSyncedAt: lastSyncedAt ?? DateTime.now(),
            serial: serial ?? '',
            description: description ?? '',
            type: type ?? '',
            syncedTokenTemplates: syncedTokenTemplates,
            localTokenTemplates: localTokenTemplates,
          ),
        'TokenContainerStateSynced' => TokenContainerStateSynced(
            lastSyncedAt: lastSyncedAt ?? DateTime.now(),
            serial: serial ?? '',
            description: description ?? '',
            type: type ?? '',
            syncedTokenTemplates: syncedTokenTemplates,
          ),
        // 'TokenContainerStateSyncing' => TokenContainerStateSyncing(
        //     syncStartedAt: dateTime ?? DateTime.now(),
        //     lastSyncedAt: lastSyncedAt,
        //     serial: serial ?? '',
        //     description: description ?? '',
        //     type: type ?? '',
        //     syncedTokenTemplates: tokenTemplates,
        //   ),
        'TokenContainerStateUnsynced' => TokenContainerStateUnsynced(
            syncAttempts: data is num ? data.floor() : 1,
            lastSyncedAt: lastSyncedAt,
            serial: serial ?? '',
            description: description ?? '',
            type: type ?? '',
            syncedTokenTemplates: syncedTokenTemplates,
            localTokenTemplates: localTokenTemplates,
          ),
        'TokenContainerStateError' => TokenContainerStateError(
            error: data,
            lastSyncedAt: lastSyncedAt,
            serial: serial ?? '',
            description: description ?? '',
            type: type ?? '',
            syncedTokenTemplates: syncedTokenTemplates,
            localTokenTemplates: localTokenTemplates,
          ),
        'TokenContainerStateDeactivated' => TokenContainerStateDeactivated(
            reason: data,
            deactivatedAt: dateTime ?? DateTime.now(),
            lastSyncedAt: lastSyncedAt,
            serial: serial ?? '',
            description: description ?? '',
            type: type ?? '',
            syncedTokenTemplates: syncedTokenTemplates,
            localTokenTemplates: localTokenTemplates,
          ),
        'TokenContainerStateDeleted' => TokenContainerStateDeleted(
            reason: data,
            deletedAt: dateTime ?? DateTime.now(),
            lastSyncedAt: lastSyncedAt,
            serial: serial ?? '',
            description: description ?? '',
            type: type ?? '',
            syncedTokenTemplates: syncedTokenTemplates,
            localTokenTemplates: localTokenTemplates,
          ),
        _ => throw UnimplementedError(stateType),
      };

  T as<T extends TokenContainerState>({dynamic data, DateTime? dateTime}) => switch (T) {
        const (TokenContainerStateUninitialized) => TokenContainerStateUninitialized(localTokenTemplates: localTokenTemplates) as T,
        const (TokenContainerStateSynced) => TokenContainerStateSynced(
            lastSyncedAt: lastSyncedAt ?? lastSyncedAt ?? DateTime.now(),
            serial: serial,
            description: description,
            type: type,
            syncedTokenTemplates: syncedTokenTemplates,
          ) as T,
        // const (TokenContainerStateSyncing) => TokenContainerStateSyncing(
        //     lastSyncedAt: lastSyncedAt,
        //     syncStartedAt: dateTime ?? lastSyncedAt ?? DateTime.now(),
        //     serial: serial,
        //     description: description,
        //     type: type,
        //     tokenTemplates: syncedTokenTemplates,
        //   ) as T,
        const (TokenContainerStateUnsynced) => this is TokenContainerStateUnsynced
            ? (this as TokenContainerStateUnsynced).withIncrementedSyncAttempts() as T
            : TokenContainerStateUnsynced(
                lastSyncedAt: lastSyncedAt,
                syncAttempts: data is num ? data.floor() : 1,
                serial: serial,
                description: description,
                type: type,
                syncedTokenTemplates: syncedTokenTemplates,
                localTokenTemplates: localTokenTemplates,
              ) as T,
        const (TokenContainerStateError) => TokenContainerStateError(
            error: data,
            lastSyncedAt: lastSyncedAt,
            serial: serial,
            description: description,
            type: type,
            syncedTokenTemplates: syncedTokenTemplates,
            localTokenTemplates: localTokenTemplates,
          ) as T,
        const (TokenContainerStateDeactivated) => TokenContainerStateDeactivated(
            reason: data,
            deactivatedAt: dateTime ?? lastSyncedAt ?? DateTime.now(),
            lastSyncedAt: lastSyncedAt,
            serial: serial,
            description: description,
            type: type,
            syncedTokenTemplates: syncedTokenTemplates,
            localTokenTemplates: localTokenTemplates,
          ) as T,
        const (TokenContainerStateDeleted) => TokenContainerStateDeleted(
            reason: data,
            deletedAt: dateTime ?? lastSyncedAt ?? DateTime.now(),
            lastSyncedAt: lastSyncedAt,
            serial: serial,
            description: description,
            type: type,
            syncedTokenTemplates: syncedTokenTemplates,
            localTokenTemplates: localTokenTemplates,
          ) as T,
        _ => throw UnimplementedError(),
      };

  @override
  Map<String, dynamic> toJson() {
    final json = switch (this) {
      TokenContainerStateUninitialized() => _$TokenContainerStateUninitializedToJson(this as TokenContainerStateUninitialized),
      TokenContainerStateModified() => _$TokenContainerStateModifiedToJson(this as TokenContainerStateModified),
      TokenContainerStateSynced() => _$TokenContainerStateSyncedToJson(this as TokenContainerStateSynced),
      // 'TokenContainerStateSyncing() => _$TokenContainerStateSyncingToJson(this as TokenContainerStateSyncing),
      TokenContainerStateUnsynced() => _$TokenContainerStateUnsyncedToJson(this as TokenContainerStateUnsynced),
      TokenContainerStateError() => _$TokenContainerStateErrorToJson(this as TokenContainerStateError),
      TokenContainerStateDeactivated() => _$TokenContainerStateDeactivatedToJson(this as TokenContainerStateDeactivated),
      TokenContainerStateDeleted() => _$TokenContainerStateDeletedToJson(this as TokenContainerStateDeleted),
    };
    json['type'] = runtimeType.toString();
    return json;
  }

  @override
  TokenContainerStateModified copyWith({
    String? serial,
    String? description,
    String? type,
    List<TokenTemplate>? syncedTokenTemplates,
    List<TokenTemplate>? localTokenTemplates,
    DateTime? lastSyncedAt,
  });

  T copyTransformInto<T extends TokenContainerState>({
    dynamic data,
    DateTime? dateTime,
    DateTime? lastSyncedAt,
    String? serial,
    String? description,
    String? type,
    List<TokenTemplate>? tokenTemplates,
  }) {
    final copied = copyWith(
      serial: serial,
      description: description,
      type: type,
      syncedTokenTemplates: tokenTemplates,
    );
    return copied.as<T>(data: data, dateTime: dateTime);
  }
}

/// ContainerState is not initialized
@JsonSerializable()
class TokenContainerStateUninitialized extends TokenContainerState {
  const TokenContainerStateUninitialized({required super.localTokenTemplates})
      : super(
          lastSyncedAt: null,
          serial: '',
          description: '',
          type: '',
          syncedTokenTemplates: const [],
        );

  @override
  TokenContainerStateModified copyWith({
    String? serial,
    String? description,
    String? type,
    List<TokenTemplate>? syncedTokenTemplates,
    List<TokenTemplate>? localTokenTemplates,
    DateTime? lastSyncedAt,
  }) {
    return TokenContainerStateModified(
      lastModifiedAt: DateTime.now(),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      serial: serial ?? this.serial,
      description: description ?? this.description,
      type: type ?? this.type,
      syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
      localTokenTemplates: localTokenTemplates ?? this.localTokenTemplates,
    );
  }
}

/// ContainerState is modified
@JsonSerializable()
class TokenContainerStateModified extends TokenContainerState {
  DateTime lastModifiedAt;
  TokenContainerStateModified({
    required this.lastModifiedAt,
    required super.lastSyncedAt,
    required super.serial,
    required super.description,
    required super.type,
    required super.syncedTokenTemplates,
    required super.localTokenTemplates,
  });

  @override
  TokenContainerStateModified copyWith({
    String? serial,
    String? description,
    String? type,
    List<TokenTemplate>? syncedTokenTemplates,
    List<TokenTemplate>? localTokenTemplates,
    DateTime? lastSyncedAt,
    DateTime? lastModifiedAt,
  }) {
    return TokenContainerStateModified(
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt ?? DateTime.now(),
      serial: serial ?? this.serial,
      description: description ?? this.description,
      type: type ?? this.type,
      syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
      localTokenTemplates: localTokenTemplates ?? this.localTokenTemplates,
    );
  }
}

/// ContainerState is successfully synced with repo
@JsonSerializable()
class TokenContainerStateSynced extends TokenContainerState {
  TokenContainerStateSynced({
    required super.serial,
    required super.description,
    required super.type,
    required super.syncedTokenTemplates,
    DateTime? lastSyncedAt,
  }) : super(lastSyncedAt: lastSyncedAt ?? DateTime.now(), localTokenTemplates: const []);

  @override
  TokenContainerStateModified copyWith({
    String? serial,
    String? description,
    String? type,
    List<TokenTemplate>? syncedTokenTemplates,
    List<TokenTemplate>? localTokenTemplates,
    DateTime? lastSyncedAt,
    DateTime? lastModifiedAt,
  }) {
    return TokenContainerStateModified(
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      serial: serial ?? this.serial,
      description: description ?? this.description,
      type: type ?? this.type,
      syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
      localTokenTemplates: const [],
      lastModifiedAt: lastModifiedAt ?? DateTime.now(),
    );
  }
}

// /// ContainerState is currently syncing
// @JsonSerializable()
// class TokenContainerStateSyncing extends TokenContainerState {
//   final DateTime syncStartedAt;
//   final Duration timeOut;
//   get isSyncing => DateTime.now().difference(syncStartedAt) < timeOut;
//   get isTimedOut => DateTime.now().difference(syncStartedAt) > timeOut;
//   const TokenContainerStateSyncing({
//     required this.syncStartedAt,
//     this.timeOut = const Duration(seconds: 30),
//     required super.lastSyncedAt,
//     required super.serial,
//     required super.description,
//     required super.type,
//     required super.tokenTemplates,
//   });

//   @override
//   TokenContainerStateSyncing copyWith({
//     String? serial,
//     String? description,
//     String? type,
//     List<TokenTemplate>? syncedTokenTemplates,
//     DateTime? lastSyncedAt,
//     DateTime? syncStartedAt,
//     Duration? timeOut,
//   }) {
//     return TokenContainerStateSyncing(
//       syncStartedAt: syncStartedAt ?? this.syncStartedAt,
//       timeOut: timeOut ?? this.timeOut,
//       lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
//       serial: serial ?? this.serial,
//       description: description ?? this.description,
//       type: type ?? this.type,
//       tokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
//     );
//   }
// }

/// ContainerState is failed last sync attempt
@JsonSerializable()
class TokenContainerStateUnsynced extends TokenContainerState {
  final int syncAttempts;
  final dynamic lastError;

  TokenContainerStateUnsynced({
    this.syncAttempts = 1,
    this.lastError,
    required super.lastSyncedAt,
    required super.serial,
    required super.description,
    required super.type,
    required super.syncedTokenTemplates,
    required super.localTokenTemplates,
  });

  TokenContainerStateUnsynced withIncrementedSyncAttempts() => withSyncAttempts(syncAttempts + 1);
  TokenContainerStateUnsynced withSyncAttempts(int syncAttempts) => TokenContainerStateUnsynced(
        syncAttempts: syncAttempts,
        lastSyncedAt: lastSyncedAt,
        serial: serial,
        description: description,
        type: type,
        syncedTokenTemplates: syncedTokenTemplates,
        localTokenTemplates: localTokenTemplates,
      );

  @override
  TokenContainerStateModified copyWith({
    String? serial,
    String? description,
    String? type,
    List<TokenTemplate>? syncedTokenTemplates,
    List<TokenTemplate>? localTokenTemplates,
    DateTime? lastSyncedAt,
    DateTime? lastModifiedAt,
    int? syncAttempts,
  }) {
    return TokenContainerStateModified(
      lastModifiedAt: lastModifiedAt ?? DateTime.now(),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      serial: serial ?? this.serial,
      description: description ?? this.description,
      type: type ?? this.type,
      syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
      localTokenTemplates: this.localTokenTemplates,
    );
  }
}

/// ContainerState is in error state
@JsonSerializable()
class TokenContainerStateError extends TokenContainerState {
  final dynamic error;
  TokenContainerStateError({
    required this.error,
    super.lastSyncedAt,
    super.serial = 'Error',
    String? description,
    super.type = 'Error',
    super.syncedTokenTemplates = const [],
    super.localTokenTemplates = const [],
  }) : super(description: description ?? error.toString());

  @override
  TokenContainerStateModified copyWith({
    String? serial,
    String? description,
    String? type,
    List<TokenTemplate>? syncedTokenTemplates,
    List<TokenTemplate>? localTokenTemplates,
    DateTime? lastSyncedAt,
    DateTime? lastModifiedAt,
  }) {
    return TokenContainerStateModified(
      lastModifiedAt: lastModifiedAt ?? DateTime.now(),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      serial: serial ?? this.serial,
      description: description ?? this.description,
      type: type ?? this.type,
      syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
      localTokenTemplates: this.localTokenTemplates,
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
    required super.serial,
    required super.description,
    required super.type,
    required super.syncedTokenTemplates,
    required super.localTokenTemplates,
  });

  @override
  TokenContainerStateModified copyWith({
    String? serial,
    String? description,
    String? type,
    List<TokenTemplate>? syncedTokenTemplates,
    List<TokenTemplate>? localTokenTemplates,
    DateTime? lastSyncedAt,
    DateTime? lastModifiedAt,
  }) {
    return TokenContainerStateModified(
      lastModifiedAt: lastModifiedAt ?? DateTime.now(),
      lastSyncedAt: lastSyncedAt ?? lastSyncedAt,
      serial: serial ?? this.serial,
      description: description ?? this.description,
      type: type ?? this.type,
      syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
      localTokenTemplates: this.localTokenTemplates,
    );
  }
}

/// ContainerState is deleted repo-sseriale
@JsonSerializable()
class TokenContainerStateDeleted extends TokenContainerState {
  final DateTime deletedAt;
  final dynamic reason;
  TokenContainerStateDeleted({
    required this.reason,
    required this.deletedAt,
    required super.lastSyncedAt,
    required super.serial,
    required super.description,
    required super.type,
    required super.syncedTokenTemplates,
    required super.localTokenTemplates,
  });

  @override
  TokenContainerStateModified copyWith({
    String? serial,
    String? description,
    String? type,
    List<TokenTemplate>? syncedTokenTemplates,
    List<TokenTemplate>? localTokenTemplates,
    DateTime? lastSyncedAt,
    DateTime? lastModifiedAt,

  }) {
    return TokenContainerStateModified(
      lastModifiedAt: lastModifiedAt ?? DateTime.now(),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      serial: serial ?? this.serial,
      description: description ?? this.description,
      type: type ?? this.type,
      syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
      localTokenTemplates: this.localTokenTemplates,
    );
  }
}
