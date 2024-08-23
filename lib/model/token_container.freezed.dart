// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_container.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TokenContainer _$TokenContainerFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'uninitialized':
      return TokenContainerUninitialized.fromJson(json);
    case 'synced':
      return TokenContainerSynced.fromJson(json);
    case 'modified':
      return TokenContainerModified.fromJson(json);
    case 'unsynced':
      return TokenContainerUnsynced.fromJson(json);
    case 'notFound':
      return TokenContainerNotFound.fromJson(json);
    case 'error':
      return TokenContainerError.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'TokenContainer',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$TokenContainer {
// Base fields
  String get serverName => throw _privateConstructorUsedError;
  DateTime? get lastSyncAt => throw _privateConstructorUsedError;
  String get serial => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<TokenTemplate> get syncedTokenTemplates =>
      throw _privateConstructorUsedError;
  List<TokenTemplate> get localTokenTemplates =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        uninitialized,
    required TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        synced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)
        modified,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)
        unsynced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)
        notFound,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult? Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TokenContainerUninitialized value) uninitialized,
    required TResult Function(TokenContainerSynced value) synced,
    required TResult Function(TokenContainerModified value) modified,
    required TResult Function(TokenContainerUnsynced value) unsynced,
    required TResult Function(TokenContainerNotFound value) notFound,
    required TResult Function(TokenContainerError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TokenContainerUninitialized value)? uninitialized,
    TResult? Function(TokenContainerSynced value)? synced,
    TResult? Function(TokenContainerModified value)? modified,
    TResult? Function(TokenContainerUnsynced value)? unsynced,
    TResult? Function(TokenContainerNotFound value)? notFound,
    TResult? Function(TokenContainerError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TokenContainerUninitialized value)? uninitialized,
    TResult Function(TokenContainerSynced value)? synced,
    TResult Function(TokenContainerModified value)? modified,
    TResult Function(TokenContainerUnsynced value)? unsynced,
    TResult Function(TokenContainerNotFound value)? notFound,
    TResult Function(TokenContainerError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this TokenContainer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenContainerCopyWith<TokenContainer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenContainerCopyWith<$Res> {
  factory $TokenContainerCopyWith(
          TokenContainer value, $Res Function(TokenContainer) then) =
      _$TokenContainerCopyWithImpl<$Res, TokenContainer>;
  @useResult
  $Res call(
      {String serverName,
      DateTime lastSyncAt,
      String serial,
      String description,
      List<TokenTemplate> syncedTokenTemplates,
      List<TokenTemplate> localTokenTemplates});
}

/// @nodoc
class _$TokenContainerCopyWithImpl<$Res, $Val extends TokenContainer>
    implements $TokenContainerCopyWith<$Res> {
  _$TokenContainerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverName = null,
    Object? lastSyncAt = null,
    Object? serial = null,
    Object? description = null,
    Object? syncedTokenTemplates = null,
    Object? localTokenTemplates = null,
  }) {
    return _then(_value.copyWith(
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      lastSyncAt: null == lastSyncAt
          ? _value.lastSyncAt!
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      syncedTokenTemplates: null == syncedTokenTemplates
          ? _value.syncedTokenTemplates
          : syncedTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
      localTokenTemplates: null == localTokenTemplates
          ? _value.localTokenTemplates
          : localTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenContainerUninitializedImplCopyWith<$Res>
    implements $TokenContainerCopyWith<$Res> {
  factory _$$TokenContainerUninitializedImplCopyWith(
          _$TokenContainerUninitializedImpl value,
          $Res Function(_$TokenContainerUninitializedImpl) then) =
      __$$TokenContainerUninitializedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String serverName,
      DateTime? lastSyncAt,
      String serial,
      String description,
      List<TokenTemplate> syncedTokenTemplates,
      List<TokenTemplate> localTokenTemplates});
}

/// @nodoc
class __$$TokenContainerUninitializedImplCopyWithImpl<$Res>
    extends _$TokenContainerCopyWithImpl<$Res,
        _$TokenContainerUninitializedImpl>
    implements _$$TokenContainerUninitializedImplCopyWith<$Res> {
  __$$TokenContainerUninitializedImplCopyWithImpl(
      _$TokenContainerUninitializedImpl _value,
      $Res Function(_$TokenContainerUninitializedImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverName = null,
    Object? lastSyncAt = freezed,
    Object? serial = null,
    Object? description = null,
    Object? syncedTokenTemplates = null,
    Object? localTokenTemplates = null,
  }) {
    return _then(_$TokenContainerUninitializedImpl(
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      lastSyncAt: freezed == lastSyncAt
          ? _value.lastSyncAt
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      syncedTokenTemplates: null == syncedTokenTemplates
          ? _value._syncedTokenTemplates
          : syncedTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
      localTokenTemplates: null == localTokenTemplates
          ? _value._localTokenTemplates
          : localTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenContainerUninitializedImpl extends TokenContainerUninitialized
    with DiagnosticableTreeMixin {
  const _$TokenContainerUninitializedImpl(
      {this.serverName = 'PrivacyIDEA',
      this.lastSyncAt,
      this.serial = 'none',
      this.description = 'Uninitialized',
      final List<TokenTemplate> syncedTokenTemplates = const [],
      final List<TokenTemplate> localTokenTemplates = const [],
      final String? $type})
      : _syncedTokenTemplates = syncedTokenTemplates,
        _localTokenTemplates = localTokenTemplates,
        $type = $type ?? 'uninitialized',
        super._();

  factory _$TokenContainerUninitializedImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$TokenContainerUninitializedImplFromJson(json);

// Base fields
  @override
  @JsonKey()
  final String serverName;
  @override
  final DateTime? lastSyncAt;
  @override
  @JsonKey()
  final String serial;
  @override
  @JsonKey()
  final String description;
  final List<TokenTemplate> _syncedTokenTemplates;
  @override
  @JsonKey()
  List<TokenTemplate> get syncedTokenTemplates {
    if (_syncedTokenTemplates is EqualUnmodifiableListView)
      return _syncedTokenTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_syncedTokenTemplates);
  }

  final List<TokenTemplate> _localTokenTemplates;
  @override
  @JsonKey()
  List<TokenTemplate> get localTokenTemplates {
    if (_localTokenTemplates is EqualUnmodifiableListView)
      return _localTokenTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_localTokenTemplates);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TokenContainer.uninitialized(serverName: $serverName, lastSyncAt: $lastSyncAt, serial: $serial, description: $description, syncedTokenTemplates: $syncedTokenTemplates, localTokenTemplates: $localTokenTemplates)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TokenContainer.uninitialized'))
      ..add(DiagnosticsProperty('serverName', serverName))
      ..add(DiagnosticsProperty('lastSyncAt', lastSyncAt))
      ..add(DiagnosticsProperty('serial', serial))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('syncedTokenTemplates', syncedTokenTemplates))
      ..add(DiagnosticsProperty('localTokenTemplates', localTokenTemplates));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenContainerUninitializedImpl &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._syncedTokenTemplates, _syncedTokenTemplates) &&
            const DeepCollectionEquality()
                .equals(other._localTokenTemplates, _localTokenTemplates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      serverName,
      lastSyncAt,
      serial,
      description,
      const DeepCollectionEquality().hash(_syncedTokenTemplates),
      const DeepCollectionEquality().hash(_localTokenTemplates));

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenContainerUninitializedImplCopyWith<_$TokenContainerUninitializedImpl>
      get copyWith => __$$TokenContainerUninitializedImplCopyWithImpl<
          _$TokenContainerUninitializedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        uninitialized,
    required TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        synced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)
        modified,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)
        unsynced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)
        notFound,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)
        error,
  }) {
    return uninitialized(serverName, lastSyncAt, serial, description,
        syncedTokenTemplates, localTokenTemplates);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult? Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
  }) {
    return uninitialized?.call(serverName, lastSyncAt, serial, description,
        syncedTokenTemplates, localTokenTemplates);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
    required TResult orElse(),
  }) {
    if (uninitialized != null) {
      return uninitialized(serverName, lastSyncAt, serial, description,
          syncedTokenTemplates, localTokenTemplates);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TokenContainerUninitialized value) uninitialized,
    required TResult Function(TokenContainerSynced value) synced,
    required TResult Function(TokenContainerModified value) modified,
    required TResult Function(TokenContainerUnsynced value) unsynced,
    required TResult Function(TokenContainerNotFound value) notFound,
    required TResult Function(TokenContainerError value) error,
  }) {
    return uninitialized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TokenContainerUninitialized value)? uninitialized,
    TResult? Function(TokenContainerSynced value)? synced,
    TResult? Function(TokenContainerModified value)? modified,
    TResult? Function(TokenContainerUnsynced value)? unsynced,
    TResult? Function(TokenContainerNotFound value)? notFound,
    TResult? Function(TokenContainerError value)? error,
  }) {
    return uninitialized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TokenContainerUninitialized value)? uninitialized,
    TResult Function(TokenContainerSynced value)? synced,
    TResult Function(TokenContainerModified value)? modified,
    TResult Function(TokenContainerUnsynced value)? unsynced,
    TResult Function(TokenContainerNotFound value)? notFound,
    TResult Function(TokenContainerError value)? error,
    required TResult orElse(),
  }) {
    if (uninitialized != null) {
      return uninitialized(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenContainerUninitializedImplToJson(
      this,
    );
  }
}

abstract class TokenContainerUninitialized extends TokenContainer {
  const factory TokenContainerUninitialized(
          {final String serverName,
          final DateTime? lastSyncAt,
          final String serial,
          final String description,
          final List<TokenTemplate> syncedTokenTemplates,
          final List<TokenTemplate> localTokenTemplates}) =
      _$TokenContainerUninitializedImpl;
  const TokenContainerUninitialized._() : super._();

  factory TokenContainerUninitialized.fromJson(Map<String, dynamic> json) =
      _$TokenContainerUninitializedImpl.fromJson;

// Base fields
  @override
  String get serverName;
  @override
  DateTime? get lastSyncAt;
  @override
  String get serial;
  @override
  String get description;
  @override
  List<TokenTemplate> get syncedTokenTemplates;
  @override
  List<TokenTemplate> get localTokenTemplates;

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenContainerUninitializedImplCopyWith<_$TokenContainerUninitializedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TokenContainerSyncedImplCopyWith<$Res>
    implements $TokenContainerCopyWith<$Res> {
  factory _$$TokenContainerSyncedImplCopyWith(_$TokenContainerSyncedImpl value,
          $Res Function(_$TokenContainerSyncedImpl) then) =
      __$$TokenContainerSyncedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String serverName,
      DateTime lastSyncAt,
      String serial,
      String description,
      List<TokenTemplate> syncedTokenTemplates,
      List<TokenTemplate> localTokenTemplates});
}

