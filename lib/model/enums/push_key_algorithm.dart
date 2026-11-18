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

import 'package:json_annotation/json_annotation.dart';

/// The key algorithms a push token can be enrolled with.
///
/// [wireName] is the name the enrollment protocol uses, both in the
/// `key_algorithm` list of the enrollment link and in the capabilities the
/// app announces when it enrolls the token. It is also the stored form.
@JsonEnum(valueField: 'wireName')
enum PushKeyAlgorithm {
  rsa4096('rsa_4096'),
  secp256r1('secp256r1');

  final String wireName;

  const PushKeyAlgorithm(this.wireName);

  /// The first algorithm of the comma separated [list] that this app knows,
  /// null if it knows none of them.
  ///
  /// The list is ordered by the server's preference. Names this app does not
  /// know are skipped, so a server may put newer algorithms first.
  static PushKeyAlgorithm? firstSupported(String? list) {
    if (list == null) return null;
    for (final name in list.split(',')) {
      final trimmed = name.trim();
      for (final algorithm in values) {
        if (algorithm.wireName == trimmed) return algorithm;
      }
    }
    return null;
  }
}
