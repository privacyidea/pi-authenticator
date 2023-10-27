/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

void main() {
  _testInsertCharAt();
  _testSplitPeriodically();
  _testMapStringToAlgorithm();
  _testEnumAsString();
  _testEqualsIgnoreCase();
}

void _testInsertCharAt() {
  const String str = 'ABCD';

  group('insertCharAt', () {
    test('Insert at start', () => expect('XABCD', insertCharAt(str, 'X', 0)));

    test('Insert at end', () => expect('ABCDX', insertCharAt(str, 'X', str.length)));

    test('Insert at end', () => expect('ABXCD', insertCharAt(str, 'X', 2)));
  });
}

void _testSplitPeriodically() {
  const String str = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  group('splitPeriodically', () {
    test('Split every -1', () => expect(splitPeriodically(str, -1), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'));
    test('Split every 0', () => expect(splitPeriodically(str, 0), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'));
    test('Split every 1', () => expect(splitPeriodically(str, 1), 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'));
    test('Split every 2', () => expect('AB CD EF GH IJ KL MN OP QR ST UV WX YZ', splitPeriodically(str, 2)));
    test('Split every 3', () => expect('ABC DEF GHI JKL MNO PQR STU VWX YZ', splitPeriodically(str, 3)));
    test('Split every 7', () => expect('ABCDEFG HIJKLMN OPQRSTU VWXYZ', splitPeriodically(str, 7)));
    test('Split every 12', () => expect('ABCDEFGHIJKL MNOPQRSTUVWX YZ', splitPeriodically(str, 12)));
  });
}

void _testMapStringToAlgorithm() {
  group('mapStringToAlgorithm', () {
    test('Test SHA1', () => expect(mapStringToAlgorithm('SHA1'), Algorithms.SHA1));
    test('Test SHA256', () => expect(mapStringToAlgorithm('SHA256'), Algorithms.SHA256));
    test('Test SHA512', () => expect(mapStringToAlgorithm('SHA512'), Algorithms.SHA512));
    test('Test invalid', () => expect(() => mapStringToAlgorithm('invalid'), throwsArgumentError));
  });
}

void _testEnumAsString() {
  group('enumAsString', () {
    test('Test SHA1', () => expect(enumAsString(Algorithms.SHA1), 'SHA1'));
    test('Test SHA256', () => expect(enumAsString(Algorithms.SHA256), 'SHA256'));
    test('Test SHA512', () => expect(enumAsString(Algorithms.SHA512), 'SHA512'));
  });
}

void _testEqualsIgnoreCase() {
  group('equalsIgnoreCase', () {
    test('Test different case', () => expect(equalsIgnoreCase('ABC', 'abc'), true));
    test('Test same case', () => expect(equalsIgnoreCase('ABC', 'ABC'), true));
    test('Test not equal same case', () => expect(equalsIgnoreCase('ABC', 'AB'), false));
    test('Test not equal different case', () => expect(equalsIgnoreCase('ABC', 'ab'), false));
  });
}