/// @nodoc
class __$$TokenContainerSyncedImplCopyWithImpl<$Res>
    extends _$TokenContainerCopyWithImpl<$Res, _$TokenContainerSyncedImpl>
    implements _$$TokenContainerSyncedImplCopyWith<$Res> {
  __$$TokenContainerSyncedImplCopyWithImpl(_$TokenContainerSyncedImpl _value,
      $Res Function(_$TokenContainerSyncedImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverName = null,
    Object? lastSyncAt = null,
    Object? serial = null,
    Object? description = null,
    Object? syncedTokenTemplates = null,
    Object? localTokenTemplates = null,
  }) {
    return _then(_$TokenContainerSyncedImpl(
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      lastSyncAt: null == lastSyncAt
          ? _value.lastSyncAt
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      syncedTokenTemplates: null == syncedTokenTemplates
          ? _value._syncedTokenTemplates
          : syncedTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
      localTokenTemplates: null == localTokenTemplates
          ? _value._localTokenTemplates
          : localTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenContainerSyncedImpl extends TokenContainerSynced
    with DiagnosticableTreeMixin {
  const _$TokenContainerSyncedImpl(
      {this.serverName = 'PrivacyIDEA',
      required this.lastSyncAt,
      required this.serial,
      required this.description,
      required final List<TokenTemplate> syncedTokenTemplates,
      required final List<TokenTemplate> localTokenTemplates,
      final String? $type})
      : _syncedTokenTemplates = syncedTokenTemplates,
        _localTokenTemplates = localTokenTemplates,
        $type = $type ?? 'synced',
        super._();

  factory _$TokenContainerSyncedImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenContainerSyncedImplFromJson(json);

// Base fields
  @override
  @JsonKey()
  final String serverName;
  @override
  final DateTime lastSyncAt;
  @override
  final String serial;
  @override
  final String description;
  final List<TokenTemplate> _syncedTokenTemplates;
  @override
  List<TokenTemplate> get syncedTokenTemplates {
    if (_syncedTokenTemplates is EqualUnmodifiableListView)
      return _syncedTokenTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_syncedTokenTemplates);
  }

  final List<TokenTemplate> _localTokenTemplates;
  @override
  List<TokenTemplate> get localTokenTemplates {
    if (_localTokenTemplates is EqualUnmodifiableListView)
      return _localTokenTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_localTokenTemplates);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TokenContainer.synced(serverName: $serverName, lastSyncAt: $lastSyncAt, serial: $serial, description: $description, syncedTokenTemplates: $syncedTokenTemplates, localTokenTemplates: $localTokenTemplates)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TokenContainer.synced'))
      ..add(DiagnosticsProperty('serverName', serverName))
      ..add(DiagnosticsProperty('lastSyncAt', lastSyncAt))
      ..add(DiagnosticsProperty('serial', serial))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('syncedTokenTemplates', syncedTokenTemplates))
      ..add(DiagnosticsProperty('localTokenTemplates', localTokenTemplates));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenContainerSyncedImpl &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._syncedTokenTemplates, _syncedTokenTemplates) &&
            const DeepCollectionEquality()
                .equals(other._localTokenTemplates, _localTokenTemplates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      serverName,
      lastSyncAt,
      serial,
      description,
      const DeepCollectionEquality().hash(_syncedTokenTemplates),
      const DeepCollectionEquality().hash(_localTokenTemplates));

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenContainerSyncedImplCopyWith<_$TokenContainerSyncedImpl>
      get copyWith =>
          __$$TokenContainerSyncedImplCopyWithImpl<_$TokenContainerSyncedImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        uninitialized,
    required TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        synced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)
        modified,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)
        unsynced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)
        notFound,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)
        error,
  }) {
    return synced(serverName, lastSyncAt, serial, description,
        syncedTokenTemplates, localTokenTemplates);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult? Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
  }) {
    return synced?.call(serverName, lastSyncAt, serial, description,
        syncedTokenTemplates, localTokenTemplates);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
    required TResult orElse(),
  }) {
    if (synced != null) {
      return synced(serverName, lastSyncAt, serial, description,
          syncedTokenTemplates, localTokenTemplates);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TokenContainerUninitialized value) uninitialized,
    required TResult Function(TokenContainerSynced value) synced,
    required TResult Function(TokenContainerModified value) modified,
    required TResult Function(TokenContainerUnsynced value) unsynced,
    required TResult Function(TokenContainerNotFound value) notFound,
    required TResult Function(TokenContainerError value) error,
  }) {
    return synced(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TokenContainerUninitialized value)? uninitialized,
    TResult? Function(TokenContainerSynced value)? synced,
    TResult? Function(TokenContainerModified value)? modified,
    TResult? Function(TokenContainerUnsynced value)? unsynced,
    TResult? Function(TokenContainerNotFound value)? notFound,
    TResult? Function(TokenContainerError value)? error,
  }) {
    return synced?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TokenContainerUninitialized value)? uninitialized,
    TResult Function(TokenContainerSynced value)? synced,
    TResult Function(TokenContainerModified value)? modified,
    TResult Function(TokenContainerUnsynced value)? unsynced,
    TResult Function(TokenContainerNotFound value)? notFound,
    TResult Function(TokenContainerError value)? error,
    required TResult orElse(),
  }) {
    if (synced != null) {
      return synced(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenContainerSyncedImplToJson(
      this,
    );
  }
}

abstract class TokenContainerSynced extends TokenContainer {
  const factory TokenContainerSynced(
          {final String serverName,
          required final DateTime lastSyncAt,
          required final String serial,
          required final String description,
          required final List<TokenTemplate> syncedTokenTemplates,
          required final List<TokenTemplate> localTokenTemplates}) =
      _$TokenContainerSyncedImpl;
  const TokenContainerSynced._() : super._();

  factory TokenContainerSynced.fromJson(Map<String, dynamic> json) =
      _$TokenContainerSyncedImpl.fromJson;

// Base fields
  @override
  String get serverName;
  @override
  DateTime get lastSyncAt;
  @override
  String get serial;
  @override
  String get description;
  @override
  List<TokenTemplate> get syncedTokenTemplates;
  @override
  List<TokenTemplate> get localTokenTemplates;

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenContainerSyncedImplCopyWith<_$TokenContainerSyncedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TokenContainerModifiedImplCopyWith<$Res>
    implements $TokenContainerCopyWith<$Res> {
  factory _$$TokenContainerModifiedImplCopyWith(
          _$TokenContainerModifiedImpl value,
          $Res Function(_$TokenContainerModifiedImpl) then) =
      __$$TokenContainerModifiedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String serverName,
      DateTime? lastSyncAt,
      String serial,
      String description,
      List<TokenTemplate> syncedTokenTemplates,
      List<TokenTemplate> localTokenTemplates,
      DateTime lastModifiedAt});
}

