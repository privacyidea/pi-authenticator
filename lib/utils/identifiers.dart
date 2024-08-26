// ignore_for_file: constant_identifier_names

/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2024 NetKnights GmbH

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

// default email address for crash reports

const defaultCrashReportRecipient = 'app-crash@netknights.it';

// qr codes:
const String URI_ID = 'URI_ID';
const String URI_SERIAL = 'URI_SERIAL';
const String URI_NONCE = 'URI_NONCE';
const String URI_TIMESTAMP = 'URI_TIMESTAMP';
const String URI_FINALIZATION_URL = 'URI_FINALIZATION_URL';
const String URI_KEY_ALGORITHM = 'URI_KEY_ALGORITHM';
const String URI_HASH_ALGORITHM = 'URI_HASH_ALGORITHM';
const String URI_CONTAINER_SERIAL = 'URI_CONTAINER_SERIAL';
const String URI_TYPE = 'URI_TYPE';
const String URI_LABEL = 'URI_LABEL';
const String URI_ALGORITHM = 'URI_ALGORITHM';
const String URI_DIGITS = 'URI_DIGITS';
const String URI_SECRET = 'URI_SECRET'; // Should be Uint8List
const String URI_COUNTER = 'URI_COUNTER';
const String URI_PERIOD = 'URI_PERIOD';
const String URI_ISSUER = 'URI_ISSUER';
const String URI_PIN = 'URI_PIN';
const String URI_IMAGE = 'URI_IMAGE';
const String URI_ORIGIN = 'URI_ORIGIN';

// 2 step:
const String URI_SALT_LENGTH = 'URI_SALT_LENGTH';
const String URI_OUTPUT_LENGTH_IN_BYTES = 'URI_OUTPUT_LENGTH_IN_BYTES';
const String URI_ITERATIONS = 'URI_ITERATIONS';

// push token:
const String URI_ROLLOUT_URL = 'URI_ROLLOUT_URL';
const String URI_TTL = 'URI_TTL';
const String URI_ENROLLMENT_CREDENTIAL = 'URI_ENROLLMENT_CREDENTIAL';
const String URI_SSL_VERIFY = 'URI_SSL_VERIFY';

// Crypto stuff:
const String SIGNING_ALGORITHM = 'SHA-256/RSA';

// Custom error identifiers
const String FIREBASE_TOKEN_ERROR_CODE = 'FIREBASE_TOKEN_ERROR_CODE';

// Push request:
const String PUSH_REQUEST_NONCE = 'nonce'; // 1.
const String PUSH_REQUEST_URL = 'url'; // 2.
const String PUSH_REQUEST_SERIAL = 'serial'; // 3.
const String PUSH_REQUEST_QUESTION = 'question'; // 4.
const String PUSH_REQUEST_TITLE = 'title'; // 5.
const String PUSH_REQUEST_SSL_VERIFY = 'sslverify'; // 6.
const String PUSH_REQUEST_SIGNATURE = 'signature'; // 7.
const String PUSH_REQUEST_ANSWERS = 'require_presence'; // 8.

// Container registration:
const String PUBLIC_SERVER_KEY = 'PUBLIC_SERVER_KEY';
const String URI_PASSPHRASE = 'URI_PASSPHRASE';

const String GLOBAL_SECURE_REPO_PREFIX = 'app_v3_';

void validateMap(Map<String, dynamic> map, Map<String, TypeMatcher> keys) {
  for (String key in keys.keys) {
    final typeMatcher = keys[key]!;
    final mapEntry = map[key];
    if (!typeMatcher.isTypeOf(map[key])) {
      if (mapEntry == null) {
        throw ArgumentError('Map does not contain required key "$key"');
      }
      throw ArgumentError('Map does contain required key "$key" but ${mapEntry.runtimeType} is not a subtype of ${typeMatcher.type}');
    }
  }
}

class TypeMatcher<T> {
  const TypeMatcher();
  bool isTypeOf(dynamic value) => value is T;

  String get type => RegExp('(?<=<).+(?=>)').firstMatch(toString())!.group(0)!;

  @override
  String toString() => runtimeType.toString();

  @override
  bool operator ==(Object other) => other is TypeMatcher<T>;

  @override
  int get hashCode => toString().hashCode;
}
