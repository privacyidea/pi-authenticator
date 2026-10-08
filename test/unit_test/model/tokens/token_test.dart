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
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/token_template.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';

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

const _secret = 'GEZDGNBVGY3TQOJQ';

TokenOriginData _origin(
  TokenOriginSourceType source, {
  bool? isPi,
  String data = 'data',
}) => TokenOriginData(
  source: source,
  appName: 'app',
  data: data,
  isPrivacyIdeaToken: isPi,
);

HOTPToken _hotp({
  String? serial,
  TokenOriginData? origin,
  String id = 'hotp-id',
}) => HOTPToken(
  id: id,
  serial: serial,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: _secret,
  origin: origin,
);

TOTPToken _totp({TokenOriginData? origin}) => TOTPToken(
  id: 'totp-id',
  period: 30,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: _secret,
  origin: origin,
);

DayPasswordToken _dayPassword({TokenOriginData? origin}) => DayPasswordToken(
  id: 'day-id',
  period: const Duration(hours: 24),
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: _secret,
  origin: origin,
);

SteamToken _steam({TokenOriginData? origin}) =>
    SteamToken(id: 'steam-id', secret: _secret, origin: origin);

PushToken _push({TokenOriginData? origin}) => PushToken(
  id: 'push-id',
  serial: 'PIPU0001',
  url: Uri.parse('https://pi.example.com/ttype/push'),
  origin: origin,
);

TokenContainerFinalized _container({String serial = 'SMPH0001'}) =>
    TokenContainerFinalized(
      issuer: 'privacyIDEA',
      nonce: 'nonce',
      timestamp: DateTime.utc(2026),
      serverUrl: Uri.parse('https://pi.example.com'),
      serial: serial,
      ecKeyAlgorithm: EcKeyAlgorithm.secp384r1,
      hashAlgorithm: Algorithms.SHA256,
      sslVerify: true,
      publicClientKey: 'pub',
      privateClientKey: 'priv',
    );

/// What the security policy demands. Exportable: not a privacyIDEA token.
///  - explicitly "no privacyIDEA token" (false): exportable
///  - privacyIDEA token (true): never exportable
///  - unknown (null): only if the user added it manually
bool _policyExportable(TokenOriginSourceType source, bool? isPi) {
  if (isPi == true) return false;
  if (isPi == false) return true;
  return source == TokenOriginSourceType.manually;
}

// --- tokens with pin, lock state and biometric option set (JSON round trip) ---

HOTPToken _pinnedHotp() => HOTPToken(
  id: 'hotp-id',
  serial: 'HOTP-SERIAL',
  algorithm: Algorithms.SHA256,
  digits: 8,
  secret: _secret,
  pin: true,
  isLocked: true,
  isHidden: false,
  forceBiometricOption: ForceBiometricOption.biometric,
);

TOTPToken _pinnedTotp() => TOTPToken(
  id: 'totp-id',
  serial: 'TOTP-SERIAL',
  algorithm: Algorithms.SHA512,
  digits: 7,
  secret: _secret,
  period: 45,
  pin: true,
  isLocked: true,
  isHidden: true,
  forceBiometricOption: ForceBiometricOption.pin,
);

DayPasswordToken _pinnedDayPassword() => DayPasswordToken(
  id: 'day-id',
  serial: 'DAY-SERIAL',
  algorithm: Algorithms.SHA1,
  digits: 9,
  secret: _secret,
  period: const Duration(hours: 6),
  pin: true,
  isLocked: true,
  isHidden: false,
  forceBiometricOption: ForceBiometricOption.any,
);

SteamToken _pinnedSteam() => SteamToken(
  id: 'steam-id',
  secret: _secret,
  pin: true,
  isLocked: true,
  isHidden: true,
  forceBiometricOption: ForceBiometricOption.any,
);

PushToken _pinnedPush() => PushToken(
  id: 'push-id',
  serial: 'PUSH-SERIAL',
  url: Uri.parse('https://pi.example.com:8443/ttype/push'),
  pin: true,
  isLocked: true,
  forceBiometricOption: ForceBiometricOption.biometric,
);

/// The storage format: Token -> String -> Token.
Token _viaStorage(Token token) =>
    Token.fromJson(jsonDecode(jsonEncode(token)) as Map<String, dynamic>);

Map<String, dynamic> _jsonOf(Token token) =>
    jsonDecode(jsonEncode(token)) as Map<String, dynamic>;

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

  _testIsExportable();
  _testJsonRoundTripAcrossTokenTypes();
}

