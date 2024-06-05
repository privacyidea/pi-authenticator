import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';

void main() {
  _testEncodingsExtension();
}

void _testEncodingsExtension() {
  group('Encodings Extension', () {
    group('encode', () {
      group('valid', () {
        test('base32', () => expect(Encodings.base32.encode(Uint8List.fromList([153, 37, 57])), equals('TESTS===')));
        test('hex', () => expect(Encodings.hex.encode(Uint8List.fromList([153, 37, 57])), equals('992539')));
        test('none', () => expect(Encodings.none.encode(Uint8List.fromList([116, 101, 115, 116, 115])), equals('tests')));
      });

      group('invalid', () {
        test('none', () => expect(() => Encodings.none.encode(Uint8List.fromList([153, 37, 57])), throwsException));
      });
    });
    group('encodeStringTo', () {
      test('base32 to hex', () => expect(Encodings.base32.encodeStringTo(Encodings.hex, 'TESTS==='), equals('992539')));
      test('hex to base32', () => expect(Encodings.hex.encodeStringTo(Encodings.base32, '992539'), equals('TESTS===')));
    });

    group('decode', () {
      group('valid', () {
        test('base32', () => expect(Encodings.base32.decode('TESTS==='), equals(Uint8List.fromList([153, 37, 57]))));
        test('hex', () => expect(Encodings.hex.decode('992539'), equals(Uint8List.fromList([153, 37, 57]))));
        test('none', () => expect(Encodings.none.decode('tests'), equals(Uint8List.fromList([116, 101, 115, 116, 115]))));
      });

      group('invalid', () {
        test('base32', () => expect(() => Encodings.base32.decode('TESTS+++'), throwsException));
        test('hex', () => expect(() => Encodings.hex.decode('abcdefg'), throwsException));
        // Every utf8 string has a valid binary representation
      });
    });

    group('isValidEncoding', () {
      test('base32', () => expect(Encodings.base32.isValidEncoding('TESTS==='), isTrue));
      test('hex', () => expect(Encodings.hex.isValidEncoding('992539'), isTrue));
      test('none', () => expect(Encodings.none.isValidEncoding('tests'), isTrue));
    });

    group('isInvalidEncoding', () {
      test('base32', () => expect(Encodings.base32.isInvalidEncoding('TESTS==='), isFalse));
      test('hex', () => expect(Encodings.hex.isInvalidEncoding('992539'), isFalse));
      // Every utf8 string has a valid binary representation
    });

    group('tryDecode', () {
      group('valid', () {
        test('base32', () => expect(Encodings.base32.tryDecode('TESTS==='), equals(Uint8List.fromList([153, 37, 57]))));
        test('hex', () => expect(Encodings.hex.tryDecode('992539'), equals(Uint8List.fromList([153, 37, 57]))));
        test('none', () => expect(Encodings.none.tryDecode('tests'), equals(Uint8List.fromList([116, 101, 115, 116, 115]))));
      });

      group('invalid', () {
        test('base32', () => expect(Encodings.base32.tryDecode('TESTS+++'), isNull));
        test('hex', () => expect(Encodings.hex.tryDecode('abcdefg'), isNull));
        // Every utf8 string has a valid binary representation
      });
    });

    group('tryEncode', () {
      group('valid', () {
        test('base32', () => expect(Encodings.base32.tryEncode(Uint8List.fromList([153, 37, 57])), equals('TESTS===')));
        test('hex', () => expect(Encodings.hex.tryEncode(Uint8List.fromList([153, 37, 57])), equals('992539')));
        test('none', () => expect(Encodings.none.tryEncode(Uint8List.fromList([116, 101, 115, 116, 115])), equals('tests')));
      });
      group('invalid', () {
        // Every binary data can be encoded to base32 and hex
        test('none', () => expect(Encodings.none.tryEncode(Uint8List.fromList([153, 37, 57])), isNull));
      });
    });
  });
}
