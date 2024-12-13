/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_container_processor.dart';

void main() {
  _testTokenContainerProcessor();
}

void _testTokenContainerProcessor() {
  final processor = TokenContainerProcessor();
  group('TokenContainerProcessor', () {
    group('processUri', () {
      test('valid uri', () async {
        final uriString = "pia://container/SMPH00067A2F"
            "?issuer=privacyIDEA"
            "&ttl=10"
            "&nonce=b33d3a11c8d1b45f19640035e27944ccf0b2383d"
            "&time=2024-12-06T11%3A14%3A26.885409%2B00%3A00"
            "&url=http://192.168.0.230:5000/"
            "&serial=SMPH00067A2F"
            "&key_algorithm=secp384r1"
            "&hash_algorithm=SHA256"
            "&ssl_verify=False"
            "&passphrase=";
        final uri = Uri.parse(uriString);
        final result = await processor.processUri(uri);
        expect(result?.length, 1);
        expect(result![0].isSuccess, true);
        expect(result[0].asSuccess, isNotNull);
        final container = result[0].asSuccess!.resultData;
        expect(container, isA<TokenContainerUnfinalized>());
        expect(container.issuer, "privacyIDEA");
        expect((container as TokenContainerUnfinalized).ttl, Duration(minutes: 10));
        expect(container.nonce, "b33d3a11c8d1b45f19640035e27944ccf0b2383d");
        expect(container.timestamp, DateTime.parse("2024-12-06T11:14:26.885409+00:00"));
        expect(container.serverUrl, Uri.parse("http://192.168.0.230:5000/"));
        expect(container.serial, "SMPH00067A2F");
        expect(container.ecKeyAlgorithm, EcKeyAlgorithm.secp384r1);
        expect(container.hashAlgorithm, Algorithms.SHA256);
        expect(container.sslVerify, false);
        expect(container.passphraseQuestion, "");
      });
      test('other values', () async {
        final uriString = "pia://container/SMPH00067A2F2"
            "?issuer=privacyIDEA2"
            "&ttl=100"
            "&nonce=b33d3a11c8d1b45f19640035e27944ccf0b2383d22"
            "&time=2024-12-07T11%3A14%3A26.885409%2B00%3A00"
            "&url=http://192.168.0.231:5000/"
            "&serial=SMPH00067A2F2"
            "&key_algorithm=secp112r1"
            "&hash_algorithm=SHA1"
            "&ssl_verify=True"
            "&passphrase=Enter%20your%20password";
        final uri = Uri.parse(uriString);
        final result = await processor.processUri(uri);
        expect(result?.length, 1);
        expect(result![0].isSuccess, true);
        expect(result[0].asSuccess, isNotNull);
        final container = result[0].asSuccess!.resultData;
        expect(container, isA<TokenContainerUnfinalized>());
        expect(container.issuer, "privacyIDEA2");
        expect((container as TokenContainerUnfinalized).ttl, Duration(minutes: 100));
        expect(container.nonce, "b33d3a11c8d1b45f19640035e27944ccf0b2383d22");
        expect(container.timestamp, DateTime.parse("2024-12-07T11:14:26.885409+00:00"));
        expect(container.serverUrl, Uri.parse("http://192.168.0.231:5000/"));
        expect(container.serial, "SMPH00067A2F2");
        expect(container.ecKeyAlgorithm, EcKeyAlgorithm.secp112r1);
        expect(container.hashAlgorithm, Algorithms.SHA1);
        expect(container.sslVerify, true);
        expect(container.passphraseQuestion, "Enter your password");
      });
      test('missing nonce', () {
        final uriString = "pia://container/SMPH00067A2F2"
            "?issuer=privacyIDEA2"
            "&ttl=100"
            "&time=2024-12-07T11%3A14%3A26.885409%2B00%3A00"
            "&url=http://192.168.0.231:5000/"
            "&serial=SMPH00067A2F2"
            "&key_algorithm=secp112r1"
            "&hash_algorithm=SHA1"
            "&ssl_verify=True"
            "&passphrase=Enter%20your%20password";
        final uri = Uri.parse(uriString);
        expect(processor.processUri(uri), completion(isNull));
      });
    });
  });
}