/// @nodoc
class __$$TokenContainerModifiedImplCopyWithImpl<$Res>
    extends _$TokenContainerCopyWithImpl<$Res, _$TokenContainerModifiedImpl>
    implements _$$TokenContainerModifiedImplCopyWith<$Res> {
  __$$TokenContainerModifiedImplCopyWithImpl(
      _$TokenContainerModifiedImpl _value,
      $Res Function(_$TokenContainerModifiedImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverName = null,
    Object? lastSyncAt = freezed,
    Object? serial = null,
    Object? description = null,
    Object? syncedTokenTemplates = null,
    Object? localTokenTemplates = null,
    Object? lastModifiedAt = null,
  }) {
    return _then(_$TokenContainerModifiedImpl(
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      lastSyncAt: freezed == lastSyncAt
          ? _value.lastSyncAt
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      syncedTokenTemplates: null == syncedTokenTemplates
          ? _value._syncedTokenTemplates
          : syncedTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
      localTokenTemplates: null == localTokenTemplates
          ? _value._localTokenTemplates
          : localTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
      lastModifiedAt: null == lastModifiedAt
          ? _value.lastModifiedAt
          : lastModifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenContainerModifiedImpl extends TokenContainerModified
    with DiagnosticableTreeMixin {
  const _$TokenContainerModifiedImpl(
      {this.serverName = 'PrivacyIDEA',
      this.lastSyncAt,
      required this.serial,
      required this.description,
      required final List<TokenTemplate> syncedTokenTemplates,
      required final List<TokenTemplate> localTokenTemplates,
      required this.lastModifiedAt,
      final String? $type})
      : _syncedTokenTemplates = syncedTokenTemplates,
        _localTokenTemplates = localTokenTemplates,
        $type = $type ?? 'modified',
        super._();

  factory _$TokenContainerModifiedImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenContainerModifiedImplFromJson(json);

// Base fields
  @override
  @JsonKey()
  final String serverName;
  @override
  final DateTime? lastSyncAt;
  @override
  final String serial;
  @override
  final String description;
  final List<TokenTemplate> _syncedTokenTemplates;
  @override
  List<TokenTemplate> get syncedTokenTemplates {
    if (_syncedTokenTemplates is EqualUnmodifiableListView)
      return _syncedTokenTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_syncedTokenTemplates);
  }

  final List<TokenTemplate> _localTokenTemplates;
  @override
  List<TokenTemplate> get localTokenTemplates {
    if (_localTokenTemplates is EqualUnmodifiableListView)
      return _localTokenTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_localTokenTemplates);
  }

// Base fields end
  @override
  final DateTime lastModifiedAt;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TokenContainer.modified(serverName: $serverName, lastSyncAt: $lastSyncAt, serial: $serial, description: $description, syncedTokenTemplates: $syncedTokenTemplates, localTokenTemplates: $localTokenTemplates, lastModifiedAt: $lastModifiedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TokenContainer.modified'))
      ..add(DiagnosticsProperty('serverName', serverName))
      ..add(DiagnosticsProperty('lastSyncAt', lastSyncAt))
      ..add(DiagnosticsProperty('serial', serial))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('syncedTokenTemplates', syncedTokenTemplates))
      ..add(DiagnosticsProperty('localTokenTemplates', localTokenTemplates))
      ..add(DiagnosticsProperty('lastModifiedAt', lastModifiedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenContainerModifiedImpl &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._syncedTokenTemplates, _syncedTokenTemplates) &&
            const DeepCollectionEquality()
                .equals(other._localTokenTemplates, _localTokenTemplates) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                other.lastModifiedAt == lastModifiedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      serverName,
      lastSyncAt,
      serial,
      description,
      const DeepCollectionEquality().hash(_syncedTokenTemplates),
      const DeepCollectionEquality().hash(_localTokenTemplates),
      lastModifiedAt);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenContainerModifiedImplCopyWith<_$TokenContainerModifiedImpl>
      get copyWith => __$$TokenContainerModifiedImplCopyWithImpl<
          _$TokenContainerModifiedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        uninitialized,
    required TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        synced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)
        modified,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)
        unsynced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)
        notFound,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)
        error,
  }) {
    return modified(serverName, lastSyncAt, serial, description,
        syncedTokenTemplates, localTokenTemplates, lastModifiedAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult? Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
  }) {
    return modified?.call(serverName, lastSyncAt, serial, description,
        syncedTokenTemplates, localTokenTemplates, lastModifiedAt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
    required TResult orElse(),
  }) {
    if (modified != null) {
      return modified(serverName, lastSyncAt, serial, description,
          syncedTokenTemplates, localTokenTemplates, lastModifiedAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TokenContainerUninitialized value) uninitialized,
    required TResult Function(TokenContainerSynced value) synced,
    required TResult Function(TokenContainerModified value) modified,
    required TResult Function(TokenContainerUnsynced value) unsynced,
    required TResult Function(TokenContainerNotFound value) notFound,
    required TResult Function(TokenContainerError value) error,
  }) {
    return modified(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TokenContainerUninitialized value)? uninitialized,
    TResult? Function(TokenContainerSynced value)? synced,
    TResult? Function(TokenContainerModified value)? modified,
    TResult? Function(TokenContainerUnsynced value)? unsynced,
    TResult? Function(TokenContainerNotFound value)? notFound,
    TResult? Function(TokenContainerError value)? error,
  }) {
    return modified?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TokenContainerUninitialized value)? uninitialized,
    TResult Function(TokenContainerSynced value)? synced,
    TResult Function(TokenContainerModified value)? modified,
    TResult Function(TokenContainerUnsynced value)? unsynced,
    TResult Function(TokenContainerNotFound value)? notFound,
    TResult Function(TokenContainerError value)? error,
    required TResult orElse(),
  }) {
    if (modified != null) {
      return modified(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenContainerModifiedImplToJson(
      this,
    );
  }
}

abstract class TokenContainerModified extends TokenContainer {
  const factory TokenContainerModified(
      {final String serverName,
      final DateTime? lastSyncAt,
      required final String serial,
      required final String description,
      required final List<TokenTemplate> syncedTokenTemplates,
      required final List<TokenTemplate> localTokenTemplates,
      required final DateTime lastModifiedAt}) = _$TokenContainerModifiedImpl;
  const TokenContainerModified._() : super._();

  factory TokenContainerModified.fromJson(Map<String, dynamic> json) =
      _$TokenContainerModifiedImpl.fromJson;

// Base fields
  @override
  String get serverName;
  @override
  DateTime? get lastSyncAt;
  @override
  String get serial;
  @override
  String get description;
  @override
  List<TokenTemplate> get syncedTokenTemplates;
  @override
  List<TokenTemplate> get localTokenTemplates; // Base fields end
  DateTime get lastModifiedAt;

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenContainerModifiedImplCopyWith<_$TokenContainerModifiedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TokenContainerUnsyncedImplCopyWith<$Res>
    implements $TokenContainerCopyWith<$Res> {
  factory _$$TokenContainerUnsyncedImplCopyWith(
          _$TokenContainerUnsyncedImpl value,
          $Res Function(_$TokenContainerUnsyncedImpl) then) =
      __$$TokenContainerUnsyncedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String serverName,
      DateTime? lastSyncAt,
      String serial,
      String description,
      List<TokenTemplate> syncedTokenTemplates,
      List<TokenTemplate> localTokenTemplates,
      String? message});
}

