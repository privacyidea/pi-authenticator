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
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart' show RSAPrivateKey, RSAPublicKey;
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/day_password_token_view_mode.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/exception_errors/localized_argument_error.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/token_template.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/model/version.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

/// Returns a skip reason unless the bug tests are enabled explicitly.
String? bug(String description) =>
    const bool.fromEnvironment('RUN_BUG_TESTS') ? null : 'BUG: $description';

const String _checkedContainerBug =
    'only DayPasswordToken.copyUpdateByTemplate applies the checkedContainer of the template additionalData, the other types drop it';

const String _frozenBug =
    'copyWith passes this.isLocked/this.isHidden (derived getters) as explicit state, '
    'so a lock derived from pin/forceBiometricOption survives removing it';

final TokenOriginData _copyUpdateOrigin = TokenOriginData(
  source: TokenOriginSourceType.qrScan,
  appName: 'TestApp',
  data: 'otpauth://totp/test',
  createdAt: DateTime.utc(2024, 1, 2, 3, 4, 5),
  isPrivacyIdeaToken: true,
);

TokenTemplate _template(
  Map<String, dynamic> otpAuthMap, {
  Map<String, dynamic> additionalData = const {},
}) => TokenTemplate.withOtps(
  otpAuthMap: otpAuthMap,
  otps: const [],
  additionalData: additionalData,
);

void _expectMetadataKept(Token before, Token after) {
  expect(after.id, before.id);
  expect(after.type, before.type);
  expect(after.folderId, 4);
  expect(after.sortIndex, 9);
  expect(after.containerSerial, 'CONT-1');
  expect(after.checkedContainer, ['CONT-1']);
  expect(after.origin, _copyUpdateOrigin);
  expect(after.isOffline, isTrue);
  expect(after.forceBiometricOption, ForceBiometricOption.none);
}

const String _pushSerial = 'PUSH-SERIAL';
const String _pushUrl = 'https://new.example.com/rollout';

PushToken _oldPush({bool pin = false}) => PushToken(
  id: 'push-id',
  serial: _pushSerial,
  label: 'old label',
  issuer: 'old issuer',
  url: Uri.parse('https://old.example.com/rollout'),
  sslVerify: true,
  isPollOnly: false,
  enrollmentCredentials: 'old-credential',
  fbToken: 'fb-token',
  publicServerKey: 'server-public',
  publicTokenKey: 'token-public',
  privateTokenKey: 'token-private',
  expirationDate: DateTime.utc(2030),
  isRolledOut: true,
  rolloutState: PushTokenRollOutState.rolloutComplete,
  tokenImage: 'old.png',
  pin: pin,
  folderId: 4,
  sortIndex: 9,
  containerSerial: 'CONT-1',
  checkedContainer: const ['CONT-1'],
  isOffline: true,
  origin: _copyUpdateOrigin,
);

const String _secret = 'JBSWY3DPEHPK3PXP';

final TokenOriginData _jsonOrigin = TokenOriginData(
  source: TokenOriginSourceType.container,
  appName: 'Server (CONT-1)',
  data: 'otpauth://totp/Test?secret=$_secret',
  createdAt: DateTime.utc(2024, 2, 29, 23, 59, 58, 123),
  isPrivacyIdeaToken: true,
  creator: 'admin',
  piServerVersion: const Version(3, 11, 2),
);

/// The storage format: Token -> String -> Token.
Token _viaStorage(Token token) =>
    Token.fromJson(jsonDecode(jsonEncode(token)) as Map<String, dynamic>);

Map<String, dynamic> _jsonOf(Token token) =>
    jsonDecode(jsonEncode(token)) as Map<String, dynamic>;

