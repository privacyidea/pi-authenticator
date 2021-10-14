/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

// default email address for crash reports
const defaultCrashReportRecipient = 'app-crash@netknights.it';

enum Encodings {
  none,
  base32,
  hex,
}

enum Algorithms {
  SHA1,
  SHA256,
  SHA512,
}

enum TokenTypes {
  HOTP,
  TOTP,
  PIPUSH,
}

// qr codes:
const String URI_TYPE = "URI_TYPE";
const String URI_LABEL = "URI_LABEL";
const String URI_ALGORITHM = "URI_ALGORITHM";
const String URI_DIGITS = "URI_DIGITS";
const String URI_SECRET = "URI_SECRET";
const String URI_COUNTER = "URI_COUNTER";
const String URI_PERIOD = "URI_PERIOD";
const String URI_ISSUER = "URI_ISSUER";

// 2 step:
const String URI_SALT_LENGTH = "URI_SALT_LENGTH";
const String URI_OUTPUT_LENGTH_IN_BYTES = "URI_OUTPUT_LENGTH_IN_BYTES";
const String URI_ITERATIONS = "URI_ITERATIONS";

// push token:
const String URI_SERIAL = "URI_SERIAL";
const String URI_ROLLOUT_URL = "URI_ROLLOUT_URL";
const String URI_TTL = "URI_TTL";
const String URI_ENROLLMENT_CREDENTIAL = "URI_ENROLLMENT_CREDENTIALS";
const String URI_SSL_VERIFY = "URI_SSL_VERIFY";

// Crypto stuff:
const String SIGNING_ALGORITHM = 'SHA-256/RSA';

// Custom error identifiers
const String FIREBASE_TOKEN_ERROR_CODE = "FIREBASE_TOKEN_ERROR_CODE";

// Notifications:
const String BUTTON_ACCEPT = "ACCEPT";
const String BUTTON_DECLINE = "DECLINE";

const String NOTIFICATION_CHANNEL_ANDROID = "privacy_idea_authenticator_push";

// Internal error codes
const int EXCEPTION_CODE = 000;
const int SOCKET_EXCEPTION_CODE = 111;
