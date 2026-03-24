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
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/token_template.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';

void main() {
  group('SteamToken - Complete Deep Dive Suite', () {
    const String baseSecret = 'JBSWY3DPEHPK3PXP';
    const String testId = 'steam-unique-id';

    SteamToken createTestToken({
      String? id,
      String? secret,
      int? folderId,
      TokenOriginData? origin,
    }) => SteamToken(
      id: id ?? testId,
      secret: secret ?? baseSecret,
      label: 'SteamUser',
      issuer: 'Steam',
      folderId: folderId,
      origin: origin,
    );

    group('1. Construction & Fixed Constraints', () {
      test('Steam tokens must ignore variable TOTP parameters', () {
        final token = createTestToken();
        expect(token.type, 'STEAM');
        expect(token.digits, 5);
        expect(token.period, 30);
        expect(token.algorithm, Algorithms.SHA1);
        expect(token.isPrivacyIdeaToken, isFalse);
        expect(token.serial, isNull);
      });
    });

    group('2. Serialization & Factories', () {
      test(
        'fromOtpAuthMap creates valid instance and handles secret casing',
        () {
          final map = {
            Token.LABEL: 'SteamAccount',
            Token.ISSUER: 'Steam',
            OTPToken.SECRET_BASE32: 'jbswy3dpehpk3pxp',
          };
          final token = SteamToken.fromOtpAuthMap(map);

          expect(token.label, 'SteamAccount');
          expect(token.secret.toUpperCase(), baseSecret);
        },
      );

      test('toOtpAuthMap export format including period', () {
        final token = createTestToken();
        final map = token.toOtpAuthMap();

        expect(map[Token.TOKENTYPE_OTPAUTH], 'STEAM');
        expect(map[OTPToken.SECRET_BASE32], baseSecret);
        expect(map[TOTPToken.PERIOD_SECONDS], '30');
      });

      test('toJson / fromJson roundtrip', () {
        final original = createTestToken(folderId: 99);
        final json = original.toJson();
        final recovered = SteamToken.fromJson(json);

        expect(recovered.id, original.id);
        expect(recovered.folderId, 99);
      });
    });

    group('3. Copying & Templates', () {
      test('copyWith preserves enum-based origin source', () {
        final origin = TokenOriginData(
          source: TokenOriginSourceType.manually,
          appName: 'TestApp',
          data: 'test-data',
        );
        final token = createTestToken(origin: origin, folderId: 10);

        final copied = token.copyWith(label: 'NewName');

        expect(copied.label, 'NewName');
        expect(copied.origin?.source, TokenOriginSourceType.manually);
        expect(copied.folderId, 10);
      });

      test('copyUpdateByTemplate handles required secret mapping', () {
        final token = createTestToken();
        final template = TokenTemplate.withOtps(
          otpAuthMap: {
            Token.LABEL: 'UpdatedLabel',
            OTPToken.SECRET_BASE32: baseSecret,
          },
          otps: [],
        );

        final updated = token.copyUpdateByTemplate(template);
        expect(updated.label, 'UpdatedLabel');
        expect(updated.digits, 5);
      });
    });

    group('4. Logic & Edge Cases', () {
      test('otpFromTime calculation with Steam alphabet', () {
        final time = DateTime.fromMillisecondsSinceEpoch(1712666212056);
        final token = createTestToken(secret: 'SECRETA=');

        final otp = token.otpFromTime(time);
        expect(otp, 'JGPCJ');
        expect(otp.length, 5);
      });

      test('isSameTokenAs logic (ID vs Parameters)', () {
        final t1 = createTestToken(id: 'ID1', secret: 'SECRET_A');
        final t2 = createTestToken(id: 'ID2', secret: 'SECRET_A');

        expect(t1.isSameTokenAs(t2), isTrue);
      });
    });
  });
}