/// Compares everything that is part of the base Token.
void _expectBaseEqual(Token actual, Token expected) {
  expect(actual.runtimeType, expected.runtimeType);
  expect(actual.id, expected.id);
  expect(actual.type, expected.type);
  expect(actual.label, expected.label);
  expect(actual.issuer, expected.issuer);
  expect(actual.serial, expected.serial);
  expect(actual.containerSerial, expected.containerSerial);
  expect(actual.checkedContainer, expected.checkedContainer);
  expect(actual.pin, expected.pin);
  expect(actual.forceBiometricOption, expected.forceBiometricOption);
  expect(actual.tokenImage, expected.tokenImage);
  expect(actual.folderId, expected.folderId);
  expect(actual.sortIndex, expected.sortIndex);
  expect(actual.isOffline, expected.isOffline);
  expect(actual.isLocked, expected.isLocked);
  expect(actual.isHidden, expected.isHidden);
  expect(actual.origin, expected.origin);
}

// --- tiny static RSA key pair (textbook sized, never use for anything real) ---
final BigInt _p = BigInt.from(104729);
final BigInt _q = BigInt.from(1299709);
final BigInt _n = _p * _q;
final BigInt _e = BigInt.from(65537);
final BigInt _d = _e.modInverse((_p - BigInt.one) * (_q - BigInt.one));

const RsaUtils _rsa = RsaUtils();
final String _publicTokenKey = _rsa.serializeRSAPublicKeyPKCS1(
  RSAPublicKey(_n, _e),
);
final String _privateTokenKey = _rsa.serializeRSAPrivateKeyPKCS1(
  RSAPrivateKey(_n, _d, _p, _q),
);
// A second, different modulus for the key of the server.
final String _publicServerKey = _rsa.serializeRSAPublicKeyPKCS1(
  RSAPublicKey(BigInt.from(15485863) * BigInt.from(32452843), _e),
);

PushToken _fullPush({
  PushTokenRollOutState rolloutState = PushTokenRollOutState.rolloutComplete,
  bool? isPollOnly = true,
}) => PushToken(
  id: 'push-id',
  serial: 'PUSH-SERIAL',
  label: 'push label',
  issuer: 'push issuer',
  url: Uri.parse('https://pi.example.com:8443/ttype/push?x=1'),
  expirationDate: DateTime.utc(2031, 12, 31, 23, 59, 59, 999),
  fbToken: 'firebase-token',
  sslVerify: true,
  isPollOnly: isPollOnly,
  enrollmentCredentials: 'enroll-credential',
  isRolledOut: true,
  rolloutState: rolloutState,
  publicServerKey: _publicServerKey,
  publicTokenKey: _publicTokenKey,
  privateTokenKey: _privateTokenKey,
  tokenImage: 'push.png',
  pin: true,
  isLocked: true,
  forceBiometricOption: ForceBiometricOption.biometric,
  folderId: 11,
  sortIndex: 7,
  containerSerial: 'CONT-4',
  checkedContainer: const ['CONT-4', 'CONT-5'],
  isOffline: true,
  origin: _jsonOrigin,
);

