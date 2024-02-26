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
      const buffer = CustomIntBuffer(maxSize: 30);

      expect(buffer.maxSize, 30);
      expect(buffer.length, 0);

      buffer.put(1);
      buffer.put(2);
      buffer.put(3);

      expect(buffer.length, 3);

      expect(buffer.contains(1), true);
      expect(buffer.contains(2), true);
      expect(buffer.contains(3), true);
      expect(buffer.contains(4), false);

      for (int i = 3; i < buffer.maxSize; i++) {
        buffer.put(-1);
      }

      buffer.put(4);

      expect(buffer.length, 30);
      expect(buffer.maxSize, 30);

      expect(buffer.contains(1), false);
      expect(buffer.contains(2), true);
      expect(buffer.contains(3), true);
      expect(buffer.contains(4), true);
    });
  });
}
