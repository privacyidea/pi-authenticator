/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// import 'package:json_annotation/json_annotation.dart';

// import '../token_container.dart';

// part 'token_container_state.g.dart';

// sealed class TokenContainer extends TokenContainer {
//   final DateTime? lastSyncedAt;

//   const TokenContainer({
//     required this.lastSyncedAt,
//     // TokenContainer
//     required super.serial,
//     required super.description,
//     required super.type,
//     required super.syncedTokenTemplates,
//     required super.localTokenTemplates,
//   });

//   factory TokenContainer.uninitialized(List<TokenTemplate> localTokenTemplates) =>
//       TokenContainerUninitialized(localTokenTemplates: localTokenTemplates);

//   factory TokenContainer.fromJson(Map<String, dynamic> json) => switch (json['type']) {
//         const ('TokenContainerUninitialized') => _$TokenContainerUninitializedFromJson(json),
//         const ('TokenContainerModified') => _$TokenContainerModifiedFromJson(json),
//         const ('TokenContainerSynced') => _$TokenContainerSyncedFromJson(json),
//         // const ('TokenContainerSyncing') => _$TokenContainerSyncingFromJson(json),
//         const ('TokenContainerUnsynced') => _$TokenContainerUnsyncedFromJson(json),
//         const ('TokenContainerError') => _$TokenContainerErrorFromJson(json),
//         const ('TokenContainerDeactivated') => _$TokenContainerDeactivatedFromJson(json),
//         const ('TokenContainerDeleted') => _$TokenContainerDeletedFromJson(json),
//         _ => throw UnimplementedError(json['type']),
//       };

//   factory TokenContainer.fromTypeString({
//     required String stateType,
//     dynamic data,
//     DateTime? dateTime,
//     String? serial,
//     String? description,
//     String? type,
//     List<TokenTemplate> syncedTokenTemplates = const [],
//     List<TokenTemplate> localTokenTemplates = const [],
//     DateTime? lastSyncedAt,
//   }) =>
//       switch (stateType) {
//         'TokenContainerUninitialized' => TokenContainerUninitialized(localTokenTemplates: localTokenTemplates),
//         'TokenContainerModified' => TokenContainerModified(
//             lastModifiedAt: dateTime ?? DateTime.now(),
//             lastSyncedAt: lastSyncedAt ?? DateTime.now(),
//             serial: serial ?? '',
//             description: description ?? '',
//             type: type ?? '',
//             syncedTokenTemplates: syncedTokenTemplates,
//             localTokenTemplates: localTokenTemplates,
//           ),
//         'TokenContainerSynced' => TokenContainerSynced(
//             lastSyncedAt: lastSyncedAt ?? DateTime.now(),
//             serial: serial ?? '',
//             description: description ?? '',
//             type: type ?? '',
//             syncedTokenTemplates: syncedTokenTemplates,
//           ),
//         // 'TokenContainerSyncing' => TokenContainerSyncing(
//         //     syncStartedAt: dateTime ?? DateTime.now(),
//         //     lastSyncedAt: lastSyncedAt,
//         //     serial: serial ?? '',
//         //     description: description ?? '',
//         //     type: type ?? '',
//         //     syncedTokenTemplates: tokenTemplates,
//         //   ),
//         'TokenContainerUnsynced' => TokenContainerUnsynced(
//             syncAttempts: data is num ? data.floor() : 1,
//             lastSyncedAt: lastSyncedAt,
//             serial: serial ?? '',
//             description: description ?? '',
//             type: type ?? '',
//             syncedTokenTemplates: syncedTokenTemplates,
//             localTokenTemplates: localTokenTemplates,
//           ),
//         'TokenContainerError' => TokenContainerError(
//             error: data,
//             lastSyncedAt: lastSyncedAt,
//             serial: serial ?? '',
//             description: description ?? '',
//             type: type ?? '',
//             syncedTokenTemplates: syncedTokenTemplates,
//             localTokenTemplates: localTokenTemplates,
//           ),
//         'TokenContainerDeactivated' => TokenContainerDeactivated(
//             reason: data,
//             deactivatedAt: dateTime ?? DateTime.now(),
//             lastSyncedAt: lastSyncedAt,
//             serial: serial ?? '',
//             description: description ?? '',
//             type: type ?? '',
//             syncedTokenTemplates: syncedTokenTemplates,
//             localTokenTemplates: localTokenTemplates,
//           ),
//         'TokenContainerDeleted' => TokenContainerDeleted(
//             reason: data,
//             deletedAt: dateTime ?? DateTime.now(),
//             lastSyncedAt: lastSyncedAt,
//             serial: serial ?? '',
//             description: description ?? '',
//             type: type ?? '',
//             syncedTokenTemplates: syncedTokenTemplates,
//             localTokenTemplates: localTokenTemplates,
//           ),
//         _ => throw UnimplementedError(stateType),
//       };

