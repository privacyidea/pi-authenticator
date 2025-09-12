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
