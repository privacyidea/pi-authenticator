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
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/day_password_token_view_mode.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/model/version.dart';

/// Token fixtures shared by the tests of `TokenEncryption` (export uri / qr code),
/// `generateQrCodeImage` and `ShowQrCodeDialog`.

final _createdAt = DateTime.utc(2024, 5, 17, 12, 30, 45, 123);

TokenOriginData _origin() => TokenOriginData(
      source: TokenOriginSourceType.manually,
      appName: 'privacyIDEA Authenticator',
      data: 'otpauth://totp/x?secret=ABC',
      createdAt: _createdAt,
      isPrivacyIdeaToken: false,
      creator: 'someone',
      piServerVersion: const Version(3, 10, 0),
    );

HOTPToken exportUriHotp() => HOTPToken(
      id: 'hotp-id',
      label: 'Alice Ünïcödé \u{1F510}',
      issuer: 'ACME & Co?x=1#frag',
      serial: 'OATH0001A',
      containerSerial: 'CONT-HOTP',
      checkedContainer: const ['CONT-HOTP', 'CONT-OLD'],
      algorithm: Algorithms.SHA256,
      digits: 8,
      secret: 'JBSWY3DPEHPK3PXP',
      counter: 42,
      tokenImage: 'https://example.com/img/hotp.png?a=b&c=d',
      pin: true,
      isLocked: true,
      isHidden: true,
      sortIndex: 3,
      folderId: 7,
      origin: _origin(),
      isOffline: true,
      forceBiometricOption: ForceBiometricOption.biometric,
    );

TOTPToken exportUriTotp() => TOTPToken(
      id: 'totp-id',
      label: 'totp label',
      issuer: 'issuer',
      containerSerial: 'CONT-TOTP',
      checkedContainer: const ['CONT-TOTP'],
      algorithm: Algorithms.SHA512,
      digits: 6,
      secret: 'MFRGGZDFMZTWQ2LK',
      period: 60,
      tokenImage: 'totp.png',
      isLocked: true,
      isHidden: false,
      sortIndex: 0,
      folderId: 2,
      origin: _origin(),
      forceBiometricOption: ForceBiometricOption.pin,
    );

SteamToken exportUriSteam() => SteamToken(
      id: 'steam-id',
      label: 'steam label',
      issuer: 'Steam',
      secret: 'JBSWY3DPEHPK3PXP',
      checkedContainer: const ['A', 'B'],
      isHidden: true,
      sortIndex: 11,
      folderId: 5,
      origin: _origin(),
      isOffline: true,
      forceBiometricOption: ForceBiometricOption.any,
    );

DayPasswordToken exportUriDayPassword() => DayPasswordToken(
      id: 'day-id',
      label: 'day label',
      issuer: 'issuer',
      serial: 'DPW0001A',
      algorithm: Algorithms.SHA1,
      digits: 7,
      secret: 'GEZDGNBVGY3TQOJQ',
      period: const Duration(hours: 6, minutes: 30),
      viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
      pin: true,
      isLocked: true,
      sortIndex: 8,
      folderId: 1,
      origin: _origin(),
    );

PushToken exportUriPush({String privateKey = 'PRIVATE-TOKEN-KEY'}) => PushToken(
      id: 'push-id',
      serial: 'PIPU0001A',
      label: 'push label',
      issuer: 'issuer',
      containerSerial: 'CONT-PUSH',
      fbToken: 'firebase-token',
      url: Uri.parse('https://pi.example.com/ttype/push?x=1'),
      expirationDate: DateTime.utc(2030, 1, 2, 3, 4, 5),
      enrollmentCredentials: 'enroll-secret',
      publicServerKey: 'PUBLIC-SERVER-KEY',
      publicTokenKey: 'PUBLIC-TOKEN-KEY',
      privateTokenKey: privateKey,
      isPollOnly: true,
      isRolledOut: true,
      sslVerify: true,
      rolloutState: PushTokenRollOutState.rolloutComplete,
      sortIndex: 4,
      folderId: 9,
      origin: _origin(),
      forceBiometricOption: ForceBiometricOption.biometric,
    );

Token exportUriMinimalTotp({String label = '', String issuer = '', String? tokenImage}) =>
    TOTPToken(id: 'id', label: label, issuer: issuer, tokenImage: tokenImage, algorithm: Algorithms.SHA1, digits: 6, secret: 'JBSWY3DPEHPK3PXP', period: 30);
