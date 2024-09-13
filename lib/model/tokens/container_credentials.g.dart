// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContainerCredentialUnfinalizedImpl
    _$$ContainerCredentialUnfinalizedImplFromJson(Map<String, dynamic> json) =>
        _$ContainerCredentialUnfinalizedImpl(
          issuer: json['issuer'] as String,
          nonce: json['nonce'] as String,
          timestamp: DateTime.parse(json['timestamp'] as String),
          finalizationUrl: Uri.parse(json['finalizationUrl'] as String),
          syncUrl: json['syncUrl'] == null
              ? null
              : Uri.parse(json['syncUrl'] as String),
          serial: json['serial'] as String,
          ecKeyAlgorithm:
              $enumDecode(_$EcKeyAlgorithmEnumMap, json['ecKeyAlgorithm']),
          hashAlgorithm:
              $enumDecode(_$AlgorithmsEnumMap, json['hashAlgorithm']),
          serverName: json['serverName'] as String? ?? 'privacyIDEA',
          finalizationState: $enumDecodeNullable(
                  _$ContainerFinalizationStateEnumMap,
                  json['finalizationState']) ??
              ContainerFinalizationState.uninitialized,
          passphraseQuestion: json['passphraseQuestion'] as String?,
          publicServerKey: json['publicServerKey'] as String?,
          publicClientKey: json['publicClientKey'] as String?,
          privateClientKey: json['privateClientKey'] as String?,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$ContainerCredentialUnfinalizedImplToJson(
        _$ContainerCredentialUnfinalizedImpl instance) =>
    <String, dynamic>{
      'issuer': instance.issuer,
      'nonce': instance.nonce,
      'timestamp': instance.timestamp.toIso8601String(),
      'finalizationUrl': instance.finalizationUrl.toString(),
      'syncUrl': instance.syncUrl?.toString(),
      'serial': instance.serial,
      'ecKeyAlgorithm': _$EcKeyAlgorithmEnumMap[instance.ecKeyAlgorithm]!,
      'hashAlgorithm': _$AlgorithmsEnumMap[instance.hashAlgorithm]!,
      'serverName': instance.serverName,
      'finalizationState':
          _$ContainerFinalizationStateEnumMap[instance.finalizationState]!,
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

const _$ContainerFinalizationStateEnumMap = {
  ContainerFinalizationState.uninitialized: 'uninitialized',
  ContainerFinalizationState.generatingKeyPair: 'generatingKeyPair',
  ContainerFinalizationState.generatingKeyPairFailed: 'generatingKeyPairFailed',
  ContainerFinalizationState.generatingKeyPairCompleted:
      'generatingKeyPairCompleted',
  ContainerFinalizationState.sendingPublicKey: 'sendingPublicKey',
  ContainerFinalizationState.sendingPublicKeyFailed: 'sendingPublicKeyFailed',
  ContainerFinalizationState.sendingPublicKeyCompleted:
      'sendingPublicKeyCompleted',
  ContainerFinalizationState.parsingResponse: 'parsingResponse',
  ContainerFinalizationState.parsingResponseFailed: 'parsingResponseFailed',
  ContainerFinalizationState.parsingResponseCompleted:
      'parsingResponseCompleted',
  ContainerFinalizationState.finalized: 'finalized',
};

_$ContainerCredentialFinalizedImpl _$$ContainerCredentialFinalizedImplFromJson(
        Map<String, dynamic> json) =>
    _$ContainerCredentialFinalizedImpl(
      issuer: json['issuer'] as String,
      nonce: json['nonce'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      syncUrl: Uri.parse(json['syncUrl'] as String),
      serial: json['serial'] as String,
      ecKeyAlgorithm:
          $enumDecode(_$EcKeyAlgorithmEnumMap, json['ecKeyAlgorithm']),
      hashAlgorithm: $enumDecode(_$AlgorithmsEnumMap, json['hashAlgorithm']),
      serverName: json['serverName'] as String? ?? 'privacyIDEA',
      finalizationState: $enumDecodeNullable(
              _$ContainerFinalizationStateEnumMap, json['finalizationState']) ??
          ContainerFinalizationState.finalized,
      passphraseQuestion: json['passphraseQuestion'] as String?,
      publicServerKey: json['publicServerKey'] as String,
      publicClientKey: json['publicClientKey'] as String,
      privateClientKey: json['privateClientKey'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ContainerCredentialFinalizedImplToJson(
        _$ContainerCredentialFinalizedImpl instance) =>
    <String, dynamic>{
      'issuer': instance.issuer,
      'nonce': instance.nonce,
      'timestamp': instance.timestamp.toIso8601String(),
      'syncUrl': instance.syncUrl.toString(),
      'serial': instance.serial,
      'ecKeyAlgorithm': _$EcKeyAlgorithmEnumMap[instance.ecKeyAlgorithm]!,
      'hashAlgorithm': _$AlgorithmsEnumMap[instance.hashAlgorithm]!,
      'serverName': instance.serverName,
      'finalizationState':
          _$ContainerFinalizationStateEnumMap[instance.finalizationState]!,
      'passphraseQuestion': instance.passphraseQuestion,
      'publicServerKey': instance.publicServerKey,
      'publicClientKey': instance.publicClientKey,
      'privateClientKey': instance.privateClientKey,
      'runtimeType': instance.$type,
    };
