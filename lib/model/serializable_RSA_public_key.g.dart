// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializable_RSA_public_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableRSAPublicKey _$SerializableRSAPublicKeyFromJson(
        Map<String, dynamic> json) =>
    SerializableRSAPublicKey(
      BigInt.parse(json['modulus'] as String),
      BigInt.parse(json['exponent'] as String),
    );

Map<String, dynamic> _$SerializableRSAPublicKeyToJson(
        SerializableRSAPublicKey instance) =>
    <String, dynamic>{
      'modulus': instance.modulus?.toString(),
      'exponent': instance.exponent?.toString(),
    };
