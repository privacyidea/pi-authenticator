// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_credentials.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ContainerCredential _$ContainerCredentialFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'unfinalized':
      return ContainerCredentialUnfinalized.fromJson(json);
    case 'finalized':
      return ContainerCredentialFinalized.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'ContainerCredential',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$ContainerCredential {
  String get issuer => throw _privateConstructorUsedError;
  String get nonce => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  Uri? get syncUrl => throw _privateConstructorUsedError;
  String get serial => throw _privateConstructorUsedError;
  EcKeyAlgorithm get ecKeyAlgorithm => throw _privateConstructorUsedError;
  Algorithms get hashAlgorithm => throw _privateConstructorUsedError;
  String get serverName => throw _privateConstructorUsedError;
  ContainerFinalizationState get finalizationState =>
      throw _privateConstructorUsedError;
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
    required TResult Function(ContainerCredentialUnfinalized value) unfinalized,
    required TResult Function(ContainerCredentialFinalized value) finalized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ContainerCredentialUnfinalized value)? unfinalized,
    TResult? Function(ContainerCredentialFinalized value)? finalized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ContainerCredentialUnfinalized value)? unfinalized,
    TResult Function(ContainerCredentialFinalized value)? finalized,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this ContainerCredential to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContainerCredential
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContainerCredentialCopyWith<ContainerCredential> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContainerCredentialCopyWith<$Res> {
  factory $ContainerCredentialCopyWith(
          ContainerCredential value, $Res Function(ContainerCredential) then) =
      _$ContainerCredentialCopyWithImpl<$Res, ContainerCredential>;
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
      ContainerFinalizationState finalizationState,
      String? passphraseQuestion,
      String publicServerKey,
      String publicClientKey,
      String privateClientKey});
}

/// @nodoc
class _$ContainerCredentialCopyWithImpl<$Res, $Val extends ContainerCredential>
    implements $ContainerCredentialCopyWith<$Res> {
  _$ContainerCredentialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContainerCredential
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
              as ContainerFinalizationState,
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
abstract class _$$ContainerCredentialUnfinalizedImplCopyWith<$Res>
    implements $ContainerCredentialCopyWith<$Res> {
  factory _$$ContainerCredentialUnfinalizedImplCopyWith(
          _$ContainerCredentialUnfinalizedImpl value,
          $Res Function(_$ContainerCredentialUnfinalizedImpl) then) =
      __$$ContainerCredentialUnfinalizedImplCopyWithImpl<$Res>;
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
      ContainerFinalizationState finalizationState,
      String? passphraseQuestion,
      String? publicServerKey,
      String? publicClientKey,
      String? privateClientKey});
}

/// @nodoc
class __$$ContainerCredentialUnfinalizedImplCopyWithImpl<$Res>
    extends _$ContainerCredentialCopyWithImpl<$Res,
        _$ContainerCredentialUnfinalizedImpl>
    implements _$$ContainerCredentialUnfinalizedImplCopyWith<$Res> {
  __$$ContainerCredentialUnfinalizedImplCopyWithImpl(
      _$ContainerCredentialUnfinalizedImpl _value,
      $Res Function(_$ContainerCredentialUnfinalizedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContainerCredential
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
    return _then(_$ContainerCredentialUnfinalizedImpl(
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
              as ContainerFinalizationState,
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
class _$ContainerCredentialUnfinalizedImpl
    extends ContainerCredentialUnfinalized {
  const _$ContainerCredentialUnfinalizedImpl(
      {required this.issuer,
      required this.nonce,
      required this.timestamp,
      required this.finalizationUrl,
      this.syncUrl,
      required this.serial,
      required this.ecKeyAlgorithm,
      required this.hashAlgorithm,
      this.serverName = 'privacyIDEA',
      this.finalizationState = ContainerFinalizationState.uninitialized,
      this.passphraseQuestion,
      this.publicServerKey,
      this.publicClientKey,
      this.privateClientKey,
      final String? $type})
      : $type = $type ?? 'unfinalized',
        super._();

  factory _$ContainerCredentialUnfinalizedImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ContainerCredentialUnfinalizedImplFromJson(json);

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
  final ContainerFinalizationState finalizationState;
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
            other is _$ContainerCredentialUnfinalizedImpl &&
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

  /// Create a copy of ContainerCredential
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContainerCredentialUnfinalizedImplCopyWith<
          _$ContainerCredentialUnfinalizedImpl>
      get copyWith => __$$ContainerCredentialUnfinalizedImplCopyWithImpl<
          _$ContainerCredentialUnfinalizedImpl>(this, _$identity);

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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
    required TResult Function(ContainerCredentialUnfinalized value) unfinalized,
    required TResult Function(ContainerCredentialFinalized value) finalized,
  }) {
    return unfinalized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ContainerCredentialUnfinalized value)? unfinalized,
    TResult? Function(ContainerCredentialFinalized value)? finalized,
  }) {
    return unfinalized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ContainerCredentialUnfinalized value)? unfinalized,
    TResult Function(ContainerCredentialFinalized value)? finalized,
    required TResult orElse(),
  }) {
    if (unfinalized != null) {
      return unfinalized(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ContainerCredentialUnfinalizedImplToJson(
      this,
    );
  }
}

abstract class ContainerCredentialUnfinalized extends ContainerCredential {
  const factory ContainerCredentialUnfinalized(
      {required final String issuer,
      required final String nonce,
      required final DateTime timestamp,
      required final Uri finalizationUrl,
      final Uri? syncUrl,
      required final String serial,
      required final EcKeyAlgorithm ecKeyAlgorithm,
      required final Algorithms hashAlgorithm,
      final String serverName,
      final ContainerFinalizationState finalizationState,
      final String? passphraseQuestion,
      final String? publicServerKey,
      final String? publicClientKey,
      final String? privateClientKey}) = _$ContainerCredentialUnfinalizedImpl;
  const ContainerCredentialUnfinalized._() : super._();

  factory ContainerCredentialUnfinalized.fromJson(Map<String, dynamic> json) =
      _$ContainerCredentialUnfinalizedImpl.fromJson;

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
  ContainerFinalizationState get finalizationState;
  @override
  String? get passphraseQuestion;
  @override
  String? get publicServerKey;
  @override
  String? get publicClientKey;
  @override
  String? get privateClientKey;

  /// Create a copy of ContainerCredential
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContainerCredentialUnfinalizedImplCopyWith<
          _$ContainerCredentialUnfinalizedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ContainerCredentialFinalizedImplCopyWith<$Res>
    implements $ContainerCredentialCopyWith<$Res> {
  factory _$$ContainerCredentialFinalizedImplCopyWith(
          _$ContainerCredentialFinalizedImpl value,
          $Res Function(_$ContainerCredentialFinalizedImpl) then) =
      __$$ContainerCredentialFinalizedImplCopyWithImpl<$Res>;
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
      ContainerFinalizationState finalizationState,
      String? passphraseQuestion,
      String publicServerKey,
      String publicClientKey,
      String privateClientKey});
}

