/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
import '../../enums/ec_key_algorithm.dart';

extension EcKeyAlgorithmList on List<EcKeyAlgorithm> {
  EcKeyAlgorithm byCurveName(String domainName) => switch (domainName) {
        'brainpoolp160r1' => EcKeyAlgorithm.brainpoolp160r1,
        'brainpoolp160t1' => EcKeyAlgorithm.brainpoolp160t1,
        'brainpoolp192r1' => EcKeyAlgorithm.brainpoolp192r1,
        'brainpoolp192t1' => EcKeyAlgorithm.brainpoolp192t1,
        'brainpoolp224r1' => EcKeyAlgorithm.brainpoolp224r1,
        'brainpoolp224t1' => EcKeyAlgorithm.brainpoolp224t1,
        'brainpoolp256r1' => EcKeyAlgorithm.brainpoolp256r1,
        'brainpoolp256t1' => EcKeyAlgorithm.brainpoolp256t1,
        'brainpoolp320r1' => EcKeyAlgorithm.brainpoolp320r1,
        'brainpoolp320t1' => EcKeyAlgorithm.brainpoolp320t1,
        'brainpoolp384r1' => EcKeyAlgorithm.brainpoolp384r1,
        'brainpoolp384t1' => EcKeyAlgorithm.brainpoolp384t1,
        'brainpoolp512r1' => EcKeyAlgorithm.brainpoolp512r1,
        'brainpoolp512t1' => EcKeyAlgorithm.brainpoolp512t1,
        'GostR3410-2001-CryptoPro-A' => EcKeyAlgorithm.GostR3410_2001_CryptoPro_A,
        'GostR3410-2001-CryptoPro-B' => EcKeyAlgorithm.GostR3410_2001_CryptoPro_B,
        'GostR3410-2001-CryptoPro-C' => EcKeyAlgorithm.GostR3410_2001_CryptoPro_C,
        'GostR3410-2001-CryptoPro-XchA' => EcKeyAlgorithm.GostR3410_2001_CryptoPro_XchA,
        'GostR3410-2001-CryptoPro-XchB' => EcKeyAlgorithm.GostR3410_2001_CryptoPro_XchB,
        'prime192v1' => EcKeyAlgorithm.prime192v1,
        'prime192v2' => EcKeyAlgorithm.prime192v2,
        'prime192v3' => EcKeyAlgorithm.prime192v3,
        'prime239v1' => EcKeyAlgorithm.prime239v1,
        'prime239v2' => EcKeyAlgorithm.prime239v2,
        'prime239v3' => EcKeyAlgorithm.prime239v3,
        'prime256v1' => EcKeyAlgorithm.prime256v1,
        'secp112r1' => EcKeyAlgorithm.secp112r1,
        'secp112r2' => EcKeyAlgorithm.secp112r2,
        'secp128r1' => EcKeyAlgorithm.secp128r1,
        'secp128r2' => EcKeyAlgorithm.secp128r2,
        'secp160k1' => EcKeyAlgorithm.secp160k1,
        'secp160r1' => EcKeyAlgorithm.secp160r1,
        'secp160r2' => EcKeyAlgorithm.secp160r2,
        'secp192k1' => EcKeyAlgorithm.secp192k1,
        'secp192r1' => EcKeyAlgorithm.secp192r1,
        'secp224k1' => EcKeyAlgorithm.secp224k1,
        'secp224r1' => EcKeyAlgorithm.secp224r1,
        'secp256k1' => EcKeyAlgorithm.secp256k1,
        'secp256r1' => EcKeyAlgorithm.secp256r1,
        'secp384r1' => EcKeyAlgorithm.secp384r1,
        'secp521r1' => EcKeyAlgorithm.secp521r1,
        _ => throw ArgumentError('Unknown domain name: $domainName'),
      };
}

extension EcKeyAlgorithmX on EcKeyAlgorithm {
  String get curveName => switch (this) {
        EcKeyAlgorithm.brainpoolp160r1 => 'brainpoolp160r1',
        EcKeyAlgorithm.brainpoolp160t1 => 'brainpoolp160t1',
        EcKeyAlgorithm.brainpoolp192r1 => 'brainpoolp192r1',
        EcKeyAlgorithm.brainpoolp192t1 => 'brainpoolp192t1',
        EcKeyAlgorithm.brainpoolp224r1 => 'brainpoolp224r1',
        EcKeyAlgorithm.brainpoolp224t1 => 'brainpoolp224t1',
        EcKeyAlgorithm.brainpoolp256r1 => 'brainpoolp256r1',
        EcKeyAlgorithm.brainpoolp256t1 => 'brainpoolp256t1',
        EcKeyAlgorithm.brainpoolp320r1 => 'brainpoolp320r1',
        EcKeyAlgorithm.brainpoolp320t1 => 'brainpoolp320t1',
        EcKeyAlgorithm.brainpoolp384r1 => 'brainpoolp384r1',
        EcKeyAlgorithm.brainpoolp384t1 => 'brainpoolp384t1',
        EcKeyAlgorithm.brainpoolp512r1 => 'brainpoolp512r1',
        EcKeyAlgorithm.brainpoolp512t1 => 'brainpoolp512t1',
        EcKeyAlgorithm.GostR3410_2001_CryptoPro_A => 'GostR3410-2001-CryptoPro-A',
        EcKeyAlgorithm.GostR3410_2001_CryptoPro_B => 'GostR3410-2001-CryptoPro-B',
        EcKeyAlgorithm.GostR3410_2001_CryptoPro_C => 'GostR3410-2001-CryptoPro-C',
        EcKeyAlgorithm.GostR3410_2001_CryptoPro_XchA => 'GostR3410-2001-CryptoPro-XchA',
        EcKeyAlgorithm.GostR3410_2001_CryptoPro_XchB => 'GostR3410-2001-CryptoPro-XchB',
        EcKeyAlgorithm.prime192v1 => 'prime192v1',
        EcKeyAlgorithm.prime192v2 => 'prime192v2',
        EcKeyAlgorithm.prime192v3 => 'prime192v3',
        EcKeyAlgorithm.prime239v1 => 'prime239v1',
        EcKeyAlgorithm.prime239v2 => 'prime239v2',
        EcKeyAlgorithm.prime239v3 => 'prime239v3',
        EcKeyAlgorithm.prime256v1 => 'prime256v1',
        EcKeyAlgorithm.secp112r1 => 'secp112r1',
        EcKeyAlgorithm.secp112r2 => 'secp112r2',
        EcKeyAlgorithm.secp128r1 => 'secp128r1',
        EcKeyAlgorithm.secp128r2 => 'secp128r2',
        EcKeyAlgorithm.secp160k1 => 'secp160k1',
        EcKeyAlgorithm.secp160r1 => 'secp160r1',
        EcKeyAlgorithm.secp160r2 => 'secp160r2',
        EcKeyAlgorithm.secp192k1 => 'secp192k1',
        EcKeyAlgorithm.secp192r1 => 'secp192r1',
        EcKeyAlgorithm.secp224k1 => 'secp224k1',
        EcKeyAlgorithm.secp224r1 => 'secp224r1',
        EcKeyAlgorithm.secp256k1 => 'secp256k1',
        EcKeyAlgorithm.secp256r1 => 'secp256r1',
        EcKeyAlgorithm.secp384r1 => 'secp384r1',
        EcKeyAlgorithm.secp521r1 => 'secp521r1',
      };
}
