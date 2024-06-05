import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/version.dart';

void main() {
  _testTokenVersion();
}

void _testTokenVersion() {
  group('Token Version Test', () {
    group('serialzation', () {
      test('toJson', () {
        // Arrange
        const version = Version(1, 2, 3);
        // Act
        final result = version.toJson();
        // Assert
        expect(result, {'major': 1, 'minor': 2, 'patch': 3});
      });
      test('fromJson', () {
        // Arrange
        const json = {'major': 1, 'minor': 2, 'patch': 3};
        // Act
        final result = Version.fromJson(json);
        // Assert
        expect(result, const Version(1, 2, 3));
      });
    });
  });
}
