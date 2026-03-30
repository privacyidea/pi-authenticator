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
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/token_template.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';

class FakeToken extends Token {
  const FakeToken({
    required super.id,
    required super.type,
    super.serial,
    super.label,
    super.issuer,
    super.pin,
    super.isLocked,
    super.isHidden,
    super.forceBiometricOption,
    super.tokenImage,
    super.sortIndex,
    super.isOffline,
    super.checkedContainer,
    super.folderId,
    super.origin,
    super.containerSerial,
  });

  @override
  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'serial': serial};

  @override
  Token copyUpdateByTemplate(TokenTemplate template) => this;

  @override
  Token copyWith({
    String? Function()? serial,
    String? label,
    String? issuer,
    String? Function()? containerSerial,
    List<String>? checkedContainer,
    String? id,
    bool? isLocked,
    bool? isHidden,
    bool? pin,
    String? tokenImage,
    int? sortIndex,
    int? Function()? folderId,
    TokenOriginData? origin,
    bool? isOffline,
    ForceBiometricOption? forceBiometricOption,
  }) {
    return FakeToken(
      id: id ?? this.id,
      type: type,
      serial: serial != null ? serial() : this.serial,
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      pin: pin ?? this.pin,
      isLocked: isLocked ?? this.isLocked,
      isHidden: isHidden ?? this.isHidden,
      forceBiometricOption: forceBiometricOption ?? this.forceBiometricOption,
      tokenImage: tokenImage ?? this.tokenImage,
      sortIndex: sortIndex ?? this.sortIndex,
      isOffline: isOffline ?? this.isOffline,
      checkedContainer: checkedContainer ?? this.checkedContainer,
      folderId: folderId != null ? folderId() : this.folderId,
      origin: origin ?? this.origin,
      containerSerial: containerSerial != null
          ? containerSerial()
          : this.containerSerial,
    );
  }
}