void main() {
  group('PushToken - Every Corner Suite', () {
    const String testSerial = 'PUSH123456';
    const String testId = 'push-id-999';
    final Uri testUrl = Uri.parse('https://example.com/rollout');

    PushToken createPush({
      PushTokenRollOutState? rolloutState,
      bool? isRolledOut,
      bool? sslVerify,
    }) => PushToken(
      serial: testSerial,
      id: testId,
      url: testUrl,
      rolloutState: rolloutState,
      isRolledOut: isRolledOut,
      sslVerify: sslVerify,
      label: 'Push',
      issuer: 'PI',
    );

    test('Rollout State mapping in fromJson factory', () {
      final statesToTest = {
        'generatingRSAKeyPair':
            PushTokenRollOutState.generatingRSAKeyPairFailed,
        'receivingFirebaseToken':
            PushTokenRollOutState.receivingFirebaseTokenFailed,
        'sendRSAPublicKey': PushTokenRollOutState.sendRSAPublicKeyFailed,
        'parsingResponse': PushTokenRollOutState.parsingResponseFailed,
        'rolloutComplete': PushTokenRollOutState.rolloutComplete,
      };

      for (var entry in statesToTest.entries) {
        final json = {
          'id': testId,
          'type': 'PIPUSH',
          'serial': testSerial,
          'rolloutState': entry.key,
        };
        final token = PushToken.fromJson(json);
        expect(
          token.rolloutState,
          entry.value,
          reason: 'Failed for ${entry.key}',
        );
      }
    });

    test('fromOtpAuthMap enforces piauth version 1', () {
      final map = {
        PushToken.VERSION: '2',
        Token.SERIAL: testSerial,
        PushToken.ROLLOUT_URL: testUrl.toString(),
        Token.LABEL: 'L',
        Token.ISSUER: 'I',
      };
      expect(
        () => PushToken.fromOtpAuthMap(map),
        throwsA(isA<LocalizedArgumentError>()),
      );
    });

    test('RSA Public/Private key getter null safety', () {
      final token = createPush();
      expect(token.rsaPublicServerKey, isNull);
      expect(token.rsaPublicTokenKey, isNull);
      expect(token.rsaPrivateTokenKey, isNull);
    });

    test('Identity check (isSameTokenAs) corner cases', () {
      final t1 = createPush().copyWith(publicServerKey: 'KEY_A');
      final t2 = createPush().copyWith(publicServerKey: 'KEY_A');
      final t3 = createPush().copyWith(publicServerKey: 'KEY_B');

      expect(t1.isSameTokenAs(t2), isTrue);
      expect(t1.isSameTokenAs(t3), isFalse);
    });

    test('toOtpAuthMap transforms booleans to 1/0 and True/False strings', () {
      final token = createPush(
        sslVerify: true,
      ).copyWith(isPollOnly: () => true);
      final map = token.toOtpAuthMap();
      expect(map[PushToken.SSL_VERIFY], '1');
      expect(map[PushToken.IS_POLL_ONLY], 'True');
      expect(map[PushToken.VERSION], '1');
    });

    test('isHidden is constant false for PushToken', () {
      final token = createPush().copyWith(isHidden: true);
      expect(token.isHidden, isFalse);
    });
  });

  group('DayPasswordToken - Every Corner Suite', () {
    final testPeriod = const Duration(hours: 24);
    const baseSecret = 'JBSWY3DPEHPK3PXP';

    DayPasswordToken createDay({
      DayPasswordTokenViewMode viewMode = DayPasswordTokenViewMode.VALIDFOR,
      Duration? period,
    }) => DayPasswordToken(
      id: 'day-id',
      secret: baseSecret,
      label: 'Day',
      issuer: 'PI',
      algorithm: Algorithms.SHA1,
      digits: 6,
      period: period ?? testPeriod,
      viewMode: viewMode,
    );

    test('Fallback logic for invalid durations', () {
      final tokenZero = createDay(period: Duration.zero);
      final tokenNeg = createDay(period: const Duration(seconds: -1));
      expect(tokenZero.period, const Duration(hours: 24));
      expect(tokenNeg.period, const Duration(hours: 24));
    });

    test('Duration consistency (Sum of durations)', () {
      final token = createDay();
      final total = token.durationSinceLastOTP + token.durationUntilNextOTP;
      // The two getters each read DateTime.now() independently, so the sum can
      // drift by a few milliseconds (and cross a second boundary under .inSeconds).
      final errorMargin = (total - token.period).abs();
      expect(errorMargin.inMilliseconds, lessThan(100));
    });

    test('Time window sequence with microsecond margin', () {
      final token = createDay();
      final start = token.thisOTPTimeStart;
      final next = token.nextOTPTimeStart;

      expect(next.isAfter(start), isTrue);

      // Use a small margin (e.g., 100ms) to account for execution time between calls
      final difference = next.difference(start);
      final errorMargin = (difference - token.period).abs();

      expect(
        errorMargin.inMilliseconds,
        lessThan(100),
        reason:
            'The gap between time windows should be exactly the period, plus/minus execution jitter.',
      );
    });
    test('Serialization roundtrip with ViewMode as String', () {
      final map = {
        Token.LABEL: 'Day',
        OTPToken.SECRET_BASE32: baseSecret,
        OTPToken.ALGORITHM: 'SHA1',
        OTPToken.DIGITS: 6,
        TOTPToken.PERIOD_SECONDS: '86400',
      };

      final data = {DayPasswordToken.VIEW_MODE: 'validUntil'};
      final token = DayPasswordToken.fromOtpAuthMap(map, additionalData: data);

      expect(token.viewMode, DayPasswordTokenViewMode.VALIDUNTIL);
      expect(
        token.additionalData[DayPasswordToken.VIEW_MODE],
        DayPasswordTokenViewMode.VALIDUNTIL.name,
      );
    });
    test('copyUpdateByTemplate with DayPassword specific fields', () {
      final token = createDay();
      final template = TokenTemplate.withOtps(
        otpAuthMap: {Token.LABEL: 'Updated', TOTPToken.PERIOD_SECONDS: '3600'},
        otps: [],
        additionalData: {
          DayPasswordToken.VIEW_MODE: DayPasswordTokenViewMode.VALIDUNTIL,
        },
      );

      final updated = token.copyUpdateByTemplate(template);
      expect(updated.label, 'Updated');
      expect(updated.period, const Duration(hours: 1));
      expect(updated.viewMode, DayPasswordTokenViewMode.VALIDUNTIL);
    });

    test('Equality (==) includes viewMode and period', () {
      final t1 = createDay();
      final t2 = createDay(viewMode: DayPasswordTokenViewMode.VALIDUNTIL);
      final t3 = createDay(period: const Duration(hours: 1));

      expect(t1 == t2, isFalse);
      expect(t1 == t3, isFalse);
    });
  });

  _testCopyUpdateByTemplate();
  _testLockStateInCopyWith();
  _testJsonRoundTrip();
}

