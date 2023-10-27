// ignore_for_file: file_names

import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/asymmetric/api.dart';

part 'serializable_RSA_public_key.g.dart';

@JsonSerializable()
class SerializableRSAPublicKey extends RSAPublicKey {
  SerializableRSAPublicKey(super.modulus, super.exponent);

  factory SerializableRSAPublicKey.fromJson(Map<String, dynamic> json) => _$SerializableRSAPublicKeyFromJson(json);

  Map<String, dynamic> toJson() => _$SerializableRSAPublicKeyToJson(this);
}