//   T as<T extends TokenContainer>({dynamic data, DateTime? dateTime}) => switch (T) {
//         const (TokenContainerUninitialized) => TokenContainerUninitialized(localTokenTemplates: localTokenTemplates) as T,
//         const (TokenContainerSynced) => TokenContainerSynced(
//             lastSyncedAt: lastSyncedAt ?? lastSyncedAt ?? DateTime.now(),
//             serial: serial,
//             description: description,
//             type: type,
//             syncedTokenTemplates: syncedTokenTemplates,
//           ) as T,
//         // const (TokenContainerSyncing) => TokenContainerSyncing(
//         //     lastSyncedAt: lastSyncedAt,
//         //     syncStartedAt: dateTime ?? lastSyncedAt ?? DateTime.now(),
//         //     serial: serial,
//         //     description: description,
//         //     type: type,
//         //     tokenTemplates: syncedTokenTemplates,
//         //   ) as T,
//         const (TokenContainerUnsynced) => this is TokenContainerUnsynced
//             ? (this as TokenContainerUnsynced).withIncrementedSyncAttempts() as T
//             : TokenContainerUnsynced(
//                 lastSyncedAt: lastSyncedAt,
//                 syncAttempts: data is num ? data.floor() : 1,
//                 serial: serial,
//                 description: description,
//                 type: type,
//                 syncedTokenTemplates: syncedTokenTemplates,
//                 localTokenTemplates: localTokenTemplates,
//               ) as T,
//         const (TokenContainerError) => TokenContainerError(
//             error: data,
//             lastSyncedAt: lastSyncedAt,
//             serial: serial,
//             description: description,
//             type: type,
//             syncedTokenTemplates: syncedTokenTemplates,
//             localTokenTemplates: localTokenTemplates,
//           ) as T,
//         const (TokenContainerDeactivated) => TokenContainerDeactivated(
//             reason: data,
//             deactivatedAt: dateTime ?? lastSyncedAt ?? DateTime.now(),
//             lastSyncedAt: lastSyncedAt,
//             serial: serial,
//             description: description,
//             type: type,
//             syncedTokenTemplates: syncedTokenTemplates,
//             localTokenTemplates: localTokenTemplates,
//           ) as T,
//         const (TokenContainerDeleted) => TokenContainerDeleted(
//             reason: data,
//             deletedAt: dateTime ?? lastSyncedAt ?? DateTime.now(),
//             lastSyncedAt: lastSyncedAt,
//             serial: serial,
//             description: description,
//             type: type,
//             syncedTokenTemplates: syncedTokenTemplates,
//             localTokenTemplates: localTokenTemplates,
//           ) as T,
//         _ => throw UnimplementedError(),
//       };

//   @override
//   Map<String, dynamic> toJson() {
//     final json = switch (this) {
//       TokenContainerUninitialized() => _$TokenContainerUninitializedToJson(this as TokenContainerUninitialized),
//       TokenContainerModified() => _$TokenContainerModifiedToJson(this as TokenContainerModified),
//       TokenContainerSynced() => _$TokenContainerSyncedToJson(this as TokenContainerSynced),
//       // 'TokenContainerSyncing() => _$TokenContainerSyncingToJson(this as TokenContainerSyncing),
//       TokenContainerUnsynced() => _$TokenContainerUnsyncedToJson(this as TokenContainerUnsynced),
//       TokenContainerError() => _$TokenContainerErrorToJson(this as TokenContainerError),
//       TokenContainerDeactivated() => _$TokenContainerDeactivatedToJson(this as TokenContainerDeactivated),
//       TokenContainerDeleted() => _$TokenContainerDeletedToJson(this as TokenContainerDeleted),
//     };
//     json['type'] = runtimeType.toString();
//     return json;
//   }

//   @override
//   TokenContainerModified copyWith({
//     String? serial,
//     String? description,
//     String? type,
//     List<TokenTemplate>? syncedTokenTemplates,
//     List<TokenTemplate>? localTokenTemplates,
//     DateTime? lastSyncedAt,
//   });

//   T copyTransformInto<T extends TokenContainer>({
//     dynamic data,
//     DateTime? dateTime,
//     DateTime? lastSyncedAt,
//     String? serial,
//     String? description,
//     String? type,
//     List<TokenTemplate>? tokenTemplates,
//   }) {
//     final copied = copyWith(
//       serial: serial,
//       description: description,
//       type: type,
//       syncedTokenTemplates: tokenTemplates,
//     );
//     return copied.as<T>(data: data, dateTime: dateTime);
//   }
// }

