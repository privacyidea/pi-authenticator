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

  group('Secure repository prefixes', () {
    // These decide where entries live on disk. Changing one orphans everything
    // already stored under the old value, so they are pinned to their literals.
    test('are unchanged', () {
      expect(SECURE_REPO_PREFIX_TOKEN, 'app_v4_token');
      expect(SECURE_REPO_PREFIX_TOKEN_CONTAINER, 'app_v4_token_container');
      expect(SECURE_REPO_PREFIX_PUSH_REQUEST, 'app_v4_push_request');
      expect(SECURE_REPO_PREFIX_FIREBASE, 'app_v4_firebase');
      expect(SECURE_REPO_PREFIX_LEGACY_TOKEN_CONTAINER, 'containerCredentials');
    });

    test('the container one nests below the token one', () {
      // The reason SecureTokenRepository has to exclude it: every container key
      // also starts with the token prefix.
      expect(
        SECURE_REPO_PREFIX_TOKEN_CONTAINER.startsWith(
          '${SECURE_REPO_PREFIX_TOKEN}_',
        ),
        isTrue,
      );
    });

    test('no other pair nests', () {
      const others = [
        SECURE_REPO_PREFIX_PUSH_REQUEST,
        SECURE_REPO_PREFIX_FIREBASE,
      ];
      for (final prefix in others) {
        expect(prefix.startsWith('${SECURE_REPO_PREFIX_TOKEN}_'), isFalse);
      }
    });
  });
}
