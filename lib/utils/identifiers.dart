/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

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
}

const String URI_TYPE = "URI_TYPE";
const String URI_LABEL = "URI_LABEL";
const String URI_ALGORITHM = "URI_ALGORITHM";
const String URI_DIGITS = "URI_DIGITS";
const String URI_SECRET = "URI_SECRET";
const String URI_COUNTER = "URI_COUNTER";
const String URI_PERIOD = "URI_PERIOD";
// 2 step:
const String URI_SALT_LENGTH = "URI_SALT_LENGTH";
const String URI_OUTPUT_LENGTH_IN_BYTES = "URI_OUTPUT_LENGTH_IN_BYTES";
const String URI_ITERATIONS = "URI_ITERATIONS";