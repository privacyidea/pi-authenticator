// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_container.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
TokenContainer _$TokenContainerFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'unfinalized':
          return TokenContainerUnfinalized.fromJson(
            json
          );
                case 'finalized':
          return TokenContainerFinalized.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'TokenContainer',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$TokenContainer {

 String get issuer; String get nonce; DateTime get timestamp; Uri get serverUrl; String get serial; EcKeyAlgorithm get ecKeyAlgorithm; Algorithms get hashAlgorithm; bool get sslVerify; String get serverName; FinalizationState get finalizationState; ContainerPolicies get policies; String? get passphraseQuestion; String? get publicClientKey; String? get privateClientKey;
/// Create a copy of TokenContainer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenContainerCopyWith<TokenContainer> get copyWith => _$TokenContainerCopyWithImpl<TokenContainer>(this as TokenContainer, _$identity);

  /// Serializes this TokenContainer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenContainer&&(identical(other.issuer, issuer) || other.issuer == issuer)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.ecKeyAlgorithm, ecKeyAlgorithm) || other.ecKeyAlgorithm == ecKeyAlgorithm)&&(identical(other.hashAlgorithm, hashAlgorithm) || other.hashAlgorithm == hashAlgorithm)&&(identical(other.sslVerify, sslVerify) || other.sslVerify == sslVerify)&&(identical(other.serverName, serverName) || other.serverName == serverName)&&(identical(other.finalizationState, finalizationState) || other.finalizationState == finalizationState)&&(identical(other.policies, policies) || other.policies == policies)&&(identical(other.passphraseQuestion, passphraseQuestion) || other.passphraseQuestion == passphraseQuestion)&&(identical(other.publicClientKey, publicClientKey) || other.publicClientKey == publicClientKey)&&(identical(other.privateClientKey, privateClientKey) || other.privateClientKey == privateClientKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,issuer,nonce,timestamp,serverUrl,serial,ecKeyAlgorithm,hashAlgorithm,sslVerify,serverName,finalizationState,policies,passphraseQuestion,publicClientKey,privateClientKey);



}