void _testCopyUpdateByTemplate() {
  group('PushToken.copyUpdateByTemplate', () {
    final fullTemplate = <String, dynamic>{
      Token.SERIAL: _pushSerial,
      PushToken.VERSION: '1',
      Token.LABEL: 'new label',
      Token.ISSUER: 'new issuer',
      Token.IMAGE: 'new.png',
      PushToken.ROLLOUT_URL: _pushUrl,
      PushToken.SSL_VERIFY: '0',
      PushToken.IS_POLL_ONLY: 'True',
      PushToken.ENROLLMENT_CREDENTIAL: 'new-credential',
    };

    test('applies every value the template describes', () {
      final updated = _oldPush().copyUpdateByTemplate(_template(fullTemplate))
          as PushToken;
      expect(updated.label, 'new label');
      expect(updated.issuer, 'new issuer');
      expect(updated.tokenImage, 'new.png');
      expect(updated.url, Uri.parse(_pushUrl));
      expect(updated.sslVerify, isFalse);
      expect(updated.isPollOnly, isTrue);
      expect(updated.enrollmentCredentials, 'new-credential');
      expect(updated.serial, _pushSerial);
    });

    test('keeps rollout state, keys and metadata', () {
      final original = _oldPush();
      final updated = original.copyUpdateByTemplate(_template(fullTemplate))
          as PushToken;
      expect(updated.fbToken, 'fb-token');
      expect(updated.publicServerKey, 'server-public');
      expect(updated.publicTokenKey, 'token-public');
      expect(updated.privateTokenKey, 'token-private');
      expect(updated.expirationDate, DateTime.utc(2030));
      expect(updated.isRolledOut, isTrue);
      expect(updated.rolloutState, PushTokenRollOutState.rolloutComplete);
      _expectMetadataKept(original, updated);
    });

    test('keeps isPollOnly and the enrollment credential when the template omits them', () {
      final base = {
        Token.SERIAL: _pushSerial,
        PushToken.VERSION: '1',
        PushToken.ROLLOUT_URL: _pushUrl,
      };
      final updated = _oldPush().copyUpdateByTemplate(_template(base)) as PushToken;
      expect(updated.isPollOnly, isFalse);
      expect(updated.enrollmentCredentials, 'old-credential');

      final unknownPollOnly = _oldPush().copyWith(isPollOnly: () => null);
      final updated2 =
          unknownPollOnly.copyUpdateByTemplate(_template(base)) as PushToken;
      expect(updated2.isPollOnly, isNull);
    });

    test('a template with another serial replaces the serial', () {
      final updated = _oldPush().copyUpdateByTemplate(
        _template({...fullTemplate, Token.SERIAL: 'PUSH-OTHER'}),
      );
      expect(updated.serial, 'PUSH-OTHER');
    });

    test('a template without serial is rejected and never erases the serial', () {
      final original = _oldPush();
      final withoutSerial = Map<String, dynamic>.from(fullTemplate)
        ..remove(Token.SERIAL);
      expect(
        () => original.copyUpdateByTemplate(_template(withoutSerial)),
        throwsArgumentError,
      );
      expect(original.serial, _pushSerial);
    });

    test('an update by the own template changes nothing', () {
      final original = _oldPush();
      final template = original.toTemplate()!;
      expect(template.serial, _pushSerial);
      final updated = original.copyUpdateByTemplate(template);
      expect(updated.toJson(), original.toJson());
    });
  });

  group('PushToken.copyUpdateByTemplate pin handling', () {
    final minimalTemplate = <String, dynamic>{Token.SERIAL: _pushSerial, PushToken.ROLLOUT_URL: _pushUrl, PushToken.VERSION: '1'};

    test('pin True in the template locks the token', () {
      final updated = _oldPush().copyUpdateByTemplate(
        _template({...minimalTemplate, Token.PIN: Token.PIN_VALUE_TRUE}),
      );
      expect(updated.pin, isTrue);
      expect(updated.isLocked, isTrue);
    });

    test('pin False in the template removes the pin and unlocks the token', () {
      final original = _oldPush(pin: true);
      expect(original.isLocked, isTrue);
      final updated = original.copyUpdateByTemplate(
        _template({...minimalTemplate, Token.PIN: Token.PIN_VALUE_FALSE}),
      );
      expect(updated.pin, isFalse);
      expect(updated.isLocked, isFalse);
    });

    test('a template without pin keeps a pin protected token protected', () {
      final updated = _oldPush(pin: true).copyUpdateByTemplate(
        _template(minimalTemplate),
      );
      expect(updated.pin, isTrue);
      expect(updated.isLocked, isTrue);
    });

    test('a template without pin keeps an unprotected token unprotected', () {
      final updated = _oldPush().copyUpdateByTemplate(_template(minimalTemplate));
      expect(updated.pin, isFalse);
      expect(updated.isLocked, isFalse);
    });
  });

  group('PushToken.copyUpdateByTemplate checkedContainer', () {
    final minimalTemplate = <String, dynamic>{Token.SERIAL: _pushSerial, PushToken.ROLLOUT_URL: _pushUrl, PushToken.VERSION: '1'};

    test('keeps the existing checkedContainer when the template carries none', () {
      final updated = _oldPush().copyUpdateByTemplate(_template(minimalTemplate));
      expect(updated.checkedContainer, ['CONT-1']);
    });

    test(
      'applies the checkedContainer of the template additionalData',
      () {
        final updated = _oldPush().copyUpdateByTemplate(
          _template(
            minimalTemplate,
            additionalData: {
              Token.CHECKED_CONTAINERS: <String>['CONT-2', 'CONT-3'],
            },
          ),
        );
        expect(updated.checkedContainer, ['CONT-2', 'CONT-3']);
      },
      skip: bug(_checkedContainerBug),
    );
  });
}

