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
    case 'unfinalized':
      return TokenContainerUnfinalized.fromJson(json);
    case 'finalized':
      return TokenContainerFinalized.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'TokenContainer',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$TokenContainer {
  String get issuer => throw _privateConstructorUsedError;
  String get nonce => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  Uri? get syncUrl => throw _privateConstructorUsedError;
  String get serial => throw _privateConstructorUsedError;
  EcKeyAlgorithm get ecKeyAlgorithm => throw _privateConstructorUsedError;
  Algorithms get hashAlgorithm => throw _privateConstructorUsedError;
  String get serverName => throw _privateConstructorUsedError;
  RolloutState get finalizationState => throw _privateConstructorUsedError;
  String? get passphraseQuestion => throw _privateConstructorUsedError;
  String? get publicServerKey => throw _privateConstructorUsedError;
  String? get publicClientKey => throw _privateConstructorUsedError;
  String? get privateClientKey => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri finalizationUrl,
            Uri? syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)
        unfinalized,
    required TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            @SyncStateJsonConverter() SyncState syncState,
            String? passphraseQuestion,
            String publicServerKey,
            String publicClientKey,
            String privateClientKey)
        finalized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri finalizationUrl,
            Uri? syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)?
        unfinalized,
    TResult? Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            @SyncStateJsonConverter() SyncState syncState,
            String? passphraseQuestion,
            String publicServerKey,
            String publicClientKey,
            String privateClientKey)?
        finalized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri finalizationUrl,
            Uri? syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)?
        unfinalized,
    TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            @SyncStateJsonConverter() SyncState syncState,
            String? passphraseQuestion,
            String publicServerKey,
            String publicClientKey,
            String privateClientKey)?
        finalized,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TokenContainerUnfinalized value) unfinalized,
    required TResult Function(TokenContainerFinalized value) finalized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TokenContainerUnfinalized value)? unfinalized,
    TResult? Function(TokenContainerFinalized value)? finalized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TokenContainerUnfinalized value)? unfinalized,
    TResult Function(TokenContainerFinalized value)? finalized,
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
      {String issuer,
      String nonce,
      DateTime timestamp,
      Uri syncUrl,
      String serial,
      EcKeyAlgorithm ecKeyAlgorithm,
      Algorithms hashAlgorithm,
      String serverName,
      RolloutState finalizationState,
      String? passphraseQuestion,
      String publicServerKey,
      String publicClientKey,
      String privateClientKey});
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
    Object? issuer = null,
    Object? nonce = null,
    Object? timestamp = null,
    Object? syncUrl = null,
    Object? serial = null,
    Object? ecKeyAlgorithm = null,
    Object? hashAlgorithm = null,
    Object? serverName = null,
    Object? finalizationState = null,
    Object? passphraseQuestion = freezed,
    Object? publicServerKey = null,
    Object? publicClientKey = null,
    Object? privateClientKey = null,
  }) {
    return _then(_value.copyWith(
      issuer: null == issuer
          ? _value.issuer
          : issuer // ignore: cast_nullable_to_non_nullable
              as String,
      nonce: null == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncUrl: null == syncUrl
          ? _value.syncUrl!
          : syncUrl // ignore: cast_nullable_to_non_nullable
              as Uri,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      ecKeyAlgorithm: null == ecKeyAlgorithm
          ? _value.ecKeyAlgorithm
          : ecKeyAlgorithm // ignore: cast_nullable_to_non_nullable
              as EcKeyAlgorithm,
      hashAlgorithm: null == hashAlgorithm
          ? _value.hashAlgorithm
          : hashAlgorithm // ignore: cast_nullable_to_non_nullable
              as Algorithms,
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      finalizationState: null == finalizationState
          ? _value.finalizationState
          : finalizationState // ignore: cast_nullable_to_non_nullable
              as RolloutState,
      passphraseQuestion: freezed == passphraseQuestion
          ? _value.passphraseQuestion
          : passphraseQuestion // ignore: cast_nullable_to_non_nullable
              as String?,
      publicServerKey: null == publicServerKey
          ? _value.publicServerKey!
          : publicServerKey // ignore: cast_nullable_to_non_nullable
              as String,
      publicClientKey: null == publicClientKey
          ? _value.publicClientKey!
          : publicClientKey // ignore: cast_nullable_to_non_nullable
              as String,
      privateClientKey: null == privateClientKey
          ? _value.privateClientKey!
          : privateClientKey // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenContainerUnfinalizedImplCopyWith<$Res>
    implements $TokenContainerCopyWith<$Res> {
  factory _$$TokenContainerUnfinalizedImplCopyWith(
          _$TokenContainerUnfinalizedImpl value,
          $Res Function(_$TokenContainerUnfinalizedImpl) then) =
      __$$TokenContainerUnfinalizedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String issuer,
      String nonce,
      DateTime timestamp,
      Uri finalizationUrl,
      Uri? syncUrl,
      String serial,
      EcKeyAlgorithm ecKeyAlgorithm,
      Algorithms hashAlgorithm,
      String serverName,
      RolloutState finalizationState,
      String? passphraseQuestion,
      String? publicServerKey,
      String? publicClientKey,
      String? privateClientKey});
}

/// @nodoc
class __$$TokenContainerUnfinalizedImplCopyWithImpl<$Res>
    extends _$TokenContainerCopyWithImpl<$Res, _$TokenContainerUnfinalizedImpl>
    implements _$$TokenContainerUnfinalizedImplCopyWith<$Res> {
  __$$TokenContainerUnfinalizedImplCopyWithImpl(
      _$TokenContainerUnfinalizedImpl _value,
      $Res Function(_$TokenContainerUnfinalizedImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? issuer = null,
    Object? nonce = null,
    Object? timestamp = null,
    Object? finalizationUrl = null,
    Object? syncUrl = freezed,
    Object? serial = null,
    Object? ecKeyAlgorithm = null,
    Object? hashAlgorithm = null,
    Object? serverName = null,
    Object? finalizationState = null,
    Object? passphraseQuestion = freezed,
    Object? publicServerKey = freezed,
    Object? publicClientKey = freezed,
    Object? privateClientKey = freezed,
  }) {
    return _then(_$TokenContainerUnfinalizedImpl(
      issuer: null == issuer
          ? _value.issuer
          : issuer // ignore: cast_nullable_to_non_nullable
              as String,
      nonce: null == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      finalizationUrl: null == finalizationUrl
          ? _value.finalizationUrl
          : finalizationUrl // ignore: cast_nullable_to_non_nullable
              as Uri,
      syncUrl: freezed == syncUrl
          ? _value.syncUrl
          : syncUrl // ignore: cast_nullable_to_non_nullable
              as Uri?,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      ecKeyAlgorithm: null == ecKeyAlgorithm
          ? _value.ecKeyAlgorithm
          : ecKeyAlgorithm // ignore: cast_nullable_to_non_nullable
              as EcKeyAlgorithm,
      hashAlgorithm: null == hashAlgorithm
          ? _value.hashAlgorithm
          : hashAlgorithm // ignore: cast_nullable_to_non_nullable
              as Algorithms,
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      finalizationState: null == finalizationState
          ? _value.finalizationState
          : finalizationState // ignore: cast_nullable_to_non_nullable
              as RolloutState,
      passphraseQuestion: freezed == passphraseQuestion
          ? _value.passphraseQuestion
          : passphraseQuestion // ignore: cast_nullable_to_non_nullable
              as String?,
      publicServerKey: freezed == publicServerKey
          ? _value.publicServerKey
          : publicServerKey // ignore: cast_nullable_to_non_nullable
              as String?,
      publicClientKey: freezed == publicClientKey
          ? _value.publicClientKey
          : publicClientKey // ignore: cast_nullable_to_non_nullable
              as String?,
      privateClientKey: freezed == privateClientKey
          ? _value.privateClientKey
          : privateClientKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenContainerUnfinalizedImpl extends TokenContainerUnfinalized {
  const _$TokenContainerUnfinalizedImpl(
      {required this.issuer,
      required this.nonce,
      required this.timestamp,
      required this.finalizationUrl,
      this.syncUrl,
      required this.serial,
      required this.ecKeyAlgorithm,
      required this.hashAlgorithm,
      this.serverName = 'privacyIDEA',
      this.finalizationState = RolloutState.completed,
      this.passphraseQuestion,
      this.publicServerKey,
      this.publicClientKey,
      this.privateClientKey,
      final String? $type})
      : $type = $type ?? 'unfinalized',
        super._();

  factory _$TokenContainerUnfinalizedImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenContainerUnfinalizedImplFromJson(json);

  @override
  final String issuer;
  @override
  final String nonce;
  @override
  final DateTime timestamp;
  @override
  final Uri finalizationUrl;
  @override
  final Uri? syncUrl;
  @override
  final String serial;
  @override
  final EcKeyAlgorithm ecKeyAlgorithm;
  @override
  final Algorithms hashAlgorithm;
  @override
  @JsonKey()
  final String serverName;
  @override
  @JsonKey()
  final RolloutState finalizationState;
  @override
  final String? passphraseQuestion;
  @override
  final String? publicServerKey;
  @override
  final String? publicClientKey;
  @override
  final String? privateClientKey;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenContainerUnfinalizedImpl &&
            (identical(other.issuer, issuer) || other.issuer == issuer) &&
            (identical(other.nonce, nonce) || other.nonce == nonce) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.finalizationUrl, finalizationUrl) ||
                other.finalizationUrl == finalizationUrl) &&
            (identical(other.syncUrl, syncUrl) || other.syncUrl == syncUrl) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.ecKeyAlgorithm, ecKeyAlgorithm) ||
                other.ecKeyAlgorithm == ecKeyAlgorithm) &&
            (identical(other.hashAlgorithm, hashAlgorithm) ||
                other.hashAlgorithm == hashAlgorithm) &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName) &&
            (identical(other.finalizationState, finalizationState) ||
                other.finalizationState == finalizationState) &&
            (identical(other.passphraseQuestion, passphraseQuestion) ||
                other.passphraseQuestion == passphraseQuestion) &&
            (identical(other.publicServerKey, publicServerKey) ||
                other.publicServerKey == publicServerKey) &&
            (identical(other.publicClientKey, publicClientKey) ||
                other.publicClientKey == publicClientKey) &&
            (identical(other.privateClientKey, privateClientKey) ||
                other.privateClientKey == privateClientKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      issuer,
      nonce,
      timestamp,
      finalizationUrl,
      syncUrl,
      serial,
      ecKeyAlgorithm,
      hashAlgorithm,
      serverName,
      finalizationState,
      passphraseQuestion,
      publicServerKey,
      publicClientKey,
      privateClientKey);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenContainerUnfinalizedImplCopyWith<_$TokenContainerUnfinalizedImpl>
      get copyWith => __$$TokenContainerUnfinalizedImplCopyWithImpl<
          _$TokenContainerUnfinalizedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri finalizationUrl,
            Uri? syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)
        unfinalized,
    required TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            @SyncStateJsonConverter() SyncState syncState,
            String? passphraseQuestion,
            String publicServerKey,
            String publicClientKey,
            String privateClientKey)
        finalized,
  }) {
    return unfinalized(
        issuer,
        nonce,
        timestamp,
        finalizationUrl,
        syncUrl,
        serial,
        ecKeyAlgorithm,
        hashAlgorithm,
        serverName,
        finalizationState,
        passphraseQuestion,
        publicServerKey,
        publicClientKey,
        privateClientKey);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri finalizationUrl,
            Uri? syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)?
        unfinalized,
    TResult? Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            @SyncStateJsonConverter() SyncState syncState,
            String? passphraseQuestion,
            String publicServerKey,
            String publicClientKey,
            String privateClientKey)?
        finalized,
  }) {
    return unfinalized?.call(
        issuer,
        nonce,
        timestamp,
        finalizationUrl,
        syncUrl,
        serial,
        ecKeyAlgorithm,
        hashAlgorithm,
        serverName,
        finalizationState,
        passphraseQuestion,
        publicServerKey,
        publicClientKey,
        privateClientKey);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri finalizationUrl,
            Uri? syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)?
        unfinalized,
    TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            @SyncStateJsonConverter() SyncState syncState,
            String? passphraseQuestion,
            String publicServerKey,
            String publicClientKey,
            String privateClientKey)?
        finalized,
    required TResult orElse(),
  }) {
    if (unfinalized != null) {
      return unfinalized(
          issuer,
          nonce,
          timestamp,
          finalizationUrl,
          syncUrl,
          serial,
          ecKeyAlgorithm,
          hashAlgorithm,
          serverName,
          finalizationState,
          passphraseQuestion,
          publicServerKey,
          publicClientKey,
          privateClientKey);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TokenContainerUnfinalized value) unfinalized,
    required TResult Function(TokenContainerFinalized value) finalized,
  }) {
    return unfinalized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TokenContainerUnfinalized value)? unfinalized,
    TResult? Function(TokenContainerFinalized value)? finalized,
  }) {
    return unfinalized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TokenContainerUnfinalized value)? unfinalized,
    TResult Function(TokenContainerFinalized value)? finalized,
    required TResult orElse(),
  }) {
    if (unfinalized != null) {
      return unfinalized(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenContainerUnfinalizedImplToJson(
      this,
    );
  }
}

abstract class TokenContainerUnfinalized extends TokenContainer {
  const factory TokenContainerUnfinalized(
      {required final String issuer,
      required final String nonce,
      required final DateTime timestamp,
      required final Uri finalizationUrl,
      final Uri? syncUrl,
      required final String serial,
      required final EcKeyAlgorithm ecKeyAlgorithm,
      required final Algorithms hashAlgorithm,
      final String serverName,
      final RolloutState finalizationState,
      final String? passphraseQuestion,
      final String? publicServerKey,
      final String? publicClientKey,
      final String? privateClientKey}) = _$TokenContainerUnfinalizedImpl;
  const TokenContainerUnfinalized._() : super._();

  factory TokenContainerUnfinalized.fromJson(Map<String, dynamic> json) =
      _$TokenContainerUnfinalizedImpl.fromJson;

  @override
  String get issuer;
  @override
  String get nonce;
  @override
  DateTime get timestamp;
  Uri get finalizationUrl;
  @override
  Uri? get syncUrl;
  @override
  String get serial;
  @override
  EcKeyAlgorithm get ecKeyAlgorithm;
  @override
  Algorithms get hashAlgorithm;
  @override
  String get serverName;
  @override
  RolloutState get finalizationState;
  @override
  String? get passphraseQuestion;
  @override
  String? get publicServerKey;
  @override
  String? get publicClientKey;
  @override
  String? get privateClientKey;

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenContainerUnfinalizedImplCopyWith<_$TokenContainerUnfinalizedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TokenContainerFinalizedImplCopyWith<$Res>
    implements $TokenContainerCopyWith<$Res> {
  factory _$$TokenContainerFinalizedImplCopyWith(
          _$TokenContainerFinalizedImpl value,
          $Res Function(_$TokenContainerFinalizedImpl) then) =
      __$$TokenContainerFinalizedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String issuer,
      String nonce,
      DateTime timestamp,
      Uri syncUrl,
      String serial,
      EcKeyAlgorithm ecKeyAlgorithm,
      Algorithms hashAlgorithm,
      String serverName,
      RolloutState finalizationState,
      @SyncStateJsonConverter() SyncState syncState,
      String? passphraseQuestion,
      String publicServerKey,
      String publicClientKey,
      String privateClientKey});
}

