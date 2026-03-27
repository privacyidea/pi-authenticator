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

class FakeOTPToken extends OTPToken {
  final String _testOtpValue;
  final String _testNextValue;

  const FakeOTPToken({
    required super.algorithm,
    required super.digits,
    required super.secret,
    required super.id,
    super.serial,
    super.label,
    super.type = 'FAKE',
    super.pin,
    super.isLocked,
    super.issuer,
    String otpValue = '123456',
    String nextValue = '654321',
  }) : _testOtpValue = otpValue,
       _testNextValue = nextValue;

  @override
  String get otpValue => _testOtpValue;

  @override
  String get nextValue => _testNextValue;

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
    String? Function()? serial,
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
    String? otpValue,
    String? nextValue,
  }) {
    final String? newSerial = serial?.call();

    return FakeOTPToken(
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      secret: secret ?? this.secret,
      id: id ?? this.id,
      serial: serial != null ? newSerial : this.serial,
      label: label ?? this.label,
      pin: pin ?? this.pin,
      isLocked: isLocked ?? this.isLocked,
      issuer: issuer ?? this.issuer,
      otpValue: otpValue ?? this.otpValue,
      nextValue: nextValue ?? this.nextValue,
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
    const token = FakeOTPToken(
      algorithm: Algorithms.SHA256,
      digits: 8,
      secret: 'SECRET123',
      id: 'id_001',
      serial: 'SN_001',
      label: 'my_label',
    );

    test('toOtpAuthMap output types and values', () {
      final map = token.toOtpAuthMap();
      expect(map[OTPToken.ALGORITHM], 'SHA256');
      expect(map[OTPToken.DIGITS], '8');
      expect(map[OTPToken.ALGORITHM], isA<String>());
    });

    test(
      'toTemplate captures serial and excludes OTP values when serial is present',
      () {
        final template = token.toTemplate();
        expect(template.serial, 'SN_001');
        expect(template.otpAuthMap.containsKey(OTPToken.OTP_VALUES), isFalse);
      },
    );

    test(
      'toTemplate captures OTP values and has null serial when serial is absent',
      () {
        final tokenWithoutSerial = token.copyWith(serial: () => null);
        final template = tokenWithoutSerial.toTemplate();
        expect(template.serial, isNull);
        expect(template.otpAuthMap[OTPToken.OTP_VALUES], ['123456', '654321']);
      },
    );

    test('toJson contains all required fields', () {
      final json = token.toJson();
      expect(json['algorithm'], 'SHA256');
      expect(json['digits'], 8);
      expect(json['secret'], 'SECRET123');
    });
  });

  group('OTPToken Identity Logic', () {
    const base = FakeOTPToken(
      id: '1',
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: 'secret',
      issuer: "issuer",
      label: "label",
      serial: "serial",
      isLocked: true,
      pin: true,
    );

    test('isSameTokenAs should match when id is the same', () {
      const other = FakeOTPToken(
        id: '1',
        serial: "different_serial",
        issuer: "different_issuer",
        algorithm: Algorithms.SHA256,
        digits: 8,
        secret: 'different_secret',
        label: "different_label",
        isLocked: false,
        pin: false,
      );
      expect(base.isSameTokenAs(other), isTrue);
    });

    group("isSameTokenAs with different id", () {
      test('isSameTokenAs should match when serial AND issuer is the same', () {
        final other1 = base.copyWith(
          id: '2', // same id = same token
          serial: () => "serial",
          issuer: "issuer",
        );
        final other2 = base.copyWith(id: '2', serial: () => "different_serial");
        final other3 = base.copyWith(id: '2', issuer: "different_issuer");
        expect(base.isSameTokenAs(other1), isTrue);
        expect(base.isSameTokenAs(other2), isFalse);
        expect(base.isSameTokenAs(other3), isFalse);
      });

      test(
        'isSameTokenAs should not match when secret, algorithm or digits differs',
        () {
          final other1 = base.copyWith(
            id: '2', // same id = same token
            issuer: "different_issuer", // same serial & issuer = same token
            secret: 'different_secret',
          );
          final other2 = base.copyWith(
            id: '2',
            issuer: "different_issuer",
            algorithm: Algorithms.SHA256,
          );
          final other3 = base.copyWith(
            id: '2',
            issuer: "different_issuer",
            digits: 8,
          );

          expect(base.isSameTokenAs(other1), isFalse);
          expect(base.isSameTokenAs(other2), isFalse);
          expect(base.isSameTokenAs(other3), isFalse);
        },
      );

      test(
        'isSameTokenAs should not be determined when only other properties differ',
        () {
          final other = base.copyWith(
            id: '2', // same id = same token
            label: "different_label",
            isLocked: false,
            pin: false,
          );
          expect(base.isSameTokenAs(other), isNull);
        },
      );
    });
  });
}
