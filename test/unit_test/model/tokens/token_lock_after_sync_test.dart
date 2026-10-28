import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/token_template.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';

/// What a privacyIDEA server sends for a container token in a sync: no pin.
Map<String, dynamic> _serverUpdate(Token token) => {
  ...token.toOtpAuthMap(),
  Token.PIN: Token.PIN_VALUE_FALSE,
  Token.LABEL: 'renamed on the server',
};

void main() {
  // A lock the user set by swipe lives only in the app: pin stays false.
  final tokens = <Token>[
    HOTPToken(
      id: 'h',
      serial: 'OATH0001',
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: 'JBSWY3DPEHPK3PXP',
      isLocked: true,
    ),
    TOTPToken(
      id: 't',
      serial: 'TOTP0001',
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: 'JBSWY3DPEHPK3PXP',
      period: 30,
      isLocked: true,
    ),
  ];

  for (final token in tokens) {
    group('a ${token.type} locked by swipe', () {
      test('is still locked after a sync rebuilds it', () {
        final rebuilt = token
            .toTemplate()!
            .withOtpAuthData(_serverUpdate(token))
            .toToken();

        expect(rebuilt.label, 'renamed on the server');
        expect(rebuilt.isLocked, isTrue);
      });

      test('is still locked after a sync updates it', () {
        final updated = token.copyUpdateByTemplate(
          TokenTemplate.withSerial(
            otpAuthMap: _serverUpdate(token),
            serial: token.serial!,
          ),
        );

        expect(updated.label, 'renamed on the server');
        expect(updated.isLocked, isTrue);
      });

      test('a server pin still locks a token the user had not locked', () {
        final unlocked = token.copyWith(isLocked: false);
        final updated = unlocked.copyUpdateByTemplate(
          TokenTemplate.withSerial(
            otpAuthMap: {
              ...unlocked.toOtpAuthMap(),
              Token.PIN: Token.PIN_VALUE_TRUE,
            },
            serial: token.serial!,
          ),
        );

        expect(updated.isLocked, isTrue);
      });
    });
  }
}