/// @nodoc
class __$$TokenContainerFinalizedImplCopyWithImpl<$Res>
    extends _$TokenContainerCopyWithImpl<$Res, _$TokenContainerFinalizedImpl>
    implements _$$TokenContainerFinalizedImplCopyWith<$Res> {
  __$$TokenContainerFinalizedImplCopyWithImpl(
      _$TokenContainerFinalizedImpl _value,
      $Res Function(_$TokenContainerFinalizedImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? issuer = null,
    Object? nonce = null,
    Object? timestamp = null,
    Object? syncUrl = null,
    Object? serial = null,
    Object? ecKeyAlgorithm = null,
    Object? hashAlgorithm = null,
    Object? serverName = null,
    Object? finalizationState = null,
    Object? syncState = null,
    Object? passphraseQuestion = freezed,
    Object? publicServerKey = null,
    Object? publicClientKey = null,
    Object? privateClientKey = null,
  }) {
    return _then(_$TokenContainerFinalizedImpl(
      issuer: null == issuer
          ? _value.issuer
          : issuer // ignore: cast_nullable_to_non_nullable
              as String,
      nonce: null == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncUrl: null == syncUrl
          ? _value.syncUrl
          : syncUrl // ignore: cast_nullable_to_non_nullable
              as Uri,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      ecKeyAlgorithm: null == ecKeyAlgorithm
          ? _value.ecKeyAlgorithm
          : ecKeyAlgorithm // ignore: cast_nullable_to_non_nullable
              as EcKeyAlgorithm,
      hashAlgorithm: null == hashAlgorithm
          ? _value.hashAlgorithm
          : hashAlgorithm // ignore: cast_nullable_to_non_nullable
              as Algorithms,
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      finalizationState: null == finalizationState
          ? _value.finalizationState
          : finalizationState // ignore: cast_nullable_to_non_nullable
              as RolloutState,
      syncState: null == syncState
          ? _value.syncState
          : syncState // ignore: cast_nullable_to_non_nullable
              as SyncState,
      passphraseQuestion: freezed == passphraseQuestion
          ? _value.passphraseQuestion
          : passphraseQuestion // ignore: cast_nullable_to_non_nullable
              as String?,
      publicServerKey: null == publicServerKey
          ? _value.publicServerKey
          : publicServerKey // ignore: cast_nullable_to_non_nullable
              as String,
      publicClientKey: null == publicClientKey
          ? _value.publicClientKey
          : publicClientKey // ignore: cast_nullable_to_non_nullable
              as String,
      privateClientKey: null == privateClientKey
          ? _value.privateClientKey
          : privateClientKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenContainerFinalizedImpl extends TokenContainerFinalized {
  const _$TokenContainerFinalizedImpl(
      {required this.issuer,
      required this.nonce,
      required this.timestamp,
      required this.syncUrl,
      required this.serial,
      required this.ecKeyAlgorithm,
      required this.hashAlgorithm,
      this.serverName = 'privacyIDEA',
      this.finalizationState = RolloutState.completed,
      @SyncStateJsonConverter() this.syncState = SyncState.notStarted,
      this.passphraseQuestion,
      required this.publicServerKey,
      required this.publicClientKey,
      required this.privateClientKey,
      final String? $type})
      : $type = $type ?? 'finalized',
        super._();

  factory _$TokenContainerFinalizedImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenContainerFinalizedImplFromJson(json);

  @override
  final String issuer;
  @override
  final String nonce;
  @override
  final DateTime timestamp;
  @override
  final Uri syncUrl;
  @override
  final String serial;
  @override
  final EcKeyAlgorithm ecKeyAlgorithm;
  @override
  final Algorithms hashAlgorithm;
  @override
  @JsonKey()
  final String serverName;
  @override
  @JsonKey()
  final RolloutState finalizationState;
  @override
  @JsonKey()
  @SyncStateJsonConverter()
  final SyncState syncState;
  @override
  final String? passphraseQuestion;
  @override
  final String publicServerKey;
  @override
  final String publicClientKey;
  @override
  final String privateClientKey;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenContainerFinalizedImpl &&
            (identical(other.issuer, issuer) || other.issuer == issuer) &&
            (identical(other.nonce, nonce) || other.nonce == nonce) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.syncUrl, syncUrl) || other.syncUrl == syncUrl) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.ecKeyAlgorithm, ecKeyAlgorithm) ||
                other.ecKeyAlgorithm == ecKeyAlgorithm) &&
            (identical(other.hashAlgorithm, hashAlgorithm) ||
                other.hashAlgorithm == hashAlgorithm) &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName) &&
            (identical(other.finalizationState, finalizationState) ||
                other.finalizationState == finalizationState) &&
            (identical(other.syncState, syncState) ||
                other.syncState == syncState) &&
            (identical(other.passphraseQuestion, passphraseQuestion) ||
                other.passphraseQuestion == passphraseQuestion) &&
            (identical(other.publicServerKey, publicServerKey) ||
                other.publicServerKey == publicServerKey) &&
            (identical(other.publicClientKey, publicClientKey) ||
                other.publicClientKey == publicClientKey) &&
            (identical(other.privateClientKey, privateClientKey) ||
                other.privateClientKey == privateClientKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      issuer,
      nonce,
      timestamp,
      syncUrl,
      serial,
      ecKeyAlgorithm,
      hashAlgorithm,
      serverName,
      finalizationState,
      syncState,
      passphraseQuestion,
      publicServerKey,
      publicClientKey,
      privateClientKey);

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenContainerFinalizedImplCopyWith<_$TokenContainerFinalizedImpl>
      get copyWith => __$$TokenContainerFinalizedImplCopyWithImpl<
          _$TokenContainerFinalizedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri finalizationUrl,
            Uri? syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)
        unfinalized,
    required TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            @SyncStateJsonConverter() SyncState syncState,
            String? passphraseQuestion,
            String publicServerKey,
            String publicClientKey,
            String privateClientKey)
        finalized,
  }) {
    return finalized(
        issuer,
        nonce,
        timestamp,
        syncUrl,
        serial,
        ecKeyAlgorithm,
        hashAlgorithm,
        serverName,
        finalizationState,
        syncState,
        passphraseQuestion,
        publicServerKey,
        publicClientKey,
        privateClientKey);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri finalizationUrl,
            Uri? syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)?
        unfinalized,
    TResult? Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            @SyncStateJsonConverter() SyncState syncState,
            String? passphraseQuestion,
            String publicServerKey,
            String publicClientKey,
            String privateClientKey)?
        finalized,
  }) {
    return finalized?.call(
        issuer,
        nonce,
        timestamp,
        syncUrl,
        serial,
        ecKeyAlgorithm,
        hashAlgorithm,
        serverName,
        finalizationState,
        syncState,
        passphraseQuestion,
        publicServerKey,
        publicClientKey,
        privateClientKey);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri finalizationUrl,
            Uri? syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)?
        unfinalized,
    TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri syncUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            String serverName,
            RolloutState finalizationState,
            @SyncStateJsonConverter() SyncState syncState,
            String? passphraseQuestion,
            String publicServerKey,
            String publicClientKey,
            String privateClientKey)?
        finalized,
    required TResult orElse(),
  }) {
    if (finalized != null) {
      return finalized(
          issuer,
          nonce,
          timestamp,
          syncUrl,
          serial,
          ecKeyAlgorithm,
          hashAlgorithm,
          serverName,
          finalizationState,
          syncState,
          passphraseQuestion,
          publicServerKey,
          publicClientKey,
          privateClientKey);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TokenContainerUnfinalized value) unfinalized,
    required TResult Function(TokenContainerFinalized value) finalized,
  }) {
    return finalized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TokenContainerUnfinalized value)? unfinalized,
    TResult? Function(TokenContainerFinalized value)? finalized,
  }) {
    return finalized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TokenContainerUnfinalized value)? unfinalized,
    TResult Function(TokenContainerFinalized value)? finalized,
    required TResult orElse(),
  }) {
    if (finalized != null) {
      return finalized(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenContainerFinalizedImplToJson(
      this,
    );
  }
}

abstract class TokenContainerFinalized extends TokenContainer {
  const factory TokenContainerFinalized(
      {required final String issuer,
      required final String nonce,
      required final DateTime timestamp,
      required final Uri syncUrl,
      required final String serial,
      required final EcKeyAlgorithm ecKeyAlgorithm,
      required final Algorithms hashAlgorithm,
      final String serverName,
      final RolloutState finalizationState,
      @SyncStateJsonConverter() final SyncState syncState,
      final String? passphraseQuestion,
      required final String publicServerKey,
      required final String publicClientKey,
      required final String privateClientKey}) = _$TokenContainerFinalizedImpl;
  const TokenContainerFinalized._() : super._();

  factory TokenContainerFinalized.fromJson(Map<String, dynamic> json) =
      _$TokenContainerFinalizedImpl.fromJson;

  @override
  String get issuer;
  @override
  String get nonce;
  @override
  DateTime get timestamp;
  @override
  Uri get syncUrl;
  @override
  String get serial;
  @override
  EcKeyAlgorithm get ecKeyAlgorithm;
  @override
  Algorithms get hashAlgorithm;
  @override
  String get serverName;
  @override
  RolloutState get finalizationState;
  @SyncStateJsonConverter()
  SyncState get syncState;
  @override
  String? get passphraseQuestion;
  @override
  String get publicServerKey;
  @override
  String get publicClientKey;
  @override
  String get privateClientKey;

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenContainerFinalizedImplCopyWith<_$TokenContainerFinalizedImpl>
      get copyWith => throw _privateConstructorUsedError;
}
