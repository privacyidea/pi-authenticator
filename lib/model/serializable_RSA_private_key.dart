import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/asymmetric/api.dart';

part 'serializable_RSA_private_key.g.dart';

@JsonSerializable()
class SerializableRSAPrivateKey extends RSAPrivateKey {
  SerializableRSAPrivateKey(BigInt modulus, BigInt exponent, BigInt p, BigInt q) : super(modulus, exponent, p, q);

  factory SerializableRSAPrivateKey.fromJson(Map<String, dynamic> json) => _$SerializableRSAPrivateKeyFromJson(json);

  Map<String, dynamic> toJson() => _$SerializableRSAPrivateKeyToJson(this);
}
