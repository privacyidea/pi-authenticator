import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/encryption/uint_8_buffer.dart';

void main() {
  _testUint8Buffer();
}

void _testUint8Buffer() {
  group('Uint 8 Buffer', () {
    test('fromList', () {
      final list = [1, 2, 3, 4, 5];
      final buffer = Uint8Buffer.fromList(list);
      expect(buffer.data, equals(Uint8List.fromList(list)));
    });

    test('writeBytes', () {
      final list = [1, 2, 3, 4, 5];
      final buffer = Uint8Buffer.fromList(list);
      final list2 = [6, 7, 8, 9, 10];
      buffer.writeBytes(Uint8List.fromList(list2));
      expect(buffer.data, equals(Uint8List.fromList([...list, ...list2])));
    });

    test('readBytes', () {
      final list = [1, 2, 3, 4, 5];
      final buffer = Uint8Buffer.fromList(list);
      final bytes = buffer.readBytes(3);
      expect(bytes, equals(Uint8List.fromList([1, 2, 3])));
      expect(buffer.currentPos, equals(3));
    });

    test('readBytes more than available', () {
      final list = [1, 2, 3, 4, 5];
      final buffer = Uint8Buffer.fromList(list);
      final bytes = buffer.readBytes(10);
      expect(bytes, equals(Uint8List.fromList([1, 2, 3, 4, 5])));
      expect(buffer.currentPos, equals(5));
    });

    test('readBytesToEnd with left', () {
      final list = [1, 2, 3, 4, 5];
      final buffer = Uint8Buffer.fromList(list);
      buffer.readBytes(1);
      final bytes = buffer.readBytesToEnd(left: 2);
      expect(bytes, equals(Uint8List.fromList([2, 3])));
      expect(buffer.currentPos, equals(3));
    });

    test('readBytesToEnd without left', () {
      final list = [1, 2, 3, 4, 5];
      final buffer = Uint8Buffer.fromList(list);
      buffer.readBytes(1);
      final bytes = buffer.readBytesToEnd();
      expect(bytes, equals(Uint8List.fromList([2, 3, 4, 5])));
      expect(buffer.currentPos, equals(5));
    });

    test('moveCurrentPos', () {
      final list = [1, 2, 3, 4, 5];
      final buffer = Uint8Buffer.fromList(list);
      buffer.moveCurrentPos(3);
      expect(buffer.currentPos, equals(3));
      final bytes = buffer.readBytesToEnd();
      expect(bytes, equals(Uint8List.fromList([4, 5])));
    });

    test('moveCurrentPos to out of bounds', () {
      final list = [1, 2, 3, 4, 5];
      final buffer = Uint8Buffer.fromList(list);
      buffer.moveCurrentPos(10);
      expect(buffer.currentPos, equals(5));
      final bytes = buffer.readBytesToEnd();
      expect(bytes, equals(Uint8List.fromList([])));
    });
  });
}
/*
  factory Uint8Buffer.fromList(List<int> list) {
    return Uint8Buffer(data: Uint8List.fromList(list));
  }

  /// Writes [bytes] to the buffer
  void writeBytes(Uint8List bytes) {
    data = Uint8List.fromList([...data, ...bytes]);
  }

  /// Reads [length] bytes from the current position
  /// and moves the position forward
  Uint8List readBytes(int length) {
    final bytes = data.sublist(currentPos, currentPos + length);
    currentPos += length;
    return bytes;
  }

  /// Reads all bytes from the current position to the end of the buffer
  /// If [left] is provided, it will leave [left] bytes at the end
  /// and return the rest
  Uint8List readBytesToEnd({int left = 0}) {
    final bytes = data.sublist(currentPos, data.length - left);
    currentPos = data.length - left;
    return bytes;
  }

  /// Moves the current position to [pos]
  void moveCurrentPos(int pos) => currentPos = pos;
 */