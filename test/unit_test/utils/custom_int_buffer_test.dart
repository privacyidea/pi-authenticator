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
import 'package:privacyidea_authenticator/utils/custom_int_buffer.dart';

void main() {
  verifyCustomStringBufferWorks();
}

void verifyCustomStringBufferWorks() {
  group('test custom string buffer', () {
    test('put elements in', () {
      final buffer0_30 = CustomIntBuffer(maxSize: 30);

      expect(buffer0_30.maxSize, 30);
      expect(buffer0_30.length, 0);

      final buffer3_30 = buffer0_30.putList([1, 2, 3]);

      expect(buffer3_30.length, 3);

      expect(buffer3_30.contains(1), true);
      expect(buffer3_30.contains(2), true);
      expect(buffer3_30.contains(3), true);
      expect(buffer3_30.contains(4), false);

      final values = List.generate(buffer3_30.maxSize - buffer3_30.length, (index) => 0 - index); // 27 elements

      final buffer30_30 = buffer3_30.putList(values); // full buffer 30/30

      final overflowBuffer = buffer30_30.put(4); // 4 is added, 1 is removed

      expect(overflowBuffer.length, 30);
      expect(overflowBuffer.maxSize, 30);

      expect(overflowBuffer.contains(1), false);
      expect(overflowBuffer.contains(2), true);
      expect(overflowBuffer.contains(3), true);
      expect(overflowBuffer.contains(4), true);
    });
  });
}
