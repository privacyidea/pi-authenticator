import 'dart:typed_data';

class Uint8Buffer {
  int currentPos = 0;
  Uint8List data;
  Uint8Buffer({required this.data});
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
}
