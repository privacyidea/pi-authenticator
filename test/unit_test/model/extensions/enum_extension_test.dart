import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/extensions/enum_extension.dart';

void main() {
  _testEnumExtension();
}

enum _TestEnum { entryOne, entryTwo, entryThree }

void _testEnumExtension() {
  group('Enum Extension', () {
    group('isName', () {
      test('caseSensitive', () {
        expect(
          _TestEnum.entryOne.isName('entryOne', caseSensitive: true),
          true,
        );
        expect(
          _TestEnum.entryOne.isName('entryone', caseSensitive: true),
          false,
        );
        expect(
          _TestEnum.entryOne.isName('entryTwo', caseSensitive: true),
          false,
        );
        expect(
          _TestEnum.entryTwo.isName('entryTwo', caseSensitive: true),
          true,
        );
        expect(
          _TestEnum.entryTwo.isName('entrytwo', caseSensitive: true),
          false,
        );
        expect(
          _TestEnum.entryTwo.isName('entryThree', caseSensitive: true),
          false,
        );
        expect(
          _TestEnum.entryThree.isName('entryThree', caseSensitive: true),
          true,
        );
        expect(
          _TestEnum.entryThree.isName('entrythree', caseSensitive: true),
          false,
        );
      });
      test('caseInsensitive', () {
        expect(_TestEnum.entryOne.isName('entryone'), true);
        expect(_TestEnum.entryOne.isName('ENTRYONE'), true);
        expect(_TestEnum.entryOne.isName('entryTwo'), false);
        expect(_TestEnum.entryTwo.isName('entrytwo'), true);
        expect(_TestEnum.entryTwo.isName('ENTRYTWO'), true);
        expect(_TestEnum.entryTwo.isName('entryThree'), false);
        expect(_TestEnum.entryThree.isName('entrythree'), true);
        expect(_TestEnum.entryThree.isName('ENTRYTHREE'), true);
      });
    });
  });
}
