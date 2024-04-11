import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';

void main() {
  _testPushRequest();
}

void _testPushRequest() {
  group('Push Request', () {
    group('creation', () {
      test('constructor', () {
        // Arrange
        final request = PushRequest(
          title: 'title',
          question: 'question',
          uri: Uri.parse('https://example.com'),
          nonce: 'nonce',
          sslVerify: true,
          id: 1,
          expirationDate: DateTime.now(),
        );
        // Assert
        expect(request.title, 'title');
        expect(request.question, 'question');
        expect(request.uri, Uri.parse('https://example.com'));
        expect(request.nonce, 'nonce');
        expect(request.sslVerify, true);
        expect(request.id, 1);
        expect(request.expirationDate, isA<DateTime>());
        expect(request.serial, '');
        expect(request.signature, '');
        expect(request.accepted, null);
      });
      test('copyWith', () {
        final dateTimeAfter = DateTime.now().add(const Duration(days: 1));
        // Arrange
        final request = PushRequest(
          title: 'title',
          question: 'question',
          uri: Uri.parse('https://example.com'),
          nonce: 'nonce',
          sslVerify: true,
          id: 1,
          expirationDate: DateTime.now(),
        );
        // Act
        final copy = request.copyWith(
          title: 'new title',
          question: 'new question',
          uri: Uri.parse('https://new.example.com'),
          nonce: 'new nonce',
          sslVerify: false,
          id: 2,
          expirationDate: dateTimeAfter,
          serial: 'serial',
          signature: 'signature',
          accepted: true,
        );
        // Assert
        expect(copy.title, 'new title');
        expect(copy.question, 'new question');
        expect(copy.uri, Uri.parse('https://new.example.com'));
        expect(copy.nonce, 'new nonce');
        expect(copy.sslVerify, false);
        expect(copy.id, 2);
        expect(copy.expirationDate, equals(dateTimeAfter));
        expect(copy.serial, 'serial');
        expect(copy.signature, 'signature');
        expect(copy.accepted, true);
      });
    });
  });
}
