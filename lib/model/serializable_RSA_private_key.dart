// ignore_for_file: file_names

import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/asymmetric/api.dart';

part 'serializable_RSA_private_key.g.dart';

@JsonSerializable()
class SerializableRSAPrivateKey extends RSAPrivateKey {
  SerializableRSAPrivateKey(super.modulus, super.exponent, BigInt super.p, BigInt super.q);

  factory SerializableRSAPrivateKey.fromJson(Map<String, dynamic> json) => _$SerializableRSAPrivateKeyFromJson(json);

  Map<String, dynamic> toJson() => _$SerializableRSAPrivateKeyToJson(this);
}
