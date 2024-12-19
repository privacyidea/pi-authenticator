/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter/foundation.dart';

class AesEncrypted {
  // [KdfAlgorithm/MacAlgorithm/Iterations/Bits]
  static const Map<String, dynamic> defaultKdfSettings = {
    'algorithm': 'PBKDF2',
    'macAlgorithm': 'HmacSHA256',
    'iterations': 100000,
    'bits': 256,
  };
  static final defaultMacAlgorithm = Hmac.sha256();
  static const defaultIterations = 100000;
  static const defaultBits = 256;
  // Key derivation
  final KdfAlgorithm kdf;
  final Uint8List salt;

  // Encryption
  final Uint8List data;
  final Uint8List iv;
  final Mac mac;
  // final String? padding;

  final Cipher cypher;

  const AesEncrypted._({
    required this.kdf,
    required this.salt,
    required this.data,
    required this.iv,
    required this.mac,
    required this.cypher,
  });

  /// If mac is not provided, it will be extracted from the last 16 bytes of the data
  /// This is the default of AES encryption.
  factory AesEncrypted({
    required Uint8List data,
    required Uint8List salt,
    required Uint8List iv,
    Mac? mac,
    required KdfAlgorithm kdf,
    required Cipher cypher,
  }) {
    if (mac == null) {
      mac = Mac(data.sublist(data.length - 16, data.length));
      data = data.sublist(0, data.length - 16);
    }
    return AesEncrypted._(mac: mac, kdf: kdf, cypher: cypher, salt: salt, iv: iv, data: data);
  }

  /// Encrypts the data using AES-GCM with 256 bits.
  /// Iterations are set to 100,000 (one hundred thousand).
  /// The password is used to derive the key using PBKDF2.
  /// When the salt or iv is not provided, it is generated randomly. (16 bytes each)
  /// The mac is calculated by the cypher.
  /// The data is concatenated with the iv and mac.
  /// The result is returned as an AesEncrypted object.
  static Future<AesEncrypted> encrypt({
    required String data,
    required String password,
    Uint8List? salt,
    Uint8List? iv,
  }) async {
    final plainBytes = utf8.encode(data);
    final cypher = AesGcm.with256bits();
    final kdf = Pbkdf2(
      macAlgorithm: defaultMacAlgorithm,
      iterations: defaultIterations,
      bits: defaultBits,
    );
    salt ??= Uint8List.fromList(List.generate(16, (index) => Random.secure().nextInt(256)));
    iv ??= Uint8List.fromList(List.generate(16, (index) => Random.secure().nextInt(256)));
    final secretKey = await kdf.deriveKeyFromPassword(password: password, nonce: salt);
    final secretBox = await cypher.encrypt(plainBytes, secretKey: secretKey, nonce: iv);
    final encryptedData = secretBox.concatenation(nonce: false, mac: false);
    return AesEncrypted._(
      cypher: cypher,
      kdf: kdf,
      salt: salt,
      iv: iv,
      data: encryptedData,
      mac: secretBox.mac,
    );
  }

  Future<Uint8List> decrypt(String password) async {
    final SecretKey secretKey = await _deriveKey(password);
    final SecretBox secretBox = SecretBox(data, nonce: iv, mac: mac);
    final decrypted = await cypher.decrypt(secretBox, secretKey: secretKey);
    return Uint8List.fromList(decrypted);
  }

  Future<String> decryptToString(String password) async {
    final decrypted = await decrypt(password);
    return utf8.decode(decrypted);
  }

  Future<SecretKey> _deriveKey(String password) async {
    return await kdf.deriveKeyFromPassword(password: password, nonce: salt);
  }

  static AesEncrypted fromJson(Map<String, dynamic> json) {
    return AesEncrypted(
      data: base64Decode(json['data']),
      salt: base64Decode(json['salt']),
      iv: base64Decode(json['iv']),
      mac: Mac(base64Decode(json['mac'])),
      kdf: KdfAlgorithmX.fromJson(json['kdf']),
      cypher: CipherX.fromJson(json['cypher']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': base64Encode(data),
      'salt': base64Encode(salt),
      'iv': base64Encode(iv),
      'mac': base64Encode(mac.bytes),
      'kdf': kdf.toJson(),
      'cypher': cypher.toJson(),
    };
  }
}

/* ////////////////////////////////////////////////////////////////////////////////////
///////////////////////////// SERIALIZATION EXTENSIONS ////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////// */

extension MacAlgorithmX on MacAlgorithm {
  static MacAlgorithm fromJson(Map<String, dynamic> json) {
    final algorithm = json['algorithm'];
    return switch (algorithm) {
      'Hmac' => HmacX.fromJson(json),
      _ => throw UnsupportedError('Unsupported MAC algorithm: $algorithm'),
    };
  }

  Map<String, dynamic> toJson() => switch (runtimeType) {
        const (DartHmac) => (this as DartHmac).toJson(),
        _ => throw UnsupportedError('Unsupported MAC algorithm: $this'),
      };
}

extension HmacX on Hmac {
  static Hmac fromJson(Map<String, dynamic> json) {
    final hashAlgorithm = HashAlgorithmX.fromJson(json['hashAlgorithm']);
    return Hmac(hashAlgorithm);
  }