/// @nodoc
class __$$TokenContainerUnsyncedImplCopyWithImpl<$Res>
    extends _$TokenContainerCopyWithImpl<$Res, _$TokenContainerUnsyncedImpl>
    implements _$$TokenContainerUnsyncedImplCopyWith<$Res> {
  __$$TokenContainerUnsyncedImplCopyWithImpl(
      _$TokenContainerUnsyncedImpl _value,
      $Res Function(_$TokenContainerUnsyncedImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverName = null,
    Object? lastSyncAt = freezed,
    Object? serial = null,
    Object? description = null,
    Object? syncedTokenTemplates = null,
    Object? localTokenTemplates = null,
    Object? message = freezed,
  }) {
    return _then(_$TokenContainerUnsyncedImpl(
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      lastSyncAt: freezed == lastSyncAt
          ? _value.lastSyncAt
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      syncedTokenTemplates: null == syncedTokenTemplates
          ? _value._syncedTokenTemplates
          : syncedTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
      localTokenTemplates: null == localTokenTemplates
          ? _value._localTokenTemplates
          : localTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenContainerUnsyncedImpl extends TokenContainerUnsynced
    with DiagnosticableTreeMixin {
  const _$TokenContainerUnsyncedImpl(
      {this.serverName = 'PrivacyIDEA',
      this.lastSyncAt,
      required this.serial,
      required this.description,
      required final List<TokenTemplate> syncedTokenTemplates,
      required final List<TokenTemplate> localTokenTemplates,
      this.message,
      final String? $type})
      : _syncedTokenTemplates = syncedTokenTemplates,
        _localTokenTemplates = localTokenTemplates,
        $type = $type ?? 'unsynced',
        super._();

  factory _$TokenContainerUnsyncedImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenContainerUnsyncedImplFromJson(json);

// Base fields
  @override
  @JsonKey()
  final String serverName;
  @override
  final DateTime? lastSyncAt;
  @override
  final String serial;
  @override
  final String description;
  final List<TokenTemplate> _syncedTokenTemplates;
  @override
  List<TokenTemplate> get syncedTokenTemplates {
    if (_syncedTokenTemplates is EqualUnmodifiableListView)
      return _syncedTokenTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_syncedTokenTemplates);
  }

  final List<TokenTemplate> _localTokenTemplates;
  @override
  List<TokenTemplate> get localTokenTemplates {
    if (_localTokenTemplates is EqualUnmodifiableListView)
      return _localTokenTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_localTokenTemplates);
  }

// Base fields end
  @override
  final String? message;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TokenContainer.unsynced(serverName: $serverName, lastSyncAt: $lastSyncAt, serial: $serial, description: $description, syncedTokenTemplates: $syncedTokenTemplates, localTokenTemplates: $localTokenTemplates, message: $message)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TokenContainer.unsynced'))
      ..add(DiagnosticsProperty('serverName', serverName))
      ..add(DiagnosticsProperty('lastSyncAt', lastSyncAt))
      ..add(DiagnosticsProperty('serial', serial))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('syncedTokenTemplates', syncedTokenTemplates))
      ..add(DiagnosticsProperty('localTokenTemplates', localTokenTemplates))
      ..add(DiagnosticsProperty('message', message));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenContainerUnsyncedImpl &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._syncedTokenTemplates, _syncedTokenTemplates) &&
            const DeepCollectionEquality()
                .equals(other._localTokenTemplates, _localTokenTemplates) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      serverName,
      lastSyncAt,
      serial,
      description,
      const DeepCollectionEquality().hash(_syncedTokenTemplates),
      const DeepCollectionEquality().hash(_localTokenTemplates),
      message);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenContainerUnsyncedImplCopyWith<_$TokenContainerUnsyncedImpl>
      get copyWith => __$$TokenContainerUnsyncedImplCopyWithImpl<
          _$TokenContainerUnsyncedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        uninitialized,
    required TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        synced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)
        modified,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)
        unsynced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)
        notFound,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)
        error,
  }) {
    return unsynced(serverName, lastSyncAt, serial, description,
        syncedTokenTemplates, localTokenTemplates, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult? Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
  }) {
    return unsynced?.call(serverName, lastSyncAt, serial, description,
        syncedTokenTemplates, localTokenTemplates, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
    required TResult orElse(),
  }) {
    if (unsynced != null) {
      return unsynced(serverName, lastSyncAt, serial, description,
          syncedTokenTemplates, localTokenTemplates, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TokenContainerUninitialized value) uninitialized,
    required TResult Function(TokenContainerSynced value) synced,
    required TResult Function(TokenContainerModified value) modified,
    required TResult Function(TokenContainerUnsynced value) unsynced,
    required TResult Function(TokenContainerNotFound value) notFound,
    required TResult Function(TokenContainerError value) error,
  }) {
    return unsynced(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TokenContainerUninitialized value)? uninitialized,
    TResult? Function(TokenContainerSynced value)? synced,
    TResult? Function(TokenContainerModified value)? modified,
    TResult? Function(TokenContainerUnsynced value)? unsynced,
    TResult? Function(TokenContainerNotFound value)? notFound,
    TResult? Function(TokenContainerError value)? error,
  }) {
    return unsynced?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TokenContainerUninitialized value)? uninitialized,
    TResult Function(TokenContainerSynced value)? synced,
    TResult Function(TokenContainerModified value)? modified,
    TResult Function(TokenContainerUnsynced value)? unsynced,
    TResult Function(TokenContainerNotFound value)? notFound,
    TResult Function(TokenContainerError value)? error,
    required TResult orElse(),
  }) {
    if (unsynced != null) {
      return unsynced(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenContainerUnsyncedImplToJson(
      this,
    );
  }
}

abstract class TokenContainerUnsynced extends TokenContainer {
  const factory TokenContainerUnsynced(
      {final String serverName,
      final DateTime? lastSyncAt,
      required final String serial,
      required final String description,
      required final List<TokenTemplate> syncedTokenTemplates,
      required final List<TokenTemplate> localTokenTemplates,
      final String? message}) = _$TokenContainerUnsyncedImpl;
  const TokenContainerUnsynced._() : super._();

  factory TokenContainerUnsynced.fromJson(Map<String, dynamic> json) =
      _$TokenContainerUnsyncedImpl.fromJson;

// Base fields
  @override
  String get serverName;
  @override
  DateTime? get lastSyncAt;
  @override
  String get serial;
  @override
  String get description;
  @override
  List<TokenTemplate> get syncedTokenTemplates;
  @override
  List<TokenTemplate> get localTokenTemplates; // Base fields end
  String? get message;

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenContainerUnsyncedImplCopyWith<_$TokenContainerUnsyncedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TokenContainerNotFoundImplCopyWith<$Res>
    implements $TokenContainerCopyWith<$Res> {
  factory _$$TokenContainerNotFoundImplCopyWith(
          _$TokenContainerNotFoundImpl value,
          $Res Function(_$TokenContainerNotFoundImpl) then) =
      __$$TokenContainerNotFoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String serverName,
      DateTime? lastSyncAt,
      String serial,
      String description,
      List<TokenTemplate> syncedTokenTemplates,
      List<TokenTemplate> localTokenTemplates,
      String message});
}