// /// ContainerState is not initialized
// @JsonSerializable()
// class TokenContainerUninitialized extends TokenContainer {
//   const TokenContainerUninitialized({required super.localTokenTemplates})
//       : super(
//           lastSyncedAt: null,
//           serial: '',
//           description: '',
//           type: '',
//           syncedTokenTemplates: const [],
//         );

//   @override
//   TokenContainerModified copyWith({
//     String? serial,
//     String? description,
//     String? type,
//     List<TokenTemplate>? syncedTokenTemplates,
//     List<TokenTemplate>? localTokenTemplates,
//     DateTime? lastSyncedAt,
//   }) {
//     return TokenContainerModified(
//       lastModifiedAt: DateTime.now(),
//       lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
//       serial: serial ?? this.serial,
//       description: description ?? this.description,
//       type: type ?? this.type,
//       syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
//       localTokenTemplates: localTokenTemplates ?? this.localTokenTemplates,
//     );
//   }
// }

// /// ContainerState is modified
// @JsonSerializable()
// class TokenContainerModified extends TokenContainer {
//   DateTime lastModifiedAt;
//   TokenContainerModified({
//     required this.lastModifiedAt,
//     required super.lastSyncedAt,
//     required super.serial,
//     required super.description,
//     required super.type,
//     required super.syncedTokenTemplates,
//     required super.localTokenTemplates,
//   });

//   @override
//   TokenContainerModified copyWith({
//     String? serial,
//     String? description,
//     String? type,
//     List<TokenTemplate>? syncedTokenTemplates,
//     List<TokenTemplate>? localTokenTemplates,
//     DateTime? lastSyncedAt,
//     DateTime? lastModifiedAt,
//   }) {
//     return TokenContainerModified(
//       lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
//       lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt ?? DateTime.now(),
//       serial: serial ?? this.serial,
//       description: description ?? this.description,
//       type: type ?? this.type,
//       syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
//       localTokenTemplates: localTokenTemplates ?? this.localTokenTemplates,
//     );
//   }
// }

// /// ContainerState is successfully synced with repo
// @JsonSerializable()
// class TokenContainerSynced extends TokenContainer {
//   TokenContainerSynced({
//     required super.serial,
//     required super.description,
//     required super.type,
//     required super.syncedTokenTemplates,
//     DateTime? lastSyncedAt,
//   }) : super(lastSyncedAt: lastSyncedAt ?? DateTime.now(), localTokenTemplates: const []);

//   @override
//   TokenContainerModified copyWith({
//     String? serial,
//     String? description,
//     String? type,
//     List<TokenTemplate>? syncedTokenTemplates,
//     List<TokenTemplate>? localTokenTemplates,
//     DateTime? lastSyncedAt,
//     DateTime? lastModifiedAt,
//   }) {
//     return TokenContainerModified(
//       lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
//       serial: serial ?? this.serial,
//       description: description ?? this.description,
//       type: type ?? this.type,
//       syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
//       localTokenTemplates: const [],
//       lastModifiedAt: lastModifiedAt ?? DateTime.now(),
//     );
//   }
// }

// // /// ContainerState is currently syncing
// // @JsonSerializable()
// // class TokenContainerSyncing extends TokenContainer {
// //   final DateTime syncStartedAt;
// //   final Duration timeOut;
// //   get isSyncing => DateTime.now().difference(syncStartedAt) < timeOut;
// //   get isTimedOut => DateTime.now().difference(syncStartedAt) > timeOut;
// //   const TokenContainerSyncing({
// //     required this.syncStartedAt,
// //     this.timeOut = const Duration(seconds: 30),
// //     required super.lastSyncedAt,
// //     required super.serial,
// //     required super.description,
// //     required super.type,
// //     required super.tokenTemplates,
// //   });

// //   @override
// //   TokenContainerSyncing copyWith({
// //     String? serial,
// //     String? description,
// //     String? type,
// //     List<TokenTemplate>? syncedTokenTemplates,
// //     DateTime? lastSyncedAt,
// //     DateTime? syncStartedAt,
// //     Duration? timeOut,
// //   }) {
// //     return TokenContainerSyncing(
// //       syncStartedAt: syncStartedAt ?? this.syncStartedAt,
// //       timeOut: timeOut ?? this.timeOut,
// //       lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
// //       serial: serial ?? this.serial,
// //       description: description ?? this.description,
// //       type: type ?? this.type,
// //       tokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
// //     );
// //   }
// // }

// /// ContainerState is failed last sync attempt
// @JsonSerializable()
// class TokenContainerUnsynced extends TokenContainer {
//   final int syncAttempts;
//   final dynamic lastError;

//   TokenContainerUnsynced({
//     this.syncAttempts = 1,
//     this.lastError,
//     required super.lastSyncedAt,
//     required super.serial,
//     required super.description,
//     required super.type,
//     required super.syncedTokenTemplates,
//     required super.localTokenTemplates,
//   });

