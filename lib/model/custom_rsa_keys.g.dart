// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_rsa_keys.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableRSAPublicKey _$SerializableRSAPublicKeyFromJson(
    Map<String, dynamic> json) {
  return SerializableRSAPublicKey(
      json['modulus'] == null ? null : BigInt.parse(json['modulus'] as String),
      json['exponent'] == null
          ? null
          : BigInt.parse(json['exponent'] as String));
}

Map<String, dynamic> _$SerializableRSAPublicKeyToJson(
        SerializableRSAPublicKey instance) =>
    <String, dynamic>{
      'modulus': instance.modulus?.toString(),
      'exponent': instance.exponent?.toString()
    };

SerializableRSAPrivateKey _$SerializableRSAPrivateKeyFromJson(
    Map<String, dynamic> json) {
  return SerializableRSAPrivateKey(
      json['modulus'] == null ? null : BigInt.parse(json['modulus'] as String),
      json['exponent'] == null
          ? null
          : BigInt.parse(json['exponent'] as String),
      json['p'] == null ? null : BigInt.parse(json['p'] as String),
      json['q'] == null ? null : BigInt.parse(json['q'] as String));
}

Map<String, dynamic> _$SerializableRSAPrivateKeyToJson(
        SerializableRSAPrivateKey instance) =>
    <String, dynamic>{
      'modulus': instance.modulus?.toString(),
      'exponent': instance.exponent?.toString(),
      'p': instance.p?.toString(),
      'q': instance.q?.toString()
    };
