// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializable_RSA_private_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableRSAPrivateKey _$SerializableRSAPrivateKeyFromJson(
        Map<String, dynamic> json) =>
    SerializableRSAPrivateKey(
      BigInt.parse(json['modulus'] as String),
      BigInt.parse(json['exponent'] as String),
      BigInt.parse(json['p'] as String),
      BigInt.parse(json['q'] as String),
    );

Map<String, dynamic> _$SerializableRSAPrivateKeyToJson(
        SerializableRSAPrivateKey instance) =>
    <String, dynamic>{
      'modulus': instance.modulus?.toString(),
      'exponent': instance.exponent?.toString(),
      'p': instance.p?.toString(),
      'q': instance.q?.toString(),
    };