/// @nodoc
class __$$TokenContainerNotFoundImplCopyWithImpl<$Res>
    extends _$TokenContainerCopyWithImpl<$Res, _$TokenContainerNotFoundImpl>
    implements _$$TokenContainerNotFoundImplCopyWith<$Res> {
  __$$TokenContainerNotFoundImplCopyWithImpl(
      _$TokenContainerNotFoundImpl _value,
      $Res Function(_$TokenContainerNotFoundImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverName = null,
    Object? lastSyncAt = freezed,
    Object? serial = null,
    Object? description = null,
    Object? syncedTokenTemplates = null,
    Object? localTokenTemplates = null,
    Object? message = null,
  }) {
    return _then(_$TokenContainerNotFoundImpl(
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      lastSyncAt: freezed == lastSyncAt
          ? _value.lastSyncAt
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      syncedTokenTemplates: null == syncedTokenTemplates
          ? _value._syncedTokenTemplates
          : syncedTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
      localTokenTemplates: null == localTokenTemplates
          ? _value._localTokenTemplates
          : localTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenContainerNotFoundImpl extends TokenContainerNotFound
    with DiagnosticableTreeMixin {
  const _$TokenContainerNotFoundImpl(
      {this.serverName = 'PrivacyIDEA',
      this.lastSyncAt,
      required this.serial,
      required this.description,
      required final List<TokenTemplate> syncedTokenTemplates,
      required final List<TokenTemplate> localTokenTemplates,
      required this.message,
      final String? $type})
      : _syncedTokenTemplates = syncedTokenTemplates,
        _localTokenTemplates = localTokenTemplates,
        $type = $type ?? 'notFound',
        super._();

  factory _$TokenContainerNotFoundImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenContainerNotFoundImplFromJson(json);

// Base fields
  @override
  @JsonKey()
  final String serverName;
  @override
  final DateTime? lastSyncAt;
  @override
  final String serial;
  @override
  final String description;
  final List<TokenTemplate> _syncedTokenTemplates;
  @override
  List<TokenTemplate> get syncedTokenTemplates {
    if (_syncedTokenTemplates is EqualUnmodifiableListView)
      return _syncedTokenTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_syncedTokenTemplates);
  }

  final List<TokenTemplate> _localTokenTemplates;
  @override
  List<TokenTemplate> get localTokenTemplates {
    if (_localTokenTemplates is EqualUnmodifiableListView)
      return _localTokenTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_localTokenTemplates);
  }

// Base fields end
  @override
  final String message;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TokenContainer.notFound(serverName: $serverName, lastSyncAt: $lastSyncAt, serial: $serial, description: $description, syncedTokenTemplates: $syncedTokenTemplates, localTokenTemplates: $localTokenTemplates, message: $message)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TokenContainer.notFound'))
      ..add(DiagnosticsProperty('serverName', serverName))
      ..add(DiagnosticsProperty('lastSyncAt', lastSyncAt))
      ..add(DiagnosticsProperty('serial', serial))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('syncedTokenTemplates', syncedTokenTemplates))
      ..add(DiagnosticsProperty('localTokenTemplates', localTokenTemplates))
      ..add(DiagnosticsProperty('message', message));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenContainerNotFoundImpl &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._syncedTokenTemplates, _syncedTokenTemplates) &&
            const DeepCollectionEquality()
                .equals(other._localTokenTemplates, _localTokenTemplates) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      serverName,
      lastSyncAt,
      serial,
      description,
      const DeepCollectionEquality().hash(_syncedTokenTemplates),
      const DeepCollectionEquality().hash(_localTokenTemplates),
      message);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenContainerNotFoundImplCopyWith<_$TokenContainerNotFoundImpl>
      get copyWith => __$$TokenContainerNotFoundImplCopyWithImpl<
          _$TokenContainerNotFoundImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        uninitialized,
    required TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        synced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)
        modified,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)
        unsynced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)
        notFound,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)
        error,
  }) {
    return notFound(serverName, lastSyncAt, serial, description,
        syncedTokenTemplates, localTokenTemplates, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult? Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
  }) {
    return notFound?.call(serverName, lastSyncAt, serial, description,
        syncedTokenTemplates, localTokenTemplates, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(serverName, lastSyncAt, serial, description,
          syncedTokenTemplates, localTokenTemplates, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TokenContainerUninitialized value) uninitialized,
    required TResult Function(TokenContainerSynced value) synced,
    required TResult Function(TokenContainerModified value) modified,
    required TResult Function(TokenContainerUnsynced value) unsynced,
    required TResult Function(TokenContainerNotFound value) notFound,
    required TResult Function(TokenContainerError value) error,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TokenContainerUninitialized value)? uninitialized,
    TResult? Function(TokenContainerSynced value)? synced,
    TResult? Function(TokenContainerModified value)? modified,
    TResult? Function(TokenContainerUnsynced value)? unsynced,
    TResult? Function(TokenContainerNotFound value)? notFound,
    TResult? Function(TokenContainerError value)? error,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TokenContainerUninitialized value)? uninitialized,
    TResult Function(TokenContainerSynced value)? synced,
    TResult Function(TokenContainerModified value)? modified,
    TResult Function(TokenContainerUnsynced value)? unsynced,
    TResult Function(TokenContainerNotFound value)? notFound,
    TResult Function(TokenContainerError value)? error,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenContainerNotFoundImplToJson(
      this,
    );
  }
}

