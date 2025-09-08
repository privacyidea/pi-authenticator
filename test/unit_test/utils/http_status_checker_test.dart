import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/http_status_checker.dart';

void main() {
  group('HttpStatusChecker', () {
    test('isInformational returns true for 1xx codes', () {
      expect(HttpStatusChecker.isInformational(100), isTrue);
      expect(HttpStatusChecker.isInformational(150), isTrue);
      expect(HttpStatusChecker.isInformational(199), isTrue);
      expect(HttpStatusChecker.isInformational(200), isFalse);
      expect(HttpStatusChecker.isInformational(99), isFalse);
    });

    test('isSuccessful returns true for 2xx codes', () {
      expect(HttpStatusChecker.isSuccessful(200), isTrue);
      expect(HttpStatusChecker.isSuccessful(250), isTrue);
      expect(HttpStatusChecker.isSuccessful(299), isTrue);
      expect(HttpStatusChecker.isSuccessful(199), isFalse);
      expect(HttpStatusChecker.isSuccessful(300), isFalse);
    });

    test('isRedirect returns true for 3xx codes', () {
      expect(HttpStatusChecker.isRedirect(300), isTrue);
      expect(HttpStatusChecker.isRedirect(350), isTrue);
      expect(HttpStatusChecker.isRedirect(399), isTrue);
      expect(HttpStatusChecker.isRedirect(299), isFalse);
      expect(HttpStatusChecker.isRedirect(400), isFalse);
    });

    test('isClientError returns true for 4xx codes', () {
      expect(HttpStatusChecker.isClientError(400), isTrue);
      expect(HttpStatusChecker.isClientError(450), isTrue);
      expect(HttpStatusChecker.isClientError(499), isTrue);
      expect(HttpStatusChecker.isClientError(399), isFalse);
      expect(HttpStatusChecker.isClientError(500), isFalse);
    });

    test('isServerError returns true for 5xx codes', () {
      expect(HttpStatusChecker.isServerError(500), isTrue);
      expect(HttpStatusChecker.isServerError(550), isTrue);
      expect(HttpStatusChecker.isServerError(599), isTrue);
      expect(HttpStatusChecker.isServerError(499), isFalse);
      expect(HttpStatusChecker.isServerError(600), isFalse);
    });

    test('isInvalidStatus returns true for codes < 100 or >= 600', () {
      expect(HttpStatusChecker.isInvalidStatus(99), isTrue);
      expect(HttpStatusChecker.isInvalidStatus(600), isTrue);
      expect(HttpStatusChecker.isInvalidStatus(700), isTrue);
      expect(HttpStatusChecker.isInvalidStatus(100), isFalse);
      expect(HttpStatusChecker.isInvalidStatus(599), isFalse);
    });

    test('isError returns true for 4xx, 5xx, and invalid codes', () {
      expect(HttpStatusChecker.isError(404), isTrue); // client error
      expect(HttpStatusChecker.isError(500), isTrue); // server error
      expect(HttpStatusChecker.isError(99), isTrue); // invalid
      expect(HttpStatusChecker.isError(600), isTrue); // invalid
      expect(HttpStatusChecker.isError(200), isFalse); // success
      expect(HttpStatusChecker.isError(301), isFalse); // redirect
    });
  });
}
