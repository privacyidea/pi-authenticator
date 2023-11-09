import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/qr_parser.dart';

void main() {
  _testParsingLabelAndIssuer();
  _testParseOtpAuth();
}

void _testParsingLabelAndIssuer() {
  group('Parsing Label and Issuer', () {
    QrParser qrParser = const QrParser();
    test('Test parse issuer from param', () {
      String uriWithoutIssuerAndLabel = 'otpauth://totp/?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'
          '&algorithm=SHA512&digits=8&period=60';
      Map<String, dynamic> map = qrParser.parseQRCodeToMap(uriWithoutIssuerAndLabel);
      expect(map[URI_LABEL], '');
      expect(map[URI_ISSUER], '');
    });

    test('Test parse issuer from param', () {
      String uriWithIssuerParam = 'otpauth://totp/alice@google.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'
          '&issuer=ACME%20Co&algorithm=SHA512&digits=8&period=60';
      Map<String, dynamic> map = qrParser.parseQRCodeToMap(uriWithIssuerParam);
      expect(map[URI_LABEL], 'alice@google.com');
      expect(map[URI_ISSUER], 'ACME Co');
    });

    test('Test parse issuer from label', () {
      String uriWithIssuer = 'otpauth://totp/Example:alice@google.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'
          '&algorithm=SHA512&digits=8&period=60';
      Map<String, dynamic> map = qrParser.parseQRCodeToMap(uriWithIssuer);
      expect(map[URI_LABEL], 'alice@google.com');
      expect(map[URI_ISSUER], 'Example');
    });

    test('Test parse issuer from label with uri encoding', () {
      String uriWithIssuerAndUriEncoding = 'otpauth://totp/Example%3Aalice@google.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'
          '&algorithm=SHA512&digits=8&period=60';
      Map<String, dynamic> map = qrParser.parseQRCodeToMap(uriWithIssuerAndUriEncoding);
      expect(map[URI_LABEL], 'alice@google.com');
      expect(map[URI_ISSUER], 'Example');
    });

    test('Test parse issuer from param and label', () {
      String uriWithIssuerParamAndIssuer = 'otpauth://totp/Example:alice@google.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'
          '&issuer=ACME%20Co&algorithm=SHA512&digits=8&period=60';
      Map<String, dynamic> map = qrParser.parseQRCodeToMap(uriWithIssuerParamAndIssuer);
      expect(map[URI_LABEL], 'alice@google.com');
      expect(map[URI_ISSUER], 'Example');
    });
  });
}

