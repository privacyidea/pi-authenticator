import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';

void main() {
  group('Identifiers', () {
    test('DEFAULT_SIGNING_ALGORITHM is SHA-256/RSA', () {
      expect(DEFAULT_SIGNING_ALGORITHM, 'SHA-256/RSA');
    });

    test('FIREBASE_TOKEN_ERROR_CODE is defined', () {
      expect(FIREBASE_TOKEN_ERROR_CODE, 'FIREBASE_TOKEN_ERROR_CODE');
    });

    test('GLOBAL_SECURE_REPO_PREFIX_LEGACY is app_v3', () {
      expect(GLOBAL_SECURE_REPO_PREFIX_LEGACY, 'app_v3');
    });

    test('GLOBAL_SECURE_REPO_PREFIX is app_v4', () {
      expect(GLOBAL_SECURE_REPO_PREFIX, 'app_v4');
    });
  });
}
