// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenContainerUnfinalizedImpl _$$TokenContainerUnfinalizedImplFromJson(
        Map<String, dynamic> json) =>
    _$TokenContainerUnfinalizedImpl(
      issuer: json['issuer'] as String,
      ttl: Duration(microseconds: (json['ttl'] as num).toInt()),
      nonce: json['nonce'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      serverUrl: Uri.parse(json['serverUrl'] as String),
      serial: json['serial'] as String,
      ecKeyAlgorithm:
          $enumDecode(_$EcKeyAlgorithmEnumMap, json['ecKeyAlgorithm']),
      hashAlgorithm: $enumDecode(_$AlgorithmsEnumMap, json['hashAlgorithm']),
      sslVerify: json['sslVerify'] as bool,
      serverName: json['serverName'] as String? ?? 'privacyIDEA',
      finalizationState: $enumDecodeNullable(
              _$RolloutStateEnumMap, json['finalizationState']) ??
          RolloutState.completed,
      policies: json['policies'] == null
          ? ContainerPolicies.defaultSetting
          : ContainerPolicies.fromJson(
              json['policies'] as Map<String, dynamic>),
      addDeviceInfos: json['addDeviceInfos'] as bool?,
      passphraseQuestion: json['passphraseQuestion'] as String?,
      publicServerKey: json['publicServerKey'] as String?,
      publicClientKey: json['publicClientKey'] as String?,
      privateClientKey: json['privateClientKey'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TokenContainerUnfinalizedImplToJson(
        _$TokenContainerUnfinalizedImpl instance) =>
    <String, dynamic>{
      'issuer': instance.issuer,
      'ttl': instance.ttl.inMicroseconds,
      'nonce': instance.nonce,
      'timestamp': instance.timestamp.toIso8601String(),
      'serverUrl': instance.serverUrl.toString(),
      'serial': instance.serial,
      'ecKeyAlgorithm': _$EcKeyAlgorithmEnumMap[instance.ecKeyAlgorithm]!,
      'hashAlgorithm': _$AlgorithmsEnumMap[instance.hashAlgorithm]!,
      'sslVerify': instance.sslVerify,
      'serverName': instance.serverName,
      'finalizationState': _$RolloutStateEnumMap[instance.finalizationState]!,
      'policies': instance.policies,
      'addDeviceInfos': instance.addDeviceInfos,
      'passphraseQuestion': instance.passphraseQuestion,
      'publicServerKey': instance.publicServerKey,
      'publicClientKey': instance.publicClientKey,
      'privateClientKey': instance.privateClientKey,
      'runtimeType': instance.$type,
    };

const _$EcKeyAlgorithmEnumMap = {
  EcKeyAlgorithm.brainpoolp160r1: 'brainpoolp160r1',
  EcKeyAlgorithm.brainpoolp160t1: 'brainpoolp160t1',
  EcKeyAlgorithm.brainpoolp192r1: 'brainpoolp192r1',
  EcKeyAlgorithm.brainpoolp192t1: 'brainpoolp192t1',
  EcKeyAlgorithm.brainpoolp224r1: 'brainpoolp224r1',
  EcKeyAlgorithm.brainpoolp224t1: 'brainpoolp224t1',
  EcKeyAlgorithm.brainpoolp256r1: 'brainpoolp256r1',
  EcKeyAlgorithm.brainpoolp256t1: 'brainpoolp256t1',
  EcKeyAlgorithm.brainpoolp320r1: 'brainpoolp320r1',
  EcKeyAlgorithm.brainpoolp320t1: 'brainpoolp320t1',
  EcKeyAlgorithm.brainpoolp384r1: 'brainpoolp384r1',
  EcKeyAlgorithm.brainpoolp384t1: 'brainpoolp384t1',
  EcKeyAlgorithm.brainpoolp512r1: 'brainpoolp512r1',
  EcKeyAlgorithm.brainpoolp512t1: 'brainpoolp512t1',
  EcKeyAlgorithm.GostR3410_2001_CryptoPro_A: 'GostR3410_2001_CryptoPro_A',
  EcKeyAlgorithm.GostR3410_2001_CryptoPro_B: 'GostR3410_2001_CryptoPro_B',
  EcKeyAlgorithm.GostR3410_2001_CryptoPro_C: 'GostR3410_2001_CryptoPro_C',
  EcKeyAlgorithm.GostR3410_2001_CryptoPro_XchA: 'GostR3410_2001_CryptoPro_XchA',
  EcKeyAlgorithm.GostR3410_2001_CryptoPro_XchB: 'GostR3410_2001_CryptoPro_XchB',
  EcKeyAlgorithm.prime192v1: 'prime192v1',
  EcKeyAlgorithm.prime192v2: 'prime192v2',
  EcKeyAlgorithm.prime192v3: 'prime192v3',
  EcKeyAlgorithm.prime239v1: 'prime239v1',
  EcKeyAlgorithm.prime239v2: 'prime239v2',
  EcKeyAlgorithm.prime239v3: 'prime239v3',
  EcKeyAlgorithm.prime256v1: 'prime256v1',
  EcKeyAlgorithm.secp112r1: 'secp112r1',
  EcKeyAlgorithm.secp112r2: 'secp112r2',
  EcKeyAlgorithm.secp128r1: 'secp128r1',
  EcKeyAlgorithm.secp128r2: 'secp128r2',
  EcKeyAlgorithm.secp160k1: 'secp160k1',
  EcKeyAlgorithm.secp160r1: 'secp160r1',
  EcKeyAlgorithm.secp160r2: 'secp160r2',
  EcKeyAlgorithm.secp192k1: 'secp192k1',
  EcKeyAlgorithm.secp192r1: 'secp192r1',
  EcKeyAlgorithm.secp224k1: 'secp224k1',
  EcKeyAlgorithm.secp224r1: 'secp224r1',
  EcKeyAlgorithm.secp256k1: 'secp256k1',
  EcKeyAlgorithm.secp256r1: 'secp256r1',
  EcKeyAlgorithm.secp384r1: 'secp384r1',
  EcKeyAlgorithm.secp521r1: 'secp521r1',
};

const _$AlgorithmsEnumMap = {
  Algorithms.SHA1: 'SHA1',
  Algorithms.SHA256: 'SHA256',
  Algorithms.SHA512: 'SHA512',
};

const _$RolloutStateEnumMap = {
  RolloutState.notStarted: 'notStarted',
  RolloutState.generatingKeyPair: 'generatingKeyPair',
  RolloutState.generatingKeyPairFailed: 'generatingKeyPairFailed',
  RolloutState.generatingKeyPairCompleted: 'generatingKeyPairCompleted',
  RolloutState.sendingPublicKey: 'sendingPublicKey',
  RolloutState.sendingPublicKeyFailed: 'sendingPublicKeyFailed',
  RolloutState.sendingPublicKeyCompleted: 'sendingPublicKeyCompleted',
  RolloutState.parsingResponse: 'parsingResponse',
  RolloutState.parsingResponseFailed: 'parsingResponseFailed',
  RolloutState.parsingResponseCompleted: 'parsingResponseCompleted',
  RolloutState.completed: 'completed',
};

_$TokenContainerFinalizedImpl _$$TokenContainerFinalizedImplFromJson(
        Map<String, dynamic> json) =>
    _$TokenContainerFinalizedImpl(
      issuer: json['issuer'] as String,
      nonce: json['nonce'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      serverUrl: Uri.parse(json['serverUrl'] as String),
      serial: json['serial'] as String,
      ecKeyAlgorithm:
          $enumDecode(_$EcKeyAlgorithmEnumMap, json['ecKeyAlgorithm']),
      hashAlgorithm: $enumDecode(_$AlgorithmsEnumMap, json['hashAlgorithm']),
      sslVerify: json['sslVerify'] as bool,
      serverName: json['serverName'] as String? ?? 'privacyIDEA',
      finalizationState: $enumDecodeNullable(
              _$RolloutStateEnumMap, json['finalizationState']) ??
          RolloutState.completed,
      syncState: $enumDecodeNullable(_$SyncStateEnumMap, json['syncState']) ??
          SyncState.notStarted,
      policies: json['policies'] == null
          ? ContainerPolicies.defaultSetting
          : ContainerPolicies.fromJson(
              json['policies'] as Map<String, dynamic>),
      passphraseQuestion: json['passphraseQuestion'] as String?,
      publicServerKey: json['publicServerKey'] as String,
      publicClientKey: json['publicClientKey'] as String,
      privateClientKey: json['privateClientKey'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TokenContainerFinalizedImplToJson(
        _$TokenContainerFinalizedImpl instance) =>
    <String, dynamic>{
      'issuer': instance.issuer,
      'nonce': instance.nonce,
      'timestamp': instance.timestamp.toIso8601String(),
      'serverUrl': instance.serverUrl.toString(),
      'serial': instance.serial,
      'ecKeyAlgorithm': _$EcKeyAlgorithmEnumMap[instance.ecKeyAlgorithm]!,
      'hashAlgorithm': _$AlgorithmsEnumMap[instance.hashAlgorithm]!,
      'sslVerify': instance.sslVerify,
      'serverName': instance.serverName,
      'finalizationState': _$RolloutStateEnumMap[instance.finalizationState]!,
      'syncState': _$SyncStateEnumMap[instance.syncState]!,
      'policies': instance.policies,
      'passphraseQuestion': instance.passphraseQuestion,
      'publicServerKey': instance.publicServerKey,
      'publicClientKey': instance.publicClientKey,
      'privateClientKey': instance.privateClientKey,
      'runtimeType': instance.$type,
    };

const _$SyncStateEnumMap = {
  SyncState.notStarted: 'notStarted',
  SyncState.syncing: 'syncing',
  SyncState.completed: 'completed',
  SyncState.failed: 'failed',
};