/// @nodoc
abstract mixin class $TokenContainerCopyWith<$Res>  {
  factory $TokenContainerCopyWith(TokenContainer value, $Res Function(TokenContainer) _then) = _$TokenContainerCopyWithImpl;
@useResult
$Res call({
 String issuer, String nonce, DateTime timestamp, Uri serverUrl, String serial, EcKeyAlgorithm ecKeyAlgorithm, Algorithms hashAlgorithm, bool sslVerify, String serverName, FinalizationState finalizationState, ContainerPolicies policies, String? passphraseQuestion, String publicClientKey, String privateClientKey
});


$ContainerPoliciesCopyWith<$Res> get policies;

}
/// @nodoc
class _$TokenContainerCopyWithImpl<$Res>
    implements $TokenContainerCopyWith<$Res> {
  _$TokenContainerCopyWithImpl(this._self, this._then);

  final TokenContainer _self;
  final $Res Function(TokenContainer) _then;

/// Create a copy of TokenContainer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? issuer = null,Object? nonce = null,Object? timestamp = null,Object? serverUrl = null,Object? serial = null,Object? ecKeyAlgorithm = null,Object? hashAlgorithm = null,Object? sslVerify = null,Object? serverName = null,Object? finalizationState = null,Object? policies = null,Object? passphraseQuestion = freezed,Object? publicClientKey = null,Object? privateClientKey = null,}) {
  return _then(_self.copyWith(
issuer: null == issuer ? _self.issuer : issuer // ignore: cast_nullable_to_non_nullable
as String,nonce: null == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as Uri,serial: null == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String,ecKeyAlgorithm: null == ecKeyAlgorithm ? _self.ecKeyAlgorithm : ecKeyAlgorithm // ignore: cast_nullable_to_non_nullable
as EcKeyAlgorithm,hashAlgorithm: null == hashAlgorithm ? _self.hashAlgorithm : hashAlgorithm // ignore: cast_nullable_to_non_nullable
as Algorithms,sslVerify: null == sslVerify ? _self.sslVerify : sslVerify // ignore: cast_nullable_to_non_nullable
as bool,serverName: null == serverName ? _self.serverName : serverName // ignore: cast_nullable_to_non_nullable
as String,finalizationState: null == finalizationState ? _self.finalizationState : finalizationState // ignore: cast_nullable_to_non_nullable
as FinalizationState,policies: null == policies ? _self.policies : policies // ignore: cast_nullable_to_non_nullable
as ContainerPolicies,passphraseQuestion: freezed == passphraseQuestion ? _self.passphraseQuestion : passphraseQuestion // ignore: cast_nullable_to_non_nullable
as String?,publicClientKey: null == publicClientKey ? _self.publicClientKey! : publicClientKey // ignore: cast_nullable_to_non_nullable
as String,privateClientKey: null == privateClientKey ? _self.privateClientKey! : privateClientKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of TokenContainer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerPoliciesCopyWith<$Res> get policies {
  
  return $ContainerPoliciesCopyWith<$Res>(_self.policies, (value) {
    return _then(_self.copyWith(policies: value));
  });
}
}


/// Adds pattern-matching-related methods to [TokenContainer].
extension TokenContainerPatterns on TokenContainer {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TokenContainerUnfinalized value)?  unfinalized,TResult Function( TokenContainerFinalized value)?  finalized,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TokenContainerUnfinalized() when unfinalized != null:
return unfinalized(_that);case TokenContainerFinalized() when finalized != null:
return finalized(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TokenContainerUnfinalized value)  unfinalized,required TResult Function( TokenContainerFinalized value)  finalized,}){
final _that = this;
switch (_that) {
case TokenContainerUnfinalized():
return unfinalized(_that);case TokenContainerFinalized():
return finalized(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TokenContainerUnfinalized value)?  unfinalized,TResult? Function( TokenContainerFinalized value)?  finalized,}){
final _that = this;
switch (_that) {
case TokenContainerUnfinalized() when unfinalized != null:
return unfinalized(_that);case TokenContainerFinalized() when finalized != null:
return finalized(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String issuer,  Duration ttl,  String nonce,  DateTime timestamp,  Uri serverUrl,  String serial,  EcKeyAlgorithm ecKeyAlgorithm,  Algorithms hashAlgorithm,  bool sslVerify,  String serverName,  FinalizationState finalizationState,  ContainerPolicies policies,  bool? addDeviceInfos,  String? passphraseQuestion,  String? publicClientKey,  String? privateClientKey,  bool sendPassphrase)?  unfinalized,TResult Function( String issuer,  String nonce,  DateTime timestamp,  Uri serverUrl,  String serial,  EcKeyAlgorithm ecKeyAlgorithm,  Algorithms hashAlgorithm,  bool sslVerify,  String serverName,  FinalizationState finalizationState,  SyncState syncState,  ContainerPolicies policies,  bool initSynced,  String? passphraseQuestion,  String publicClientKey,  String privateClientKey)?  finalized,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TokenContainerUnfinalized() when unfinalized != null:
return unfinalized(_that.issuer,_that.ttl,_that.nonce,_that.timestamp,_that.serverUrl,_that.serial,_that.ecKeyAlgorithm,_that.hashAlgorithm,_that.sslVerify,_that.serverName,_that.finalizationState,_that.policies,_that.addDeviceInfos,_that.passphraseQuestion,_that.publicClientKey,_that.privateClientKey,_that.sendPassphrase);case TokenContainerFinalized() when finalized != null:
return finalized(_that.issuer,_that.nonce,_that.timestamp,_that.serverUrl,_that.serial,_that.ecKeyAlgorithm,_that.hashAlgorithm,_that.sslVerify,_that.serverName,_that.finalizationState,_that.syncState,_that.policies,_that.initSynced,_that.passphraseQuestion,_that.publicClientKey,_that.privateClientKey);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String issuer,  Duration ttl,  String nonce,  DateTime timestamp,  Uri serverUrl,  String serial,  EcKeyAlgorithm ecKeyAlgorithm,  Algorithms hashAlgorithm,  bool sslVerify,  String serverName,  FinalizationState finalizationState,  ContainerPolicies policies,  bool? addDeviceInfos,  String? passphraseQuestion,  String? publicClientKey,  String? privateClientKey,  bool sendPassphrase)  unfinalized,required TResult Function( String issuer,  String nonce,  DateTime timestamp,  Uri serverUrl,  String serial,  EcKeyAlgorithm ecKeyAlgorithm,  Algorithms hashAlgorithm,  bool sslVerify,  String serverName,  FinalizationState finalizationState,  SyncState syncState,  ContainerPolicies policies,  bool initSynced,  String? passphraseQuestion,  String publicClientKey,  String privateClientKey)  finalized,}) {final _that = this;
switch (_that) {
case TokenContainerUnfinalized():
return unfinalized(_that.issuer,_that.ttl,_that.nonce,_that.timestamp,_that.serverUrl,_that.serial,_that.ecKeyAlgorithm,_that.hashAlgorithm,_that.sslVerify,_that.serverName,_that.finalizationState,_that.policies,_that.addDeviceInfos,_that.passphraseQuestion,_that.publicClientKey,_that.privateClientKey,_that.sendPassphrase);case TokenContainerFinalized():
return finalized(_that.issuer,_that.nonce,_that.timestamp,_that.serverUrl,_that.serial,_that.ecKeyAlgorithm,_that.hashAlgorithm,_that.sslVerify,_that.serverName,_that.finalizationState,_that.syncState,_that.policies,_that.initSynced,_that.passphraseQuestion,_that.publicClientKey,_that.privateClientKey);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String issuer,  Duration ttl,  String nonce,  DateTime timestamp,  Uri serverUrl,  String serial,  EcKeyAlgorithm ecKeyAlgorithm,  Algorithms hashAlgorithm,  bool sslVerify,  String serverName,  FinalizationState finalizationState,  ContainerPolicies policies,  bool? addDeviceInfos,  String? passphraseQuestion,  String? publicClientKey,  String? privateClientKey,  bool sendPassphrase)?  unfinalized,TResult? Function( String issuer,  String nonce,  DateTime timestamp,  Uri serverUrl,  String serial,  EcKeyAlgorithm ecKeyAlgorithm,  Algorithms hashAlgorithm,  bool sslVerify,  String serverName,  FinalizationState finalizationState,  SyncState syncState,  ContainerPolicies policies,  bool initSynced,  String? passphraseQuestion,  String publicClientKey,  String privateClientKey)?  finalized,}) {final _that = this;
switch (_that) {
case TokenContainerUnfinalized() when unfinalized != null:
return unfinalized(_that.issuer,_that.ttl,_that.nonce,_that.timestamp,_that.serverUrl,_that.serial,_that.ecKeyAlgorithm,_that.hashAlgorithm,_that.sslVerify,_that.serverName,_that.finalizationState,_that.policies,_that.addDeviceInfos,_that.passphraseQuestion,_that.publicClientKey,_that.privateClientKey,_that.sendPassphrase);case TokenContainerFinalized() when finalized != null:
return finalized(_that.issuer,_that.nonce,_that.timestamp,_that.serverUrl,_that.serial,_that.ecKeyAlgorithm,_that.hashAlgorithm,_that.sslVerify,_that.serverName,_that.finalizationState,_that.syncState,_that.policies,_that.initSynced,_that.passphraseQuestion,_that.publicClientKey,_that.privateClientKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class TokenContainerUnfinalized extends TokenContainer {
  const TokenContainerUnfinalized({required this.issuer, required this.ttl, required this.nonce, required this.timestamp, required this.serverUrl, required this.serial, required this.ecKeyAlgorithm, required this.hashAlgorithm, required this.sslVerify, this.serverName = 'privacyIDEA', this.finalizationState = FinalizationState.notStarted, this.policies = ContainerPolicies.defaultSetting, this.addDeviceInfos, this.passphraseQuestion, this.publicClientKey, this.privateClientKey, this.sendPassphrase = false, final  String? $type}): $type = $type ?? 'unfinalized',super._();
  factory TokenContainerUnfinalized.fromJson(Map<String, dynamic> json) => _$TokenContainerUnfinalizedFromJson(json);

@override final  String issuer;
 final  Duration ttl;
@override final  String nonce;
@override final  DateTime timestamp;
@override final  Uri serverUrl;
@override final  String serial;
@override final  EcKeyAlgorithm ecKeyAlgorithm;
@override final  Algorithms hashAlgorithm;
@override final  bool sslVerify;
@override@JsonKey() final  String serverName;
@override@JsonKey() final  FinalizationState finalizationState;
@override@JsonKey() final  ContainerPolicies policies;
 final  bool? addDeviceInfos;
@override final  String? passphraseQuestion;
@override final  String? publicClientKey;
@override final  String? privateClientKey;
@JsonKey() final  bool sendPassphrase;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of TokenContainer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenContainerUnfinalizedCopyWith<TokenContainerUnfinalized> get copyWith => _$TokenContainerUnfinalizedCopyWithImpl<TokenContainerUnfinalized>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenContainerUnfinalizedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenContainerUnfinalized&&(identical(other.issuer, issuer) || other.issuer == issuer)&&(identical(other.ttl, ttl) || other.ttl == ttl)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.ecKeyAlgorithm, ecKeyAlgorithm) || other.ecKeyAlgorithm == ecKeyAlgorithm)&&(identical(other.hashAlgorithm, hashAlgorithm) || other.hashAlgorithm == hashAlgorithm)&&(identical(other.sslVerify, sslVerify) || other.sslVerify == sslVerify)&&(identical(other.serverName, serverName) || other.serverName == serverName)&&(identical(other.finalizationState, finalizationState) || other.finalizationState == finalizationState)&&(identical(other.policies, policies) || other.policies == policies)&&(identical(other.addDeviceInfos, addDeviceInfos) || other.addDeviceInfos == addDeviceInfos)&&(identical(other.passphraseQuestion, passphraseQuestion) || other.passphraseQuestion == passphraseQuestion)&&(identical(other.publicClientKey, publicClientKey) || other.publicClientKey == publicClientKey)&&(identical(other.privateClientKey, privateClientKey) || other.privateClientKey == privateClientKey)&&(identical(other.sendPassphrase, sendPassphrase) || other.sendPassphrase == sendPassphrase));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,issuer,ttl,nonce,timestamp,serverUrl,serial,ecKeyAlgorithm,hashAlgorithm,sslVerify,serverName,finalizationState,policies,addDeviceInfos,passphraseQuestion,publicClientKey,privateClientKey,sendPassphrase);



}

