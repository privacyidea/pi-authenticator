/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2025 NetKnights GmbH

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

// Crypto stuff:
const String DEFAULT_SIGNING_ALGORITHM = 'SHA-256/RSA';

// Custom error identifiers
const String FIREBASE_TOKEN_ERROR_CODE = 'FIREBASE_TOKEN_ERROR_CODE';

const String GLOBAL_SECURE_REPO_PREFIX_LEGACY = 'app_v3';
const String GLOBAL_SECURE_REPO_PREFIX = 'app_v4';

// Prefixes that tell the repositories sharing one secure storage apart.
// They live here so a repository can tell which of the others nest below its
// own prefix, which decides whose entries it must leave alone.
const String SECURE_REPO_PREFIX_TOKEN = '${GLOBAL_SECURE_REPO_PREFIX}_token';
const String SECURE_REPO_PREFIX_TOKEN_CONTAINER =
    '${GLOBAL_SECURE_REPO_PREFIX}_token_container';
const String SECURE_REPO_PREFIX_PUSH_REQUEST =
    '${GLOBAL_SECURE_REPO_PREFIX}_push_request';
const String SECURE_REPO_PREFIX_FIREBASE =
    '${GLOBAL_SECURE_REPO_PREFIX}_firebase';

// The legacy storage keeps tokens, push requests and firebase tokens under the
// one GLOBAL_SECURE_REPO_PREFIX_LEGACY and tells them apart by their content.
// Containers are the exception, they carry their own prefix.
const String SECURE_REPO_PREFIX_LEGACY_TOKEN_CONTAINER = 'containerCredentials';