void main() {
  group('Token Constants & Validators', () {
    test('Verify static string constants for persistence and UI', () {
      expect(Token.PIN_VALUE_TRUE, 'True');
      expect(Token.PIN_VALUE_FALSE, 'False');
      expect(Token.TOKENTYPE_OTPAUTH, 'tokentype');
      expect(Token.TOKENTYPE_JSON, 'type');
      expect(Token.FORCE_BIOMETRIC_OPTION, 'app_force_unlock');
    });

    test('validateOtpAuthMap ensures all base fields have defaults', () {
      final result = Token.validateOtpAuthMap({});
      expect(result[Token.LABEL], '');
      expect(result[Token.ISSUER], '');
      expect(result[Token.OFFLINE], false);
      expect(result[Token.FORCE_BIOMETRIC_OPTION], ForceBiometricOption.none);
    });

    test('validateAdditionalData ensures list and optional field handling', () {
      final result = Token.validateAdditionalData({});
      expect(result[Token.CHECKED_CONTAINERS], []);
      expect(result[Token.ID], isNull);
      expect(result[Token.SORT_INDEX], isNull);
    });
  });

  group('Token State Logic: isLocked & isHidden corners', () {
    test(
      'isLocked returns true if PIN is required regardless of internal state',
      () {
        const t = FakeToken(id: '1', type: 'T', pin: true, isLocked: false);
        expect(t.isLocked, isTrue);
      },
    );

    test('isLocked returns true if Biometrics are forced', () {
      final t = FakeToken(
        id: '1',
        type: 'T',
        forceBiometricOption: ForceBiometricOption.biometric,
        isLocked: false,
      );
      expect(t.isLocked, isTrue);
    });

    test(
      'isLocked returns false only if PIN, Biometrics, and _isLocked are all false',
      () {
        const t = FakeToken(id: '1', type: 'T', pin: false, isLocked: false);
        expect(t.isLocked, isFalse);
      },
    );

    test('isHidden defaults to isLocked value when not specified', () {
      const locked = FakeToken(id: '1', type: 'T', isLocked: true);
      const unlocked = FakeToken(id: '2', type: 'T', isLocked: false);
      expect(locked.isHidden, isTrue);
      expect(unlocked.isHidden, isFalse);
    });

    test(
      'isHidden can be false while isLocked is true (explicit override)',
      () {
        const t = FakeToken(
          id: '1',
          type: 'T',
          isLocked: true,
          isHidden: false,
        );
        expect(t.isLocked, isTrue);
        expect(t.isHidden, isFalse);
      },
    );
  });

  group('Token Identity Logic', () {
    const base = FakeToken(
      id: '1',
      type: 'FAKE',
      serial: 'serial',
      issuer: 'issuer',
      label: 'label',
      isLocked: true,
      pin: true,
    );

    test('isSameTokenAs matches when id is the same', () {
      const other = FakeToken(
        id: '1',
        type: 'OTHER',
        serial: 'different_serial',
        issuer: 'different_issuer',
      );
      expect(base.isSameTokenAs(other), isTrue);
    });

    group('isSameTokenAs with different id', () {
      test('matches when serial AND issuer are the same', () {
        final other1 = base.copyWith(
          id: '2',
          serial: () => 'serial',
          issuer: 'issuer',
        );
        final other2 = base.copyWith(id: '2', serial: () => 'different_serial');
        final other3 = base.copyWith(id: '2', issuer: 'different_issuer');

        expect(base.isSameTokenAs(other1), isTrue);
        expect(base.isSameTokenAs(other2), isFalse);
        expect(base.isSameTokenAs(other3), isFalse);
      });

      test('returns null if IDs differ and serials are null', () {
        final t1 = base.copyWith(id: '1', serial: () => null);
        final t2 = base.copyWith(id: '2', serial: () => null);
        expect(t1.isSameTokenAs(t2), isNull);
      });

      test('should not be determined when only UI properties differ', () {
        final baseNoSerial = base.copyWith(
          id: '1',
          // have to nullify serial to reach the UI properties check
          serial: () => null,
        );
        final other = base.copyWith(
          id: '2',
          serial: () => null,
          label: 'different_label',
          isLocked: false,
          pin: false,
        );
        expect(baseNoSerial.isSameTokenAs(other), isNull);
      });
    });

    test('Operator == strictly compares ID', () {
      const t1 = FakeToken(id: 'ID-A', type: 'HOTP');
      const t2 = FakeToken(id: 'ID-A', type: 'TOTP');
      const t3 = FakeToken(id: 'ID-B', type: 'HOTP');

      expect(t1 == t2, isTrue);
      expect(t1 == t3, isFalse);
    });
  });

  group('Token Serialization & Template corner cases', () {
    test(
      'toOtpAuthMap transforms PIN bool to proprietary True/False strings',
      () {
        const tTrue = FakeToken(id: '1', type: 'T', pin: true);
        const tFalse = FakeToken(id: '1', type: 'T', pin: false);
        expect(tTrue.toOtpAuthMap()[Token.PIN], 'True');
        expect(tFalse.toOtpAuthMap()[Token.PIN], 'False');
      },
    );

    test('additionalData exports all internal fields', () {
      const t = FakeToken(
        id: 'uid',
        type: 'T',
        sortIndex: 5,
        folderId: 10,
        checkedContainer: ['C1', 'C2'],
        containerSerial: 'CONT-SN',
      );
      final data = t.additionalData;
      expect(data[Token.ID], 'uid');
      expect(data[Token.SORT_INDEX], 5);
      expect(data[Token.FOLDER_ID], 10);
      expect(data[Token.CHECKED_CONTAINERS], ['C1', 'C2']);
      expect(data[Token.CONTAINER_SERIAL], 'CONT-SN');
    });

    test('toTemplate captures correct state only when serial is present', () {
      const tWith = FakeToken(id: '1', type: 'T', serial: 'SN-123');
      const tWithout = FakeToken(id: '2', type: 'T');

      expect(tWith.toTemplate(), isNotNull);
      expect(tWith.toTemplate()?.serial, 'SN-123');
      expect(tWithout.toTemplate(), isNull);
    });
  });

  group('Token Factory Dispatch Error Handling', () {
    test('fromJson throws ArgumentError on missing type key', () {
      expect(() => Token.fromJson({}), throwsArgumentError);
    });

    test('fromJson throws ArgumentError on unsupported type name', () {
      expect(
        () => Token.fromJson({'type': 'INVALID_TYPE'}),
        throwsArgumentError,
      );
    });

    test('fromOtpAuthMap throws ArgumentError on missing tokentype key', () {
      expect(() => Token.fromOtpAuthMap({}), throwsArgumentError);
    });
  });
}
