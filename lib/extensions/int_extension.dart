import 'dart:typed_data';

extension IntExtension on int {
  Uint8List get bytes {
    int long = this;
    final byteArray = Uint8List(8);

    for (var index = byteArray.length - 1; index >= 0; index--) {
      final byte = long & 0xff;
      byteArray[index] = byte;
      long = (long - byte) ~/ 256;
    }
    return byteArray;
  }

  Iterable<int> get digits sync* {
    var number = this;
    do {
      yield number.remainder(10);
      number ~/= 10;
    } while (number != 0);
  }
}
