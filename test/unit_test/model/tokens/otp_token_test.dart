/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/token_template.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';

class MockOTPToken extends OTPToken {
  const MockOTPToken({
    required super.algorithm,
    required super.digits,
    required super.secret,
    required super.id,
    super.serial,
    super.label,
    super.type = 'MOCK',
    super.pin,
    super.isLocked,
    super.issuer,
  });

  @override
  String get otpValue => '123456';

  @override
  String get nextValue => '654321';

  @override
  Map<String, dynamic> toJson() => {
    ...toOtpAuthMap(),
    'algorithm': algorithm.name,
    'digits': digits,
    'secret': secret,
  };

  @override
  Token copyUpdateByTemplate(TokenTemplate template) => this;

  @override
  OTPToken copyWith({
    String? serial,
    String? label,
    String? issuer,
    String? Function()? containerSerial,
    List<String>? checkedContainer,
    String? id,
    Algorithms? algorithm,
    int? digits,
    String? secret,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
    String? tokenImage,
    int? sortIndex,
    int? Function()? folderId,
    TokenOriginData? origin,
    bool? isOffline,
    ForceBiometricOption? forceBiometricOption,
  }) {
    return MockOTPToken(
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      secret: secret ?? this.secret,
      id: id ?? this.id,
      serial: serial ?? this.serial,
      label: label ?? this.label,
      pin: pin ?? this.pin,
      isLocked: isLocked ?? this.isLocked,
      issuer: issuer ?? this.issuer,
    );
  }
}

void main() {
  group('OTPToken Static Validators', () {
    test('validateOtpAuthMap provides default SHA1 and 6 digits', () {
      final input = {OTPToken.SECRET_BASE32: 'JBSWY3DPEHPK3PXP'};
      final result = OTPToken.validateOtpAuthMap(input);
      expect(result[OTPToken.ALGORITHM], Algorithms.SHA1);
      expect(result[OTPToken.DIGITS], 6);
    });

    test('validateOtpAuthMap accepts explicit values', () {
      final input = {
        OTPToken.SECRET_BASE32: 'JBSWY3DPEHPK3PXP',
        OTPToken.ALGORITHM: 'SHA512',
        OTPToken.DIGITS: '8',
      };
      final result = OTPToken.validateOtpAuthMap(input);
      expect(result[OTPToken.ALGORITHM], Algorithms.SHA512);
      expect(result[OTPToken.DIGITS], 8);
    });
  });

  group('OTPToken Serialization & Template Logic', () {
    const token = MockOTPToken(
      algorithm: Algorithms.SHA256,
      digits: 8,
      secret: 'SECRET123',
      id: 'id_001',
      serial: 'SN_001',
      label: 'my_label',
    );

    test('toOtpAuthMap output types', () {
      final map = token.toOtpAuthMap();
      expect(map[OTPToken.ALGORITHM], isA<String>());
      expect(map[OTPToken.DIGITS], isA<String>());
      expect(map[OTPToken.ALGORITHM], 'SHA256');
    });

    test('OTP values are included in map only if serial is null', () {
      final withSerial = token.toOtpAuthMap();
      expect(withSerial.containsKey(OTPToken.OTP_VALUES), isFalse);

      final noSerial = token.copyWith(serial: null).toOtpAuthMap();
      expect(noSerial[OTPToken.OTP_VALUES], ['123456', '654321']);
    });

    test('toTemplate captures OTP values in otpAuthMap', () {
      final template = token.toTemplate();
      expect(template.otpAuthMap[OTPToken.OTP_VALUES], ['123456', '654321']);
    });

    test('toJson contains all required fields', () {
      final json = token.toJson();
      expect(json['algorithm'], 'SHA256');
      expect(json['digits'], 8);
      expect(json['secret'], 'SECRET123');
    });
  });

  group('OTPToken Identity Logic', () {
    const base = MockOTPToken(
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: 'S',
      id: '1',
    );

    test('isSameTokenAs matches by parameters if ID/Serial differ', () {
      const other = MockOTPToken(
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'S',
        id: 'different',
      );
      expect(base.isSameTokenAs(other), isTrue);
    });

    test('isSameTokenAs fails if secret differs', () {
      const other = MockOTPToken(
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'OTHER',
        id: '1',
      );
      expect(base.isSameTokenAs(other), isFalse);
    });

    test('isSameTokenAs fails if algorithm differs', () {
      const other = MockOTPToken(
        algorithm: Algorithms.SHA256,
        digits: 6,
        secret: 'S',
        id: '1',
      );
      expect(base.isSameTokenAs(other), isFalse);
    });
  });
}
