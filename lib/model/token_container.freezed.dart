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
  Uri get serverUrl => throw _privateConstructorUsedError;
  String get serial => throw _privateConstructorUsedError;
  EcKeyAlgorithm get ecKeyAlgorithm => throw _privateConstructorUsedError;
  Algorithms get hashAlgorithm => throw _privateConstructorUsedError;
  bool get sslVerify => throw _privateConstructorUsedError;
  String get serverName => throw _privateConstructorUsedError;
  RolloutState get finalizationState => throw _privateConstructorUsedError;
  ContainerPolicies get policies => throw _privateConstructorUsedError;
  String? get passphraseQuestion => throw _privateConstructorUsedError;
  String? get publicServerKey => throw _privateConstructorUsedError;
  String? get publicClientKey => throw _privateConstructorUsedError;
  String? get privateClientKey => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String issuer,
            Duration ttl,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            ContainerPolicies policies,
            bool? addDeviceInfos,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)
        unfinalized,
    required TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            SyncState syncState,
            ContainerPolicies policies,
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
            Duration ttl,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            ContainerPolicies policies,
            bool? addDeviceInfos,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)?
        unfinalized,
    TResult? Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            SyncState syncState,
            ContainerPolicies policies,
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
            Duration ttl,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            ContainerPolicies policies,
            bool? addDeviceInfos,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)?
        unfinalized,
    TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            SyncState syncState,
            ContainerPolicies policies,
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
      Uri serverUrl,
      String serial,
      EcKeyAlgorithm ecKeyAlgorithm,
      Algorithms hashAlgorithm,
      bool sslVerify,
      String serverName,
      RolloutState finalizationState,
      ContainerPolicies policies,
      String? passphraseQuestion,
      String publicServerKey,
      String publicClientKey,
      String privateClientKey});

  $ContainerPoliciesCopyWith<$Res> get policies;
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
    Object? serverUrl = null,
    Object? serial = null,
    Object? ecKeyAlgorithm = null,
    Object? hashAlgorithm = null,
    Object? sslVerify = null,
    Object? serverName = null,
    Object? finalizationState = null,
    Object? policies = null,
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
      serverUrl: null == serverUrl
          ? _value.serverUrl
          : serverUrl // ignore: cast_nullable_to_non_nullable
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
      sslVerify: null == sslVerify
          ? _value.sslVerify
          : sslVerify // ignore: cast_nullable_to_non_nullable
              as bool,
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      finalizationState: null == finalizationState
          ? _value.finalizationState
          : finalizationState // ignore: cast_nullable_to_non_nullable
              as RolloutState,
      policies: null == policies
          ? _value.policies
          : policies // ignore: cast_nullable_to_non_nullable
              as ContainerPolicies,
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

  /// Create a copy of TokenContainer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContainerPoliciesCopyWith<$Res> get policies {
    return $ContainerPoliciesCopyWith<$Res>(_value.policies, (value) {
      return _then(_value.copyWith(policies: value) as $Val);
    });
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
      Duration ttl,
      String nonce,
      DateTime timestamp,
      Uri serverUrl,
      String serial,
      EcKeyAlgorithm ecKeyAlgorithm,
      Algorithms hashAlgorithm,
      bool sslVerify,
      String serverName,
      RolloutState finalizationState,
      ContainerPolicies policies,
      bool? addDeviceInfos,
      String? passphraseQuestion,
      String? publicServerKey,
      String? publicClientKey,
      String? privateClientKey});

  @override
  $ContainerPoliciesCopyWith<$Res> get policies;
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
    Object? ttl = null,
    Object? nonce = null,
    Object? timestamp = null,
    Object? serverUrl = null,
    Object? serial = null,
    Object? ecKeyAlgorithm = null,
    Object? hashAlgorithm = null,
    Object? sslVerify = null,
    Object? serverName = null,
    Object? finalizationState = null,
    Object? policies = null,
    Object? addDeviceInfos = freezed,
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
      ttl: null == ttl
          ? _value.ttl
          : ttl // ignore: cast_nullable_to_non_nullable
              as Duration,
      nonce: null == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      serverUrl: null == serverUrl
          ? _value.serverUrl
          : serverUrl // ignore: cast_nullable_to_non_nullable
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
      sslVerify: null == sslVerify
          ? _value.sslVerify
          : sslVerify // ignore: cast_nullable_to_non_nullable
              as bool,
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      finalizationState: null == finalizationState
          ? _value.finalizationState
          : finalizationState // ignore: cast_nullable_to_non_nullable
              as RolloutState,
      policies: null == policies
          ? _value.policies
          : policies // ignore: cast_nullable_to_non_nullable
              as ContainerPolicies,
      addDeviceInfos: freezed == addDeviceInfos
          ? _value.addDeviceInfos
          : addDeviceInfos // ignore: cast_nullable_to_non_nullable
              as bool?,
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
      required this.ttl,
      required this.nonce,
      required this.timestamp,
      required this.serverUrl,
      required this.serial,
      required this.ecKeyAlgorithm,
      required this.hashAlgorithm,
      required this.sslVerify,
      this.serverName = 'privacyIDEA',
      this.finalizationState = RolloutState.completed,
      this.policies = ContainerPolicies.defaultSetting,
      this.addDeviceInfos,
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
  final Duration ttl;
  @override
  final String nonce;
  @override
  final DateTime timestamp;
  @override
  final Uri serverUrl;
  @override
  final String serial;
  @override
  final EcKeyAlgorithm ecKeyAlgorithm;
  @override
  final Algorithms hashAlgorithm;
  @override
  final bool sslVerify;
  @override
  @JsonKey()
  final String serverName;
  @override
  @JsonKey()
  final RolloutState finalizationState;
  @override
  @JsonKey()
  final ContainerPolicies policies;
  @override
  final bool? addDeviceInfos;
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
            (identical(other.ttl, ttl) || other.ttl == ttl) &&
            (identical(other.nonce, nonce) || other.nonce == nonce) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.serverUrl, serverUrl) ||
                other.serverUrl == serverUrl) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.ecKeyAlgorithm, ecKeyAlgorithm) ||
                other.ecKeyAlgorithm == ecKeyAlgorithm) &&
            (identical(other.hashAlgorithm, hashAlgorithm) ||
                other.hashAlgorithm == hashAlgorithm) &&
            (identical(other.sslVerify, sslVerify) ||
                other.sslVerify == sslVerify) &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName) &&
            (identical(other.finalizationState, finalizationState) ||
                other.finalizationState == finalizationState) &&
            (identical(other.policies, policies) ||
                other.policies == policies) &&
            (identical(other.addDeviceInfos, addDeviceInfos) ||
                other.addDeviceInfos == addDeviceInfos) &&
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
      ttl,
      nonce,
      timestamp,
      serverUrl,
      serial,
      ecKeyAlgorithm,
      hashAlgorithm,
      sslVerify,
      serverName,
      finalizationState,
      policies,
      addDeviceInfos,
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
            Duration ttl,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            ContainerPolicies policies,
            bool? addDeviceInfos,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)
        unfinalized,
    required TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            SyncState syncState,
            ContainerPolicies policies,
            String? passphraseQuestion,
            String publicServerKey,
            String publicClientKey,
            String privateClientKey)
        finalized,
  }) {
    return unfinalized(
        issuer,
        ttl,
        nonce,
        timestamp,
        serverUrl,
        serial,
        ecKeyAlgorithm,
        hashAlgorithm,
        sslVerify,
        serverName,
        finalizationState,
        policies,
        addDeviceInfos,
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
            Duration ttl,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            ContainerPolicies policies,
            bool? addDeviceInfos,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)?
        unfinalized,
    TResult? Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            SyncState syncState,
            ContainerPolicies policies,
            String? passphraseQuestion,
            String publicServerKey,
            String publicClientKey,
            String privateClientKey)?
        finalized,
  }) {
    return unfinalized?.call(
        issuer,
        ttl,
        nonce,
        timestamp,
        serverUrl,
        serial,
        ecKeyAlgorithm,
        hashAlgorithm,
        sslVerify,
        serverName,
        finalizationState,
        policies,
        addDeviceInfos,
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
            Duration ttl,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            ContainerPolicies policies,
            bool? addDeviceInfos,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)?
        unfinalized,
    TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            SyncState syncState,
            ContainerPolicies policies,
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
          ttl,
          nonce,
          timestamp,
          serverUrl,
          serial,
          ecKeyAlgorithm,
          hashAlgorithm,
          sslVerify,
          serverName,
          finalizationState,
          policies,
          addDeviceInfos,
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
      required final Duration ttl,
      required final String nonce,
      required final DateTime timestamp,
      required final Uri serverUrl,
      required final String serial,
      required final EcKeyAlgorithm ecKeyAlgorithm,
      required final Algorithms hashAlgorithm,
      required final bool sslVerify,
      final String serverName,
      final RolloutState finalizationState,
      final ContainerPolicies policies,
      final bool? addDeviceInfos,
      final String? passphraseQuestion,
      final String? publicServerKey,
      final String? publicClientKey,
      final String? privateClientKey}) = _$TokenContainerUnfinalizedImpl;
  const TokenContainerUnfinalized._() : super._();

  factory TokenContainerUnfinalized.fromJson(Map<String, dynamic> json) =
      _$TokenContainerUnfinalizedImpl.fromJson;

  @override
  String get issuer;
  Duration get ttl;
  @override
  String get nonce;
  @override
  DateTime get timestamp;
  @override
  Uri get serverUrl;
  @override
  String get serial;
  @override
  EcKeyAlgorithm get ecKeyAlgorithm;
  @override
  Algorithms get hashAlgorithm;
  @override
  bool get sslVerify;
  @override
  String get serverName;
  @override
  RolloutState get finalizationState;
  @override
  ContainerPolicies get policies;
  bool? get addDeviceInfos;
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
      Uri serverUrl,
      String serial,
      EcKeyAlgorithm ecKeyAlgorithm,
      Algorithms hashAlgorithm,
      bool sslVerify,
      String serverName,
      RolloutState finalizationState,
      SyncState syncState,
      ContainerPolicies policies,
      String? passphraseQuestion,
      String publicServerKey,
      String publicClientKey,
      String privateClientKey});

  @override
  $ContainerPoliciesCopyWith<$Res> get policies;
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
    Object? serverUrl = null,
    Object? serial = null,
    Object? ecKeyAlgorithm = null,
    Object? hashAlgorithm = null,
    Object? sslVerify = null,
    Object? serverName = null,
    Object? finalizationState = null,
    Object? syncState = null,
    Object? policies = null,
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
      serverUrl: null == serverUrl
          ? _value.serverUrl
          : serverUrl // ignore: cast_nullable_to_non_nullable
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
      sslVerify: null == sslVerify
          ? _value.sslVerify
          : sslVerify // ignore: cast_nullable_to_non_nullable
              as bool,
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
      policies: null == policies
          ? _value.policies
          : policies // ignore: cast_nullable_to_non_nullable
              as ContainerPolicies,
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
      required this.serverUrl,
      required this.serial,
      required this.ecKeyAlgorithm,
      required this.hashAlgorithm,
      required this.sslVerify,
      this.serverName = 'privacyIDEA',
      this.finalizationState = RolloutState.completed,
      this.syncState = SyncState.notStarted,
      this.policies = ContainerPolicies.defaultSetting,
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
  final Uri serverUrl;
  @override
  final String serial;
  @override
  final EcKeyAlgorithm ecKeyAlgorithm;
  @override
  final Algorithms hashAlgorithm;
  @override
  final bool sslVerify;
  @override
  @JsonKey()
  final String serverName;
  @override
  @JsonKey()
  final RolloutState finalizationState;
  @override
  @JsonKey()
  final SyncState syncState;
  @override
  @JsonKey()
  final ContainerPolicies policies;
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
            (identical(other.serverUrl, serverUrl) ||
                other.serverUrl == serverUrl) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.ecKeyAlgorithm, ecKeyAlgorithm) ||
                other.ecKeyAlgorithm == ecKeyAlgorithm) &&
            (identical(other.hashAlgorithm, hashAlgorithm) ||
                other.hashAlgorithm == hashAlgorithm) &&
            (identical(other.sslVerify, sslVerify) ||
                other.sslVerify == sslVerify) &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName) &&
            (identical(other.finalizationState, finalizationState) ||
                other.finalizationState == finalizationState) &&
            (identical(other.syncState, syncState) ||
                other.syncState == syncState) &&
            (identical(other.policies, policies) ||
                other.policies == policies) &&
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
      serverUrl,
      serial,
      ecKeyAlgorithm,
      hashAlgorithm,
      sslVerify,
      serverName,
      finalizationState,
      syncState,
      policies,
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
            Duration ttl,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            ContainerPolicies policies,
            bool? addDeviceInfos,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)
        unfinalized,
    required TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            SyncState syncState,
            ContainerPolicies policies,
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
        serverUrl,
        serial,
        ecKeyAlgorithm,
        hashAlgorithm,
        sslVerify,
        serverName,
        finalizationState,
        syncState,
        policies,
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
            Duration ttl,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            ContainerPolicies policies,
            bool? addDeviceInfos,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)?
        unfinalized,
    TResult? Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            SyncState syncState,
            ContainerPolicies policies,
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
        serverUrl,
        serial,
        ecKeyAlgorithm,
        hashAlgorithm,
        sslVerify,
        serverName,
        finalizationState,
        syncState,
        policies,
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
            Duration ttl,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            ContainerPolicies policies,
            bool? addDeviceInfos,
            String? passphraseQuestion,
            String? publicServerKey,
            String? publicClientKey,
            String? privateClientKey)?
        unfinalized,
    TResult Function(
            String issuer,
            String nonce,
            DateTime timestamp,
            Uri serverUrl,
            String serial,
            EcKeyAlgorithm ecKeyAlgorithm,
            Algorithms hashAlgorithm,
            bool sslVerify,
            String serverName,
            RolloutState finalizationState,
            SyncState syncState,
            ContainerPolicies policies,
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
          serverUrl,
          serial,
          ecKeyAlgorithm,
          hashAlgorithm,
          sslVerify,
          serverName,
          finalizationState,
          syncState,
          policies,
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
      required final Uri serverUrl,
      required final String serial,
      required final EcKeyAlgorithm ecKeyAlgorithm,
      required final Algorithms hashAlgorithm,
      required final bool sslVerify,
      final String serverName,
      final RolloutState finalizationState,
      final SyncState syncState,
      final ContainerPolicies policies,
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
  Uri get serverUrl;
  @override
  String get serial;
  @override
  EcKeyAlgorithm get ecKeyAlgorithm;
  @override
  Algorithms get hashAlgorithm;
  @override
  bool get sslVerify;
  @override
  String get serverName;
  @override
  RolloutState get finalizationState;
  SyncState get syncState;
  @override
  ContainerPolicies get policies;
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