/// @nodoc
abstract mixin class $TokenContainerUnfinalizedCopyWith<$Res> implements $TokenContainerCopyWith<$Res> {
  factory $TokenContainerUnfinalizedCopyWith(TokenContainerUnfinalized value, $Res Function(TokenContainerUnfinalized) _then) = _$TokenContainerUnfinalizedCopyWithImpl;
@override @useResult
$Res call({
 String issuer, Duration ttl, String nonce, DateTime timestamp, Uri serverUrl, String serial, EcKeyAlgorithm ecKeyAlgorithm, Algorithms hashAlgorithm, bool sslVerify, String serverName, FinalizationState finalizationState, ContainerPolicies policies, bool? addDeviceInfos, String? passphraseQuestion, String? publicClientKey, String? privateClientKey, bool sendPassphrase
});


@override $ContainerPoliciesCopyWith<$Res> get policies;

}
/// @nodoc
class _$TokenContainerUnfinalizedCopyWithImpl<$Res>
    implements $TokenContainerUnfinalizedCopyWith<$Res> {
  _$TokenContainerUnfinalizedCopyWithImpl(this._self, this._then);

  final TokenContainerUnfinalized _self;
  final $Res Function(TokenContainerUnfinalized) _then;

/// Create a copy of TokenContainer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? issuer = null,Object? ttl = null,Object? nonce = null,Object? timestamp = null,Object? serverUrl = null,Object? serial = null,Object? ecKeyAlgorithm = null,Object? hashAlgorithm = null,Object? sslVerify = null,Object? serverName = null,Object? finalizationState = null,Object? policies = null,Object? addDeviceInfos = freezed,Object? passphraseQuestion = freezed,Object? publicClientKey = freezed,Object? privateClientKey = freezed,Object? sendPassphrase = null,}) {
  return _then(TokenContainerUnfinalized(
issuer: null == issuer ? _self.issuer : issuer // ignore: cast_nullable_to_non_nullable
as String,ttl: null == ttl ? _self.ttl : ttl // ignore: cast_nullable_to_non_nullable
as Duration,nonce: null == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as Uri,serial: null == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String,ecKeyAlgorithm: null == ecKeyAlgorithm ? _self.ecKeyAlgorithm : ecKeyAlgorithm // ignore: cast_nullable_to_non_nullable
as EcKeyAlgorithm,hashAlgorithm: null == hashAlgorithm ? _self.hashAlgorithm : hashAlgorithm // ignore: cast_nullable_to_non_nullable
as Algorithms,sslVerify: null == sslVerify ? _self.sslVerify : sslVerify // ignore: cast_nullable_to_non_nullable
as bool,serverName: null == serverName ? _self.serverName : serverName // ignore: cast_nullable_to_non_nullable
as String,finalizationState: null == finalizationState ? _self.finalizationState : finalizationState // ignore: cast_nullable_to_non_nullable
as FinalizationState,policies: null == policies ? _self.policies : policies // ignore: cast_nullable_to_non_nullable
as ContainerPolicies,addDeviceInfos: freezed == addDeviceInfos ? _self.addDeviceInfos : addDeviceInfos // ignore: cast_nullable_to_non_nullable
as bool?,passphraseQuestion: freezed == passphraseQuestion ? _self.passphraseQuestion : passphraseQuestion // ignore: cast_nullable_to_non_nullable
as String?,publicClientKey: freezed == publicClientKey ? _self.publicClientKey : publicClientKey // ignore: cast_nullable_to_non_nullable
as String?,privateClientKey: freezed == privateClientKey ? _self.privateClientKey : privateClientKey // ignore: cast_nullable_to_non_nullable
as String?,sendPassphrase: null == sendPassphrase ? _self.sendPassphrase : sendPassphrase // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TokenContainer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerPoliciesCopyWith<$Res> get policies {
  
  return $ContainerPoliciesCopyWith<$Res>(_self.policies, (value) {
    return _then(_self.copyWith(policies: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class TokenContainerFinalized extends TokenContainer {
  const TokenContainerFinalized({required this.issuer, required this.nonce, required this.timestamp, required this.serverUrl, required this.serial, required this.ecKeyAlgorithm, required this.hashAlgorithm, required this.sslVerify, this.serverName = 'privacyIDEA', this.finalizationState = FinalizationState.completed, this.syncState = SyncState.notStarted, this.policies = ContainerPolicies.defaultSetting, this.initSynced = false, this.passphraseQuestion, required this.publicClientKey, required this.privateClientKey, final  String? $type}): $type = $type ?? 'finalized',super._();
  factory TokenContainerFinalized.fromJson(Map<String, dynamic> json) => _$TokenContainerFinalizedFromJson(json);

@override final  String issuer;
@override final  String nonce;
@override final  DateTime timestamp;
@override final  Uri serverUrl;
@override final  String serial;
@override final  EcKeyAlgorithm ecKeyAlgorithm;
@override final  Algorithms hashAlgorithm;
@override final  bool sslVerify;
@override@JsonKey() final  String serverName;
@override@JsonKey() final  FinalizationState finalizationState;
@JsonKey() final  SyncState syncState;
@override@JsonKey() final  ContainerPolicies policies;
@JsonKey() final  bool initSynced;
@override final  String? passphraseQuestion;
@override final  String publicClientKey;
@override final  String privateClientKey;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of TokenContainer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenContainerFinalizedCopyWith<TokenContainerFinalized> get copyWith => _$TokenContainerFinalizedCopyWithImpl<TokenContainerFinalized>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenContainerFinalizedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenContainerFinalized&&(identical(other.issuer, issuer) || other.issuer == issuer)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.ecKeyAlgorithm, ecKeyAlgorithm) || other.ecKeyAlgorithm == ecKeyAlgorithm)&&(identical(other.hashAlgorithm, hashAlgorithm) || other.hashAlgorithm == hashAlgorithm)&&(identical(other.sslVerify, sslVerify) || other.sslVerify == sslVerify)&&(identical(other.serverName, serverName) || other.serverName == serverName)&&(identical(other.finalizationState, finalizationState) || other.finalizationState == finalizationState)&&(identical(other.syncState, syncState) || other.syncState == syncState)&&(identical(other.policies, policies) || other.policies == policies)&&(identical(other.initSynced, initSynced) || other.initSynced == initSynced)&&(identical(other.passphraseQuestion, passphraseQuestion) || other.passphraseQuestion == passphraseQuestion)&&(identical(other.publicClientKey, publicClientKey) || other.publicClientKey == publicClientKey)&&(identical(other.privateClientKey, privateClientKey) || other.privateClientKey == privateClientKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,issuer,nonce,timestamp,serverUrl,serial,ecKeyAlgorithm,hashAlgorithm,sslVerify,serverName,finalizationState,syncState,policies,initSynced,passphraseQuestion,publicClientKey,privateClientKey);



}

/// @nodoc
abstract mixin class $TokenContainerFinalizedCopyWith<$Res> implements $TokenContainerCopyWith<$Res> {
  factory $TokenContainerFinalizedCopyWith(TokenContainerFinalized value, $Res Function(TokenContainerFinalized) _then) = _$TokenContainerFinalizedCopyWithImpl;
@override @useResult
$Res call({
 String issuer, String nonce, DateTime timestamp, Uri serverUrl, String serial, EcKeyAlgorithm ecKeyAlgorithm, Algorithms hashAlgorithm, bool sslVerify, String serverName, FinalizationState finalizationState, SyncState syncState, ContainerPolicies policies, bool initSynced, String? passphraseQuestion, String publicClientKey, String privateClientKey
});


@override $ContainerPoliciesCopyWith<$Res> get policies;

}
/// @nodoc
class _$TokenContainerFinalizedCopyWithImpl<$Res>
    implements $TokenContainerFinalizedCopyWith<$Res> {
  _$TokenContainerFinalizedCopyWithImpl(this._self, this._then);

  final TokenContainerFinalized _self;
  final $Res Function(TokenContainerFinalized) _then;

/// Create a copy of TokenContainer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? issuer = null,Object? nonce = null,Object? timestamp = null,Object? serverUrl = null,Object? serial = null,Object? ecKeyAlgorithm = null,Object? hashAlgorithm = null,Object? sslVerify = null,Object? serverName = null,Object? finalizationState = null,Object? syncState = null,Object? policies = null,Object? initSynced = null,Object? passphraseQuestion = freezed,Object? publicClientKey = null,Object? privateClientKey = null,}) {
  return _then(TokenContainerFinalized(
issuer: null == issuer ? _self.issuer : issuer // ignore: cast_nullable_to_non_nullable
as String,nonce: null == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as Uri,serial: null == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String,ecKeyAlgorithm: null == ecKeyAlgorithm ? _self.ecKeyAlgorithm : ecKeyAlgorithm // ignore: cast_nullable_to_non_nullable
as EcKeyAlgorithm,hashAlgorithm: null == hashAlgorithm ? _self.hashAlgorithm : hashAlgorithm // ignore: cast_nullable_to_non_nullable
as Algorithms,sslVerify: null == sslVerify ? _self.sslVerify : sslVerify // ignore: cast_nullable_to_non_nullable
as bool,serverName: null == serverName ? _self.serverName : serverName // ignore: cast_nullable_to_non_nullable
as String,finalizationState: null == finalizationState ? _self.finalizationState : finalizationState // ignore: cast_nullable_to_non_nullable
as FinalizationState,syncState: null == syncState ? _self.syncState : syncState // ignore: cast_nullable_to_non_nullable
as SyncState,policies: null == policies ? _self.policies : policies // ignore: cast_nullable_to_non_nullable
as ContainerPolicies,initSynced: null == initSynced ? _self.initSynced : initSynced // ignore: cast_nullable_to_non_nullable
as bool,passphraseQuestion: freezed == passphraseQuestion ? _self.passphraseQuestion : passphraseQuestion // ignore: cast_nullable_to_non_nullable
as String?,publicClientKey: null == publicClientKey ? _self.publicClientKey : publicClientKey // ignore: cast_nullable_to_non_nullable
as String,privateClientKey: null == privateClientKey ? _self.privateClientKey : privateClientKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of TokenContainer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerPoliciesCopyWith<$Res> get policies {
  
  return $ContainerPoliciesCopyWith<$Res>(_self.policies, (value) {
    return _then(_self.copyWith(policies: value));
  });
}
}

// dart format on