/// @nodoc
class __$$ContainerCredentialFinalizedImplCopyWithImpl<$Res>
    extends _$ContainerCredentialCopyWithImpl<$Res,
        _$ContainerCredentialFinalizedImpl>
    implements _$$ContainerCredentialFinalizedImplCopyWith<$Res> {
  __$$ContainerCredentialFinalizedImplCopyWithImpl(
      _$ContainerCredentialFinalizedImpl _value,
      $Res Function(_$ContainerCredentialFinalizedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContainerCredential
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
    return _then(_$ContainerCredentialFinalizedImpl(
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
              as ContainerFinalizationState,
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
class _$ContainerCredentialFinalizedImpl extends ContainerCredentialFinalized {
  const _$ContainerCredentialFinalizedImpl(
      {required this.issuer,
      required this.nonce,
      required this.timestamp,
      required this.syncUrl,
      required this.serial,
      required this.ecKeyAlgorithm,
      required this.hashAlgorithm,
      this.serverName = 'privacyIDEA',
      this.finalizationState = ContainerFinalizationState.finalized,
      this.passphraseQuestion,
      required this.publicServerKey,
      required this.publicClientKey,
      required this.privateClientKey,
      final String? $type})
      : $type = $type ?? 'finalized',
        super._();

  factory _$ContainerCredentialFinalizedImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ContainerCredentialFinalizedImplFromJson(json);

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
  final ContainerFinalizationState finalizationState;
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
            other is _$ContainerCredentialFinalizedImpl &&
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
      passphraseQuestion,
      publicServerKey,
      publicClientKey,
      privateClientKey);

  /// Create a copy of ContainerCredential
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContainerCredentialFinalizedImplCopyWith<
          _$ContainerCredentialFinalizedImpl>
      get copyWith => __$$ContainerCredentialFinalizedImplCopyWithImpl<
          _$ContainerCredentialFinalizedImpl>(this, _$identity);

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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
            ContainerFinalizationState finalizationState,
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
    required TResult Function(ContainerCredentialUnfinalized value) unfinalized,
    required TResult Function(ContainerCredentialFinalized value) finalized,
  }) {
    return finalized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ContainerCredentialUnfinalized value)? unfinalized,
    TResult? Function(ContainerCredentialFinalized value)? finalized,
  }) {
    return finalized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ContainerCredentialUnfinalized value)? unfinalized,
    TResult Function(ContainerCredentialFinalized value)? finalized,
    required TResult orElse(),
  }) {
    if (finalized != null) {
      return finalized(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ContainerCredentialFinalizedImplToJson(
      this,
    );
  }
}

abstract class ContainerCredentialFinalized extends ContainerCredential {
  const factory ContainerCredentialFinalized(
          {required final String issuer,
          required final String nonce,
          required final DateTime timestamp,
          required final Uri syncUrl,
          required final String serial,
          required final EcKeyAlgorithm ecKeyAlgorithm,
          required final Algorithms hashAlgorithm,
          final String serverName,
          final ContainerFinalizationState finalizationState,
          final String? passphraseQuestion,
          required final String publicServerKey,
          required final String publicClientKey,
          required final String privateClientKey}) =
      _$ContainerCredentialFinalizedImpl;
  const ContainerCredentialFinalized._() : super._();

  factory ContainerCredentialFinalized.fromJson(Map<String, dynamic> json) =
      _$ContainerCredentialFinalizedImpl.fromJson;

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
  ContainerFinalizationState get finalizationState;
  @override
  String? get passphraseQuestion;
  @override
  String get publicServerKey;
  @override
  String get publicClientKey;
  @override
  String get privateClientKey;

  /// Create a copy of ContainerCredential
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContainerCredentialFinalizedImplCopyWith<
          _$ContainerCredentialFinalizedImpl>
      get copyWith => throw _privateConstructorUsedError;
}