void _testIsExportable() {
  group('Token.isExportable', () {
    final builders = <String, Token Function(TokenOriginData?)>{
      'HOTP': (o) => _hotp(origin: o),
      'HOTP with serial': (o) => _hotp(serial: 'OATH0001', origin: o),
      'TOTP': (o) => _totp(origin: o),
      'DayPassword': (o) => _dayPassword(origin: o),
      'Steam': (o) => _steam(origin: o),
    };

    for (final entry in builders.entries) {
      group(entry.key, () {
        test('no origin: not exportable', () {
          expect(entry.value(null).isExportable, isFalse);
        });

        test('follows the origin for every source and flag', () {
          for (final source in TokenOriginSourceType.values) {
            for (final isPi in <bool?>[false, null]) {
              final origin = _origin(source, isPi: isPi);

              expect(
                entry.value(origin).isExportable,
                origin.isExportable,
                reason: '${source.name}/$isPi',
              );
              expect(
                entry.value(origin).isExportable,
                _policyExportable(source, isPi),
                reason: '${source.name}/$isPi',
              );
            }
          }
        });

        test('privacyIDEA tokens (flag true) are not exportable unless added manually', () {
          for (final source in TokenOriginSourceType.values) {
            if (source == TokenOriginSourceType.manually) continue; // see BUG test in the origin group
            expect(
              entry.value(_origin(source, isPi: true)).isExportable,
              isFalse,
              reason: source.name,
            );
          }
        });
      });
    }

    test('push tokens: no origin, privacyIDEA origin and container origin are not exportable', () {
      expect(_push().isExportable, isFalse);
      expect(
        _push(origin: _origin(TokenOriginSourceType.qrScan, isPi: true)).isExportable,
        isFalse,
      );
      expect(
        _push(origin: _origin(TokenOriginSourceType.container, isPi: true)).isExportable,
        isFalse,
      );
      expect(_push(origin: _origin(TokenOriginSourceType.unknown)).isExportable, isFalse);
    });

    test('isPrivacyIdeaToken true/false/null is taken from the origin (push and Steam override it)', () {
      expect(
        _hotp(origin: _origin(TokenOriginSourceType.qrScan, isPi: true)).isPrivacyIdeaToken,
        isTrue,
      );
      expect(
        _hotp(origin: _origin(TokenOriginSourceType.qrScan, isPi: false)).isPrivacyIdeaToken,
        isFalse,
      );
      expect(_hotp(origin: _origin(TokenOriginSourceType.qrScan)).isPrivacyIdeaToken, isNull);
      expect(_hotp().isPrivacyIdeaToken, isNull);
      expect(_push().isPrivacyIdeaToken, isTrue);
      expect(_steam().isPrivacyIdeaToken, isFalse);
    });

    test('changing the origin with copyWith changes the exportability', () {
      final manual = _hotp(origin: _origin(TokenOriginSourceType.manually));
      expect(manual.isExportable, isTrue);

      final asContainerToken = manual.copyWith(
        origin: _origin(TokenOriginSourceType.container, isPi: true),
      );

      expect(asContainerToken.isExportable, isFalse);
      expect(manual.isExportable, isTrue);
    });

    test('exportability survives the token JSON round trip', () {
      final tokens = <Token>[
        _hotp(origin: _origin(TokenOriginSourceType.manually)),
        _hotp(origin: _origin(TokenOriginSourceType.backupFile, isPi: false)),
        _hotp(origin: _origin(TokenOriginSourceType.qrScan, isPi: true)),
        _hotp(origin: _origin(TokenOriginSourceType.link)),
        _hotp(),
        _totp(origin: _origin(TokenOriginSourceType.qrScanImport, isPi: false)),
        _totp(origin: _origin(TokenOriginSourceType.container, isPi: true)),
        _push(origin: _origin(TokenOriginSourceType.qrScan, isPi: true)),
      ];

      for (final token in tokens) {
        final restored = Token.fromJson(
          jsonDecode(jsonEncode(token.toJson())) as Map<String, dynamic>,
        );

        expect(restored.runtimeType, token.runtimeType);
        expect(
          restored.isExportable,
          token.isExportable,
          reason: '${token.runtimeType} ${token.origin}',
        );
      }
    });
  });

  group('linking a token to a container revokes the exportability', () {
    final exportableTokens = <String, Token>{
      'manually added': _hotp(origin: _origin(TokenOriginSourceType.manually)),
      'imported from another app': _hotp(
        origin: _origin(TokenOriginSourceType.backupFile, isPi: false),
      ),
      'google authenticator qr': _totp(
        origin: _origin(TokenOriginSourceType.qrScanImport, isPi: false),
      ),
    };

    for (final entry in exportableTokens.entries) {
      test('container.addOriginToToken: ${entry.key}', () {
        final token = entry.value;
        expect(token.isExportable, isTrue);
        final container = _container(serial: 'SMPH0042');

        final linked = container.addOriginToToken(token: token);

        expect(linked.containerSerial, 'SMPH0042');
        expect(linked.origin!.source, TokenOriginSourceType.container);
        expect(linked.origin!.isPrivacyIdeaToken, isTrue);
        expect(linked.isExportable, isFalse);
        // The input token is unchanged.
        expect(token.isExportable, isTrue);
        expect(token.containerSerial, isNull);
      });
    }

    test('container.addOriginToToken for a token without origin gives a container origin', () {
      final linked = _container().addOriginToToken(
        token: _hotp(),
        tokenData: 'otpauth-data',
      );

      expect(linked.origin!.source, TokenOriginSourceType.container);
      expect(linked.origin!.data, 'otpauth-data');
      expect(linked.isExportable, isFalse);
    });

    test('container.addOriginToToken keeps the original origin data but revokes the export', () {
      final token = _hotp(
        origin: _origin(TokenOriginSourceType.manually, data: 'original-data'),
      );

      final linked = _container().addOriginToToken(token: token, tokenData: 'new');

      expect(linked.origin!.data, 'original-data');
      expect(linked.origin!.appName, 'app');
      expect(linked.isExportable, isFalse);
    });

    test('the sync result path (template -> token -> addOriginToToken) is never exportable', () {
      final container = _container();
      for (final entry in exportableTokens.entries) {
        final withSerial = (entry.value as dynamic).copyWith(
          serial: () => 'OATH-SYNC',
        ) as Token;
        for (final token in [entry.value, withSerial]) {
          final template = token.toTemplate()!;

          final updated = container.addOriginToToken(token: template.toToken());
          final linkedTemplate = token.toTemplate(container: container)!.toToken();

          expect(updated.isExportable, isFalse, reason: entry.key);
          expect(linkedTemplate.isExportable, isFalse, reason: entry.key);
        }
      }
    });
  });
}