abstract class TokenContainerNotFound extends TokenContainer {
  const factory TokenContainerNotFound(
      {final String serverName,
      final DateTime? lastSyncAt,
      required final String serial,
      required final String description,
      required final List<TokenTemplate> syncedTokenTemplates,
      required final List<TokenTemplate> localTokenTemplates,
      required final String message}) = _$TokenContainerNotFoundImpl;
  const TokenContainerNotFound._() : super._();

  factory TokenContainerNotFound.fromJson(Map<String, dynamic> json) =
      _$TokenContainerNotFoundImpl.fromJson;

// Base fields
  @override
  String get serverName;
  @override
  DateTime? get lastSyncAt;
  @override
  String get serial;
  @override
  String get description;
  @override
  List<TokenTemplate> get syncedTokenTemplates;
  @override
  List<TokenTemplate> get localTokenTemplates; // Base fields end
  String get message;

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenContainerNotFoundImplCopyWith<_$TokenContainerNotFoundImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TokenContainerErrorImplCopyWith<$Res>
    implements $TokenContainerCopyWith<$Res> {
  factory _$$TokenContainerErrorImplCopyWith(_$TokenContainerErrorImpl value,
          $Res Function(_$TokenContainerErrorImpl) then) =
      __$$TokenContainerErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String serverName,
      DateTime? lastSyncAt,
      String serial,
      String description,
      List<TokenTemplate> syncedTokenTemplates,
      List<TokenTemplate> localTokenTemplates,
      dynamic error});
}

