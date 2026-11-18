/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/push_key_algorithm.dart';

void main() {
  group('PushKeyAlgorithm', () {
    test(
      'firstSupported takes the first algorithm of the list the app knows',
      () {
        expect(
          PushKeyAlgorithm.firstSupported('secp256r1,rsa_4096'),
          PushKeyAlgorithm.secp256r1,
        );
        expect(
          PushKeyAlgorithm.firstSupported('rsa_4096,secp256r1'),
          PushKeyAlgorithm.rsa4096,
        );
        expect(
          PushKeyAlgorithm.firstSupported('ed25519,secp256r1'),
          PushKeyAlgorithm.secp256r1,
          reason: 'an algorithm the app does not know is skipped',
        );
        expect(
          PushKeyAlgorithm.firstSupported(' secp256r1 , rsa_4096'),
          PushKeyAlgorithm.secp256r1,
        );
        expect(PushKeyAlgorithm.firstSupported('ed25519'), isNull);
        expect(PushKeyAlgorithm.firstSupported(''), isNull);
        expect(PushKeyAlgorithm.firstSupported(null), isNull);
        expect(
          PushKeyAlgorithm.firstSupported('prime256v1'),
          isNull,
          reason: 'only the names of the protocol count',
        );
      },
    );

    test('the wire names are the protocol vocabulary', () {
      expect(PushKeyAlgorithm.rsa4096.wireName, 'rsa_4096');
      expect(PushKeyAlgorithm.secp256r1.wireName, 'secp256r1');
    });
  });
}