void _testParseOtpAuth() {
  group('Parse TOTP uri', () {
    const qrParser = QrParser();
    test('Test with wrong uri schema', () {
      expect(
          () => qrParser.parseQRCodeToMap('http://totp/ACME%20Co:john@example.com?'
              'secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co'
              '&algorithm=SHA1&digits=6&period=30'),
          throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('Test with unknown type', () {
      expect(
          () => qrParser.parseQRCodeToMap('otpauth://asdf/ACME%20Co:john@example.com?'
              'secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co'
              '&algorithm=SHA1&digits=6&period=30'),
          throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('Test with missing type', () {
      expect(
          () => qrParser.parseQRCodeToMap('otpauth:///ACME%20Co:john@example.com?'
              'secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co'
              '&algorithm=SHA1&digits=6&period=30'),
          throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('Test missing algorithm', () {
      Map<String, dynamic> map = qrParser.parseQRCodeToMap('otpauth://totp/ACME%20Co:john@example.com?'
          'secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co'
          '&digits=6&period=30');
      expect(map[URI_ALGORITHM], 'SHA1'); // This is the default value
    });

    test('Test unknown algorithm', () {
      expect(
          () => qrParser.parseQRCodeToMap('otpauth://totp/ACME%20Co:john@example.com?'
              'secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co'
              '&algorithm=BubbleSort&digits=6&period=30'),
          throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('Test missing digits', () {
      Map<String, dynamic> map = qrParser.parseQRCodeToMap('otpauth://totp/ACME%20Co:john@example.com?'
          'secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co'
          '&period=30');
      expect(map[URI_DIGITS], 6); // This is the default value
    });

    // At least the library used to calculate otp values does not support other number of digits.
    test('Test invalid number of digits', () {
      expect(
          () => qrParser.parseQRCodeToMap('otpauth://totp/ACME%20Co:john@example.com?'
              'secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co'
              '&algorithm=SHA1&digits=66&period=30'),
          throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('Test invalid characters for digits', () {
      expect(
          () => qrParser.parseQRCodeToMap('otpauth://totp/ACME%20Co:john@example.com?'
              'secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co'
              '&algorithm=SHA1&digits=aA&period=30'),
          throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('Test missing secret', () {
      expect(
          () => qrParser.parseQRCodeToMap('otpauth://totp/ACME%20Co:john@example.com?'
              'issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30'),
          throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('Test invalid secret', () {
      expect(
          () => qrParser.parseQRCodeToMap('otpauth://totp/ACME%20Co:john@example.com?'
              'secret=ÖÖ&issuer=ACME%20Co&algorithm=SHA1&digits=6'
              '&period=30'),
          throwsA(const TypeMatcher<ArgumentError>()));
    });

    // TOTP specific
    test('Test missing period', () {
      Map<String, dynamic> map = qrParser.parseQRCodeToMap('otpauth://totp/ACME%20Co:john@example.com?'
          'secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co'
          '&algorithm=SHA1&digits=6');
      expect(map[URI_PERIOD], 30);
    });

    test('Test invalid characters for period', () {
      expect(
          () => qrParser.parseQRCodeToMap('otpauth://totp/ACME%20Co:john@example.com?'
              'secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co'
              '&algorithm=SHA1&digits=6&period=aa'),
          throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('Test longer values for period', () {
      Map<String, dynamic> map = qrParser.parseQRCodeToMap('otpauth://totp/ACME%20Co:john@example.com?'
          'secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co'
          '&algorithm=SHA1&digits=6&period=124432');

      expect(map[URI_PERIOD], 124432);
    });

    test('Test valid totp uri', () {
      Map<String, dynamic> map = qrParser.parseQRCodeToMap('otpauth://totp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'
          '&issuer=ACME%20Co&algorithm=SHA512&digits=8&period=60');
      expect(map[URI_LABEL], 'Kitchen');
      expect(map[URI_ALGORITHM], 'SHA512');
      expect(map[URI_DIGITS], 8);
      expect(map[URI_SECRET], decodeSecretToUint8('HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ', Encodings.base32));
      expect(map[URI_PERIOD], 60);
    });
  });
  group('Parse HOTP uri', () {
    const qrParser = QrParser();
    // HOTP specific
    test('Test with missing counter', () {
      expect(
          () => qrParser.parseQRCodeToMap('otpauth://hotp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'
              '&issuer=ACME%20Co&algorithm=SHA256&digits=8'),
          throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('Test with invalid counter', () {
      expect(
          () => qrParser.parseQRCodeToMap('otpauth://hotp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'
              '&issuer=ACME%20Co&algorithm=SHA256&digits=8&counter=aa'),
          throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('Test valid hotp uri', () {
      Map<String, dynamic> map = qrParser.parseQRCodeToMap('otpauth://hotp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ'
          '&issuer=ACME%20Co&algorithm=SHA256&digits=8&counter=5');
      expect(map[URI_LABEL], 'Kitchen');
      expect(map[URI_ALGORITHM], 'SHA256');
      expect(map[URI_DIGITS], 8);
      expect(map[URI_SECRET], decodeSecretToUint8('HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ', Encodings.base32));
      expect(map[URI_COUNTER], 5);
    });
  });
  group('2 Step Rollout', () {
    const qrParser = QrParser();
    test('is2StepURI', () {
      expect(
        qrParser.is2StepURI(Uri.parse(
            'otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE&counter=1&digits=6&issuer=privacyIDEA&2step_salt=8&2step_output=20')),
        true,
      );
      expect(
        qrParser.is2StepURI(Uri.parse(
            'otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE&counter=1&digits=6&issuer=privacyIDEA&2step_salt=8&2step_difficulty=10000')),
        true,
      );
      expect(
          qrParser.is2StepURI(Uri.parse(
              'otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE&counter=1&digits=6&issuer=privacyIDEA&2step_output=20&2step_difficulty=10000')),
          true);
      expect(
        qrParser
            .is2StepURI(Uri.parse('otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE&counter=1&digits=6&issuer=privacyIDEA&2step_salt=8')),
        true,
      );

      expect(
        qrParser.is2StepURI(Uri.parse('otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE&counter=1&digits=6&issuer=privacyIDEA')),
        false,
      );
    });
  });
}