/// @nodoc
class __$$TokenContainerErrorImplCopyWithImpl<$Res>
    extends _$TokenContainerCopyWithImpl<$Res, _$TokenContainerErrorImpl>
    implements _$$TokenContainerErrorImplCopyWith<$Res> {
  __$$TokenContainerErrorImplCopyWithImpl(_$TokenContainerErrorImpl _value,
      $Res Function(_$TokenContainerErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverName = null,
    Object? lastSyncAt = freezed,
    Object? serial = null,
    Object? description = null,
    Object? syncedTokenTemplates = null,
    Object? localTokenTemplates = null,
    Object? error = freezed,
  }) {
    return _then(_$TokenContainerErrorImpl(
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      lastSyncAt: freezed == lastSyncAt
          ? _value.lastSyncAt
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      syncedTokenTemplates: null == syncedTokenTemplates
          ? _value._syncedTokenTemplates
          : syncedTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
      localTokenTemplates: null == localTokenTemplates
          ? _value._localTokenTemplates
          : localTokenTemplates // ignore: cast_nullable_to_non_nullable
              as List<TokenTemplate>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenContainerErrorImpl extends TokenContainerError
    with DiagnosticableTreeMixin {
  const _$TokenContainerErrorImpl(
      {this.serverName = 'PrivacyIDEA',
      this.lastSyncAt,
      this.serial = 'none',
      this.description = 'Error',
      final List<TokenTemplate> syncedTokenTemplates = const [],
      final List<TokenTemplate> localTokenTemplates = const [],
      required this.error,
      final String? $type})
      : _syncedTokenTemplates = syncedTokenTemplates,
        _localTokenTemplates = localTokenTemplates,
        $type = $type ?? 'error',
        super._();

  factory _$TokenContainerErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenContainerErrorImplFromJson(json);

// Base fields
  @override
  @JsonKey()
  final String serverName;
  @override
  final DateTime? lastSyncAt;
  @override
  @JsonKey()
  final String serial;
  @override
  @JsonKey()
  final String description;
  final List<TokenTemplate> _syncedTokenTemplates;
  @override
  @JsonKey()
  List<TokenTemplate> get syncedTokenTemplates {
    if (_syncedTokenTemplates is EqualUnmodifiableListView)
      return _syncedTokenTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_syncedTokenTemplates);
  }

  final List<TokenTemplate> _localTokenTemplates;
  @override
  @JsonKey()
  List<TokenTemplate> get localTokenTemplates {
    if (_localTokenTemplates is EqualUnmodifiableListView)
      return _localTokenTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_localTokenTemplates);
  }

// Base fields end
  @override
  final dynamic error;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TokenContainer.error(serverName: $serverName, lastSyncAt: $lastSyncAt, serial: $serial, description: $description, syncedTokenTemplates: $syncedTokenTemplates, localTokenTemplates: $localTokenTemplates, error: $error)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TokenContainer.error'))
      ..add(DiagnosticsProperty('serverName', serverName))
      ..add(DiagnosticsProperty('lastSyncAt', lastSyncAt))
      ..add(DiagnosticsProperty('serial', serial))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('syncedTokenTemplates', syncedTokenTemplates))
      ..add(DiagnosticsProperty('localTokenTemplates', localTokenTemplates))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenContainerErrorImpl &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._syncedTokenTemplates, _syncedTokenTemplates) &&
            const DeepCollectionEquality()
                .equals(other._localTokenTemplates, _localTokenTemplates) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      serverName,
      lastSyncAt,
      serial,
      description,
      const DeepCollectionEquality().hash(_syncedTokenTemplates),
      const DeepCollectionEquality().hash(_localTokenTemplates),
      const DeepCollectionEquality().hash(error));

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenContainerErrorImplCopyWith<_$TokenContainerErrorImpl> get copyWith =>
      __$$TokenContainerErrorImplCopyWithImpl<_$TokenContainerErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        uninitialized,
    required TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)
        synced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)
        modified,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)
        unsynced,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)
        notFound,
    required TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)
        error,
  }) {
    return error(serverName, lastSyncAt, serial, description,
        syncedTokenTemplates, localTokenTemplates, this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult? Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult? Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
  }) {
    return error?.call(serverName, lastSyncAt, serial, description,
        syncedTokenTemplates, localTokenTemplates, this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        uninitialized,
    TResult Function(
            String serverName,
            DateTime lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates)?
        synced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            DateTime lastModifiedAt)?
        modified,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String? message)?
        unsynced,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            String message)?
        notFound,
    TResult Function(
            String serverName,
            DateTime? lastSyncAt,
            String serial,
            String description,
            List<TokenTemplate> syncedTokenTemplates,
            List<TokenTemplate> localTokenTemplates,
            dynamic error)?
        error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(serverName, lastSyncAt, serial, description,
          syncedTokenTemplates, localTokenTemplates, this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TokenContainerUninitialized value) uninitialized,
    required TResult Function(TokenContainerSynced value) synced,
    required TResult Function(TokenContainerModified value) modified,
    required TResult Function(TokenContainerUnsynced value) unsynced,
    required TResult Function(TokenContainerNotFound value) notFound,
    required TResult Function(TokenContainerError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TokenContainerUninitialized value)? uninitialized,
    TResult? Function(TokenContainerSynced value)? synced,
    TResult? Function(TokenContainerModified value)? modified,
    TResult? Function(TokenContainerUnsynced value)? unsynced,
    TResult? Function(TokenContainerNotFound value)? notFound,
    TResult? Function(TokenContainerError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TokenContainerUninitialized value)? uninitialized,
    TResult Function(TokenContainerSynced value)? synced,
    TResult Function(TokenContainerModified value)? modified,
    TResult Function(TokenContainerUnsynced value)? unsynced,
    TResult Function(TokenContainerNotFound value)? notFound,
    TResult Function(TokenContainerError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenContainerErrorImplToJson(
      this,
    );
  }
}

