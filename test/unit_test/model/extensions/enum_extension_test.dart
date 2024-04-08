import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/extensions/enum_extension.dart';

void main() {
  _testEnumExtension();
}

enum _TestEnum {
  entryOne,
  entryTwo,
  entryThree,
}

void _testEnumExtension() {
  group('Enum Extension', () {
    group('isName', () {
      test('caseSensitive', () {
        expect(_TestEnum.entryOne.isName('entryOne'), true);
        expect(_TestEnum.entryOne.isName('entryone'), false);
        expect(_TestEnum.entryOne.isName('entryTwo'), false);
        expect(_TestEnum.entryTwo.isName('entryTwo'), true);
        expect(_TestEnum.entryTwo.isName('entrytwo'), false);
        expect(_TestEnum.entryTwo.isName('entryThree'), false);
        expect(_TestEnum.entryThree.isName('entryThree'), true);
        expect(_TestEnum.entryThree.isName('entrythree'), false);
      });
      test('caseInsensitive', () {
        expect(_TestEnum.entryOne.isName('entryone', caseSensitive: false), true);
        expect(_TestEnum.entryOne.isName('ENTRYONE', caseSensitive: false), true);
        expect(_TestEnum.entryOne.isName('entryTwo', caseSensitive: false), false);
        expect(_TestEnum.entryTwo.isName('entrytwo', caseSensitive: false), true);
        expect(_TestEnum.entryTwo.isName('ENTRYTWO', caseSensitive: false), true);
        expect(_TestEnum.entryTwo.isName('entryThree', caseSensitive: false), false);
        expect(_TestEnum.entryThree.isName('entrythree', caseSensitive: false), true);
        expect(_TestEnum.entryThree.isName('ENTRYTHREE', caseSensitive: false), true);
      });
    });
  });
}
