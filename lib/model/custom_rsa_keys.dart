/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/asymmetric/api.dart';

part 'custom_rsa_keys.g.dart';

@JsonSerializable()
class SerializableRSAPublicKey extends RSAPublicKey {
  SerializableRSAPublicKey(BigInt modulus, BigInt exponent)
      : super(modulus, exponent);

  factory SerializableRSAPublicKey.fromJson(Map<String, dynamic> json) =>
      _$SerializableRSAPublicKeyFromJson(json);

  Map<String, dynamic> toJson() => _$SerializableRSAPublicKeyToJson(this);
}

@JsonSerializable()
class SerializableRSAPrivateKey extends RSAPrivateKey {
  SerializableRSAPrivateKey(BigInt modulus, BigInt exponent, BigInt p, BigInt q)
      : super(modulus, exponent, p, q);

  factory SerializableRSAPrivateKey.fromJson(Map<String, dynamic> json) =>
      _$SerializableRSAPrivateKeyFromJson(json);

  Map<String, dynamic> toJson() => _$SerializableRSAPrivateKeyToJson(this);
}