void _testLockStateInCopyWith() {
  group('PushToken lock state in copyWith', () {
    PushToken build({
      bool? pin,
      ForceBiometricOption? biometric,
      bool? isLocked,
      bool? isHidden,
    }) => PushToken(
      id: 'id',
      serial: 'PUSH-SERIAL',
      pin: pin,
      forceBiometricOption: biometric ?? ForceBiometricOption.none,
      isLocked: isLocked,
      isHidden: isHidden,
    );

    PushToken copyOf(
      PushToken token, {
      bool? pin,
      ForceBiometricOption? biometric,
      bool? isLocked,
      bool? isHidden,
      String? label,
    }) => token.copyWith(
      pin: pin,
      forceBiometricOption: biometric,
      isLocked: isLocked,
      isHidden: isHidden,
      label: label,
    );

    group('behaviour that already holds', () {
        test('a fresh token without pin is neither locked nor hidden', () {
          final token = build();
          expect(token.isLocked, isFalse);
          expect(token.isHidden, isFalse);
        });

        test('an unrelated copyWith keeps an unlocked token unlocked and visible', () {
          final copy = copyOf(build(), label: 'renamed');
          expect(copy.label, 'renamed');
          expect(copy.isLocked, isFalse);
          expect(copy.isHidden, isFalse);
        });

        test('an unrelated copyWith keeps a pin protected token locked', () {
          final copy = copyOf(build(pin: true), label: 'renamed');
          expect(copy.pin, isTrue);
          expect(copy.isLocked, isTrue);
        });

        test('an unrelated copyWith keeps a biometric protected token locked', () {
          final copy = copyOf(
            build(biometric: ForceBiometricOption.biometric),
            label: 'renamed',
          );
          expect(copy.forceBiometricOption, ForceBiometricOption.biometric);
          expect(copy.isLocked, isTrue);
        });

        test('adding a pin locks the token', () {
          final copy = copyOf(build(), pin: true);
          expect(copy.pin, isTrue);
          expect(copy.isLocked, isTrue);
        });

        test('forcing biometrics locks the token', () {
          final copy = copyOf(build(), biometric: ForceBiometricOption.any);
          expect(copy.isLocked, isTrue);
        });

        test('isLocked: true locks a token that has no pin', () {
          final copy = copyOf(build(), isLocked: true);
          expect(copy.pin, isFalse);
          expect(copy.isLocked, isTrue);
        });

        test('isLocked: false unlocks a token that was only locked explicitly', () {
          final copy = copyOf(build(isLocked: true), isLocked: false);
          expect(copy.isLocked, isFalse);
        });

        test('isLocked: false can not unlock a pin protected token', () {
          final copy = copyOf(build(pin: true), isLocked: false);
          expect(copy.pin, isTrue);
          expect(copy.isLocked, isTrue);
        });

        test('isLocked: false can not unlock a biometric protected token', () {
          final copy = copyOf(
            build(biometric: ForceBiometricOption.pin),
            isLocked: false,
          );
          expect(copy.isLocked, isTrue);
        });

        test('an explicit lock survives the removal of the pin', () {
          final copy = copyOf(build(pin: true, isLocked: true), pin: false);
          expect(copy.pin, isFalse);
          expect(copy.isLocked, isTrue);
        });

          test('isHidden stays false whatever pin, lock or isHidden say', () {
            final token = build(pin: true, isLocked: true, isHidden: true);
            expect(token.isLocked, isTrue);
            expect(token.isHidden, isFalse);
            expect(copyOf(token, isHidden: true).isHidden, isFalse);
            expect(copyOf(build(), pin: true).isHidden, isFalse);
            expect(copyOf(token, label: 'x').isHidden, isFalse);
          });
    });

    group('derived lock state must not be frozen by copyWith', () {
        test(
          'removing the pin unlocks a token that was only locked by its pin',
          () {
            final copy = copyOf(build(pin: true), pin: false);
            expect(copy.pin, isFalse);
            expect(copy.isLocked, isFalse);
          },
          skip: bug(_frozenBug),
        );

        test(
          'removing forced biometrics unlocks a token that was only locked by them',
          () {
            final copy = copyOf(
              build(biometric: ForceBiometricOption.biometric),
              biometric: ForceBiometricOption.none,
            );
            expect(copy.forceBiometricOption, ForceBiometricOption.none);
            expect(copy.isLocked, isFalse);
          },
          skip: bug(_frozenBug),
        );

        test(
          'an unrelated copyWith does not freeze the pin lock for a later pin removal',
          () {
            final renamed = copyOf(build(pin: true), label: 'renamed');
            final unpinned = copyOf(renamed, pin: false);
            expect(unpinned.isLocked, isFalse);
          },
          skip: bug(_frozenBug),
        );

        test(
          'removing the pin and the biometric requirement in two steps unlocks the token',
          () {
            final both = build(
              pin: true,
              biometric: ForceBiometricOption.biometric,
            );
            final step1 = copyOf(both, pin: false);
            expect(step1.isLocked, isTrue, reason: 'biometrics still force the lock');
            final step2 = copyOf(step1, biometric: ForceBiometricOption.none);
            expect(step2.isLocked, isFalse);
          },
          skip: bug(_frozenBug),
        );


    });
  });
}