//   TokenContainerUnsynced withIncrementedSyncAttempts() => withSyncAttempts(syncAttempts + 1);
//   TokenContainerUnsynced withSyncAttempts(int syncAttempts) => TokenContainerUnsynced(
//         syncAttempts: syncAttempts,
//         lastSyncedAt: lastSyncedAt,
//         serial: serial,
//         description: description,
//         type: type,
//         syncedTokenTemplates: syncedTokenTemplates,
//         localTokenTemplates: localTokenTemplates,
//       );

//   @override
//   TokenContainerModified copyWith({
//     String? serial,
//     String? description,
//     String? type,
//     List<TokenTemplate>? syncedTokenTemplates,
//     List<TokenTemplate>? localTokenTemplates,
//     DateTime? lastSyncedAt,
//     DateTime? lastModifiedAt,
//     int? syncAttempts,
//   }) {
//     return TokenContainerModified(
//       lastModifiedAt: lastModifiedAt ?? DateTime.now(),
//       lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
//       serial: serial ?? this.serial,
//       description: description ?? this.description,
//       type: type ?? this.type,
//       syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
//       localTokenTemplates: this.localTokenTemplates,
//     );
//   }
// }

// /// ContainerState is in error state
// @JsonSerializable()
// class TokenContainerError extends TokenContainer {
//   final dynamic error;
//   TokenContainerError({
//     required this.error,
//     super.lastSyncedAt,
//     super.serial = 'Error',
//     String? description,
//     super.type = 'Error',
//     super.syncedTokenTemplates = const [],
//     super.localTokenTemplates = const [],
//   }) : super(description: description ?? error.toString());

//   @override
//   TokenContainerModified copyWith({
//     String? serial,
//     String? description,
//     String? type,
//     List<TokenTemplate>? syncedTokenTemplates,
//     List<TokenTemplate>? localTokenTemplates,
//     DateTime? lastSyncedAt,
//     DateTime? lastModifiedAt,
//   }) {
//     return TokenContainerModified(
//       lastModifiedAt: lastModifiedAt ?? DateTime.now(),
//       lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
//       serial: serial ?? this.serial,
//       description: description ?? this.description,
//       type: type ?? this.type,
//       syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
//       localTokenTemplates: this.localTokenTemplates,
//     );
//   }
// }

// /// ContainerState is deactivated
// @JsonSerializable()
// class TokenContainerDeactivated extends TokenContainer {
//   final DateTime deactivatedAt;
//   final dynamic reason;
//   TokenContainerDeactivated({
//     required this.reason,
//     required this.deactivatedAt,
//     required super.lastSyncedAt,
//     required super.serial,
//     required super.description,
//     required super.type,
//     required super.syncedTokenTemplates,
//     required super.localTokenTemplates,
//   });

//   @override
//   TokenContainerModified copyWith({
//     String? serial,
//     String? description,
//     String? type,
//     List<TokenTemplate>? syncedTokenTemplates,
//     List<TokenTemplate>? localTokenTemplates,
//     DateTime? lastSyncedAt,
//     DateTime? lastModifiedAt,
//   }) {
//     return TokenContainerModified(
//       lastModifiedAt: lastModifiedAt ?? DateTime.now(),
//       lastSyncedAt: lastSyncedAt ?? lastSyncedAt,
//       serial: serial ?? this.serial,
//       description: description ?? this.description,
//       type: type ?? this.type,
//       syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
//       localTokenTemplates: this.localTokenTemplates,
//     );
//   }
// }

// /// ContainerState is deleted repo-sseriale
// @JsonSerializable()
// class TokenContainerDeleted extends TokenContainer {
//   final DateTime deletedAt;
//   final dynamic reason;
//   TokenContainerDeleted({
//     required this.reason,
//     required this.deletedAt,
//     required super.lastSyncedAt,
//     required super.serial,
//     required super.description,
//     required super.type,
//     required super.syncedTokenTemplates,
//     required super.localTokenTemplates,
//   });

//   @override
//   TokenContainerModified copyWith({
//     String? serial,
//     String? description,
//     String? type,
//     List<TokenTemplate>? syncedTokenTemplates,
//     List<TokenTemplate>? localTokenTemplates,
//     DateTime? lastSyncedAt,
//     DateTime? lastModifiedAt,

//   }) {
//     return TokenContainerModified(
//       lastModifiedAt: lastModifiedAt ?? DateTime.now(),
//       lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
//       serial: serial ?? this.serial,
//       description: description ?? this.description,
//       type: type ?? this.type,
//       syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
//       localTokenTemplates: this.localTokenTemplates,
//     );
//   }
// }