void _testJsonRoundTripAcrossTokenTypes() {
  group('Token JSON round trip across token types', () {
    final factories = <String, Token Function()>{
      'HOTPToken': _pinnedHotp,
      'TOTPToken': _pinnedTotp,
      'DayPasswordToken': _pinnedDayPassword,
      'SteamToken': _pinnedSteam,
      'PushToken': _pinnedPush,
    };

    test('the lock state of a pin protected token is stored and restored', () {
      for (final build in factories.values) {
        final original = build();
        expect(original.isLocked, isTrue);
        final json = _jsonOf(original);
        expect(json['pin'], isTrue);
        expect(json['isLocked'], isTrue);
        final restored = _viaStorage(original);
        expect(restored.pin, isTrue);
        expect(restored.isLocked, isTrue);
        expect(restored.isHidden, original.isHidden);
      }
    });

    test('Token.fromJson rejects a missing and an unknown type', () {
      expect(() => Token.fromJson({'id': 'x'}), throwsArgumentError);
      expect(
        () => Token.fromJson({'id': 'x', 'type': 'DOESNOTEXIST'}),
        throwsArgumentError,
      );
    });

    test('Token.fromJson accepts the legacy type name PUSH and normalizes it to PIPUSH', () {
      final json = _jsonOf(_pinnedPush())..['type'] = 'PUSH';
      final restored = Token.fromJson(json);
      expect(restored, isA<PushToken>());
      expect(restored.type, 'PIPUSH');
    });

    test('Token.fromJson matches the type case insensitively', () {
      final json = _jsonOf(_pinnedTotp())..['type'] = 'totp';
      expect(Token.fromJson(json), isA<TOTPToken>());
    });

    test('a list of mixed tokens keeps order and types', () {
      final tokens = <Token>[
        _pinnedPush(),
        _pinnedSteam(),
        _pinnedHotp(),
        _pinnedDayPassword(),
        _pinnedTotp(),
      ];
      final decoded = (jsonDecode(jsonEncode(tokens)) as List)
          .map((e) => Token.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(decoded.map((t) => t.runtimeType).toList(), [
        PushToken,
        SteamToken,
        HOTPToken,
        DayPasswordToken,
        TOTPToken,
      ]);
      expect(decoded.map((t) => t.id).toList(), [
        'push-id',
        'steam-id',
        'hotp-id',
        'day-id',
        'totp-id',
      ]);
    });
  });
}