void _testJsonRoundTrip() {
  group('static RSA fixture', () {
    test('serialized keys parse back to the original numbers', () {
      final pub = _rsa.deserializeRSAPublicKeyPKCS1(_publicTokenKey);
      expect(pub.modulus, _n);
      expect(pub.exponent, _e);
      final priv = _rsa.deserializeRSAPrivateKeyPKCS1(_privateTokenKey);
      expect(priv.modulus, _n);
      expect(priv.privateExponent, _d);
      expect(priv.p, _p);
      expect(priv.q, _q);
      expect((_e * _d) % ((_p - BigInt.one) * (_q - BigInt.one)), BigInt.one);
    });
  });

  group('PushToken JSON round trip', () {
    test('all metadata, keys and rollout data survive the round trip', () {
      final original = _fullPush();
      final restored = _viaStorage(original) as PushToken;
      _expectBaseEqual(restored, original);
      expect(restored.serial, 'PUSH-SERIAL');
      expect(restored.url, Uri.parse('https://pi.example.com:8443/ttype/push?x=1'));
      expect(restored.expirationDate, DateTime.utc(2031, 12, 31, 23, 59, 59, 999));
      expect(restored.fbToken, 'firebase-token');
      expect(restored.sslVerify, isTrue);
      expect(restored.isPollOnly, isTrue);
      expect(restored.enrollmentCredentials, 'enroll-credential');
      expect(restored.isRolledOut, isTrue);
      expect(restored.rolloutState, PushTokenRollOutState.rolloutComplete);
      expect(restored.publicServerKey, _publicServerKey);
      expect(restored.publicTokenKey, _publicTokenKey);
      expect(restored.privateTokenKey, _privateTokenKey);
    });

    test('the JSON is stable', () {
      final original = _fullPush();
      expect(_jsonOf(_viaStorage(original)), _jsonOf(original));
    });

    test('the restored RSA keys are usable and equal the fixture numbers', () {
      final restored = _viaStorage(_fullPush()) as PushToken;
      expect(restored.rsaPublicTokenKey!.modulus, _n);
      expect(restored.rsaPublicTokenKey!.exponent, _e);
      expect(restored.rsaPrivateTokenKey!.privateExponent, _d);
      expect(restored.rsaPrivateTokenKey!.p, _p);
      expect(restored.rsaPrivateTokenKey!.q, _q);
      expect(
        restored.rsaPublicServerKey!.modulus,
        BigInt.from(15485863) * BigInt.from(32452843),
      );
    });

    test('isPollOnly keeps its three states true, false and null', () {
      for (final value in <bool?>[true, false, null]) {
        final restored =
            _viaStorage(_fullPush(isPollOnly: value)) as PushToken;
        expect(restored.isPollOnly, value, reason: 'isPollOnly $value');
      }
    });

    test('a token without optional fields survives', () {
      final minimal = PushToken(id: 'min', serial: 'S');
      final restored = _viaStorage(minimal) as PushToken;
      _expectBaseEqual(restored, minimal);
      expect(restored.url, isNull);
      expect(restored.expirationDate, isNull);
      expect(restored.fbToken, isNull);
      expect(restored.isPollOnly, isNull);
      expect(restored.enrollmentCredentials, isNull);
      expect(restored.publicServerKey, isNull);
      expect(restored.publicTokenKey, isNull);
      expect(restored.privateTokenKey, isNull);
      expect(restored.rsaPublicTokenKey, isNull);
      expect(restored.rsaPrivateTokenKey, isNull);
      expect(restored.isRolledOut, isFalse);
      expect(restored.sslVerify, isFalse);
      expect(restored.rolloutState, PushTokenRollOutState.rolloutNotStarted);
    });

    test('rollout states that were interrupted come back as failed', () {
      const expected = {
        PushTokenRollOutState.rolloutNotStarted:
            PushTokenRollOutState.rolloutNotStarted,
        PushTokenRollOutState.generatingRSAKeyPair:
            PushTokenRollOutState.generatingRSAKeyPairFailed,
        PushTokenRollOutState.generatingRSAKeyPairFailed:
            PushTokenRollOutState.generatingRSAKeyPairFailed,
        PushTokenRollOutState.receivingFirebaseToken:
            PushTokenRollOutState.receivingFirebaseTokenFailed,
        PushTokenRollOutState.receivingFirebaseTokenFailed:
            PushTokenRollOutState.receivingFirebaseTokenFailed,
        PushTokenRollOutState.sendRSAPublicKey:
            PushTokenRollOutState.sendRSAPublicKeyFailed,
        PushTokenRollOutState.sendRSAPublicKeyFailed:
            PushTokenRollOutState.sendRSAPublicKeyFailed,
        PushTokenRollOutState.parsingResponse:
            PushTokenRollOutState.parsingResponseFailed,
        PushTokenRollOutState.parsingResponseFailed:
            PushTokenRollOutState.parsingResponseFailed,
        PushTokenRollOutState.rolloutComplete:
            PushTokenRollOutState.rolloutComplete,
      };
      expect(expected.keys.toSet(), PushTokenRollOutState.values.toSet());
      for (final entry in expected.entries) {
        final restored =
            _viaStorage(_fullPush(rolloutState: entry.key)) as PushToken;
        expect(restored.rolloutState, entry.value, reason: '${entry.key}');
        // a second load does not change the state any more
        expect(
          (_viaStorage(restored) as PushToken).rolloutState,
          entry.value,
          reason: 'second load of ${entry.key}',
        );
      }
    });

    test('isHidden is never stored as true', () {
      final json = _jsonOf(_fullPush());
      expect(json['isLocked'], isTrue);
      expect(json['isHidden'], isFalse);
    });


    test('PushToken: Token.fromJson dispatches to the own type', () {
      final restored = _viaStorage(_fullPush());
      expect(restored.runtimeType.toString(), 'PushToken');
      expect(restored.type, _fullPush().type);
    });

    test('PushToken: every ForceBiometricOption survives and locks the token', () {
      for (final option in ForceBiometricOption.values) {
        final token = _fullPush().copyWith(
          pin: false,
          isLocked: false,
          forceBiometricOption: option,
        );
        final restored = _viaStorage(token);
        expect(restored.forceBiometricOption, option, reason: '$option');
        expect(
          restored.isLocked,
          option != ForceBiometricOption.none,
          reason: 'isLocked for $option',
        );
      }
    });

    test('PushToken: folder and sort index survive, also when null', () {
      final withValues = _viaStorage(_fullPush());
      expect(withValues.folderId, _fullPush().folderId);
      expect(withValues.sortIndex, _fullPush().sortIndex);
      final cleared = _viaStorage(_fullPush().copyWith(folderId: () => null));
      expect(cleared.folderId, isNull);
    });

    test('PushToken: a JSON written without the optional keys loads with defaults', () {
      final json = _jsonOf(_fullPush())
        ..remove('isOffline')
        ..remove('forceBiometricOption')
        ..remove('checkedContainer')
        ..remove('label')
        ..remove('issuer')
        ..remove('pin')
        ..remove('isLocked')
        ..remove('isHidden');
      final restored = Token.fromJson(json);
      expect(restored.isOffline, isFalse);
      expect(restored.forceBiometricOption, ForceBiometricOption.none);
      expect(restored.checkedContainer, isEmpty);
      expect(restored.label, '');
      expect(restored.issuer, '');
      expect(restored.pin, isFalse);
      expect(restored.isLocked, isFalse);
      expect(restored.isHidden, isFalse);
    });
  });
}