  Map<String, dynamic> toJson() => {
        'algorithm': 'Hmac',
        'hashAlgorithm': hashAlgorithm.toJson(),
      };
}

extension HashAlgorithmX on HashAlgorithm {
  static HashAlgorithm fromJson(Map<String, dynamic> json) {
    final algorithm = json['algorithm'];
    return switch (algorithm) {
      'DartSha256' => const DartSha256(),
      'DartSha512' => const DartSha512(),
      _ => throw UnsupportedError('Unsupported hash algorithm: $algorithm'),
    };
  }

  Map<String, dynamic> toJson() => {
        'algorithm': runtimeType.toString(),
      };
}

extension KdfAlgorithmX on KdfAlgorithm {
  static KdfAlgorithm fromJson(Map<String, dynamic> json) {
    final algorithm = json['algorithm'];
    return switch (algorithm) {
      'Pbkdf2' => Pbkdf2X.fromJson(json),
      _ => throw UnsupportedError('Unsupported KDF algorithm: $algorithm'),
    };
  }

  Map<String, dynamic> toJson() => switch (runtimeType) {
        const (DartPbkdf2) => (this as DartPbkdf2).toJson(),
        _ => throw UnsupportedError('Unsupported KDF algorithm: $this'),
      };
}

extension Pbkdf2X on Pbkdf2 {
  static Pbkdf2 fromJson(Map<String, dynamic> json) {
    final macAlgorithm = MacAlgorithmX.fromJson(json['macAlgorithm']);
    final iterations = json['iterations'] as int;
    final bits = json['bits'] as int;
    return Pbkdf2(
      macAlgorithm: macAlgorithm,
      iterations: iterations,
      bits: bits,
    );
  }

  Map<String, dynamic> toJson() => {
        'algorithm': 'Pbkdf2',
        'macAlgorithm': macAlgorithm.toJson(),
        'iterations': iterations,
        'bits': bits,
      };
}

extension CipherX on Cipher {
  static Cipher fromJson(Map<String, dynamic> json) {
    final algorithm = json['algorithm'];
    return switch (algorithm) {
      'AesGcm' => AesGcmX.fromJson(json),
      'AesCbc' => AesCbcX.fromJson(json),
      _ => throw UnsupportedError('Unsupported cipher algorithm: $algorithm'),
    };
  }

  Map<String, dynamic> toJson() => switch (runtimeType) {
        const (DartAesGcm) => (this as DartAesGcm).toJson(),
        const (DartAesCbc) => (this as DartAesCbc).toJson(),
        _ => throw UnsupportedError('Unsupported cipher algorithm: $this'),
      };
}

extension AesGcmX on AesGcm {
  static AesGcm fromJson(Map<String, dynamic> json) {
    final secretKeyLength = json['secretKeyLength'];
    return switch (secretKeyLength) {
      16 => AesGcm.with128bits(),
      24 => AesGcm.with192bits(),
      32 => AesGcm.with256bits(),
      _ => throw UnsupportedError('Unsupported secret key length: $secretKeyLength'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'algorithm': 'AesGcm',
      'secretKeyLength': secretKeyLength,
    };
  }
}

extension AesCbcX on AesCbc {
  static AesCbc fromJson(Map<String, dynamic> json) {
    final secretKeyLength = json['secretKeyLength'];
    final macAlgorithm = json['macAlgorithm'] != null ? MacAlgorithmX.fromJson(json['macAlgorithm']) : Hmac.sha256();
    final paddingAlgorithm = json['paddingAlgorithm'] != null ? PaddingAlgorithmX.fromString(json['paddingAlgorithm']) : PaddingAlgorithm.pkcs7;
    return switch (secretKeyLength) {
      16 => AesCbc.with128bits(macAlgorithm: macAlgorithm, paddingAlgorithm: paddingAlgorithm),
      24 => AesCbc.with192bits(macAlgorithm: macAlgorithm, paddingAlgorithm: paddingAlgorithm),
      32 => AesCbc.with256bits(macAlgorithm: macAlgorithm, paddingAlgorithm: paddingAlgorithm),
      _ => throw UnsupportedError('Unsupported secret key length: $secretKeyLength'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'algorithm': 'AesCbc',
      'secretKeyLength': secretKeyLength,
      'macAlgorithm': macAlgorithm.toString(),
      'paddingAlgorithm': paddingAlgorithm.toString(),
    };
  }
}

extension PaddingAlgorithmX on PaddingAlgorithm {
  static PaddingAlgorithm fromString(String string) {
    return switch (string) {
      'PaddingAlgorithm.pkcs7' => PaddingAlgorithm.pkcs7,
      'PaddingAlgorithm.zero' => PaddingAlgorithm.zero,
      _ => throw UnsupportedError('Unsupported padding algorithm: $string')
    };
  }
}