abstract class TokenContainerError extends TokenContainer {
  const factory TokenContainerError(
      {final String serverName,
      final DateTime? lastSyncAt,
      final String serial,
      final String description,
      final List<TokenTemplate> syncedTokenTemplates,
      final List<TokenTemplate> localTokenTemplates,
      required final dynamic error}) = _$TokenContainerErrorImpl;
  const TokenContainerError._() : super._();

  factory TokenContainerError.fromJson(Map<String, dynamic> json) =
      _$TokenContainerErrorImpl.fromJson;

// Base fields
  @override
  String get serverName;
  @override
  DateTime? get lastSyncAt;
  @override
  String get serial;
  @override
  String get description;
  @override
  List<TokenTemplate> get syncedTokenTemplates;
  @override
  List<TokenTemplate> get localTokenTemplates; // Base fields end
  dynamic get error;

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenContainerErrorImplCopyWith<_$TokenContainerErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TokenTemplate _$TokenTemplateFromJson(Map<String, dynamic> json) {
  return _TokenTemplate.fromJson(json);
}

/// @nodoc
mixin _$TokenTemplate {
  Map<String, dynamic> get data => throw _privateConstructorUsedError;

  /// Serializes this TokenTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenTemplateCopyWith<TokenTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenTemplateCopyWith<$Res> {
  factory $TokenTemplateCopyWith(
          TokenTemplate value, $Res Function(TokenTemplate) then) =
      _$TokenTemplateCopyWithImpl<$Res, TokenTemplate>;
  @useResult
  $Res call({Map<String, dynamic> data});
}

/// @nodoc
class _$TokenTemplateCopyWithImpl<$Res, $Val extends TokenTemplate>
    implements $TokenTemplateCopyWith<$Res> {
  _$TokenTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenTemplateImplCopyWith<$Res>
    implements $TokenTemplateCopyWith<$Res> {
  factory _$$TokenTemplateImplCopyWith(
          _$TokenTemplateImpl value, $Res Function(_$TokenTemplateImpl) then) =
      __$$TokenTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, dynamic> data});
}

/// @nodoc
class __$$TokenTemplateImplCopyWithImpl<$Res>
    extends _$TokenTemplateCopyWithImpl<$Res, _$TokenTemplateImpl>
    implements _$$TokenTemplateImplCopyWith<$Res> {
  __$$TokenTemplateImplCopyWithImpl(
      _$TokenTemplateImpl _value, $Res Function(_$TokenTemplateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$TokenTemplateImpl(
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenTemplateImpl extends _TokenTemplate with DiagnosticableTreeMixin {
  _$TokenTemplateImpl({required final Map<String, dynamic> data})
      : _data = data,
        super._();

  factory _$TokenTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenTemplateImplFromJson(json);

  final Map<String, dynamic> _data;
  @override
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TokenTemplate(data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TokenTemplate'))
      ..add(DiagnosticsProperty('data', data));
  }

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenTemplateImplCopyWith<_$TokenTemplateImpl> get copyWith =>
      __$$TokenTemplateImplCopyWithImpl<_$TokenTemplateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenTemplateImplToJson(
      this,
    );
  }
}

abstract class _TokenTemplate extends TokenTemplate {
  factory _TokenTemplate({required final Map<String, dynamic> data}) =
      _$TokenTemplateImpl;
  _TokenTemplate._() : super._();

  factory _TokenTemplate.fromJson(Map<String, dynamic> json) =
      _$TokenTemplateImpl.fromJson;

  @override
  Map<String, dynamic> get data;

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenTemplateImplCopyWith<_$TokenTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
