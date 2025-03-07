import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/extensions/int_extension.dart';

void main() {
  _testIntExtension();
}

void _testIntExtension() {
  group('int extension', () {
    group('bytes', () {
      test('min int value', () => expect((-0x8000000000000000).bytes, [128, 0, 0, 0, 0, 0, 0, 0]));
      test('zero', () => expect(0.bytes, [0, 0, 0, 0, 0, 0, 0, 0]));
      test('max int value', () => expect(0x7FFFFFFFFFFFFFFF.bytes, [127, 255, 255, 255, 255, 255, 255, 255]));
      test('20 different int values', () {
        expect(8254763140651989312.bytes, [114, 142, 207, 87, 63, 140, 185, 64]);
        expect(6867929122700968103.bytes, [95, 79, 201, 38, 53, 38, 192, 167]);
        expect(6658070822668124012.bytes, [92, 102, 56, 35, 34, 134, 191, 108]);
        expect(6233195836444142436.bytes, [86, 128, 194, 150, 158, 178, 107, 100]);
        expect(5665252064165200114.bytes, [78, 159, 4, 188, 143, 157, 128, 242]);
        expect(3836812696023088046.bytes, [53, 63, 24, 209, 152, 42, 59, 174]);
        expect(4217815205603023728.bytes, [58, 136, 176, 149, 34, 53, 155, 112]);
        expect(1859730558376856620.bytes, [25, 207, 23, 22, 237, 253, 204, 44]);
        expect((-1341891893474570224).bytes, [237, 96, 164, 110, 186, 120, 208, 16]);
        expect((-1947790576164582988).bytes, [228, 248, 14, 202, 114, 219, 73, 180]);
        expect((-5204853149876150168).bytes, [183, 196, 165, 162, 253, 143, 32, 104]);
        expect((-5765512478999408848).bytes, [175, 252, 200, 242, 133, 40, 143, 48]);
        expect((-6273311771369426144).bytes, [168, 240, 184, 46, 110, 63, 179, 32]);
        expect((-6384342681465787276).bytes, [167, 102, 66, 40, 42, 221, 236, 116]);
        expect((-6805707171905842232).bytes, [161, 141, 69, 98, 165, 57, 83, 200]);
        expect((-7708924412950309696).bytes, [149, 4, 102, 23, 13, 194, 148, 192]);
        expect((-7731444997339132318).bytes, [148, 180, 99, 188, 229, 33, 78, 98]);
        expect((-7855692611255695686).bytes, [146, 250, 249, 48, 249, 113, 134, 186]);
        expect((-8557951589827587072).bytes, [137, 60, 12, 94, 251, 86, 84, 0]);
        expect((-9153687162235632943).bytes, [128, 247, 146, 6, 53, 228, 66, 209]);
      });
    });
    test('digits', () {
      expect(0.digits, [0]);
      expect(1.digits, [1]);
      expect(9.digits, [9]);
      expect(10.digits, [0, 1]);
      expect(11.digits, [1, 1]);
      expect(99.digits, [9, 9]);
      expect(100.digits, [0, 0, 1]);
      expect(101.digits, [1, 0, 1]);
      expect(999.digits, [9, 9, 9]);
      expect(1000.digits, [0, 0, 0, 1]);
      expect(1001.digits, [1, 0, 0, 1]);
      expect(9999.digits, [9, 9, 9, 9]);
      expect(10000.digits, [0, 0, 0, 0, 1]);
      expect(10001.digits, [1, 0, 0, 0, 1]);
      expect(99999.digits, [9, 9, 9, 9, 9]);
      expect(100000.digits, [0, 0, 0, 0, 0, 1]);
      expect(100001.digits, [1, 0, 0, 0, 0, 1]);
      expect(999999.digits, [9, 9, 9, 9, 9, 9]);
      expect(1000000.digits, [0, 0, 0, 0, 0, 0, 1]);
      expect(1000001.digits, [1, 0, 0, 0, 0, 0, 1]);
      expect(9999999.digits, [9, 9, 9, 9, 9, 9, 9]);
      expect(10000000.digits, [0, 0, 0, 0, 0, 0, 0, 1]);
      expect(10000001.digits, [1, 0, 0, 0, 0, 0, 0, 1]);
      expect(99999999.digits, [9, 9, 9, 9, 9, 9, 9, 9]);
    });
    test('pow', () {
      expect(0.pow(0), 1);
      expect(0.pow(1), 0);
      expect(1.pow(0), 1);
      expect(1.pow(1), 1);
      expect(2.pow(0), 1);
      expect(2.pow(1), 2);
      expect(2.pow(2), 4);
      expect(3.pow(1), 3);
      expect(3.pow(2), 9);
      expect(3.pow(3), 27);
      expect(4.pow(2), 16);
      expect(4.pow(3), 64);
      expect(4.pow(4), 256);
      expect(5.pow(3), 125);
      expect(5.pow(4), 625);
      expect(5.pow(5), 3125);
      expect(6.pow(4), 1296);
      expect(6.pow(5), 7776);
      expect(6.pow(6), 46656);
      expect(7.pow(5), 16807);
      expect(7.pow(6), 117649);
      expect(7.pow(7), 823543);
      expect(8.pow(6), 262144);
      expect(8.pow(7), 2097152);
      expect(8.pow(8), 16777216);
      expect(9.pow(7), 4782969);
      expect(9.pow(8), 43046721);
      expect(9.pow(9), 387420489);
      expect(10.pow(8), 100000000);
      expect(10.pow(9), 1000000000);
      expect(10.pow(10), 10000000000);
    });
  });
}
