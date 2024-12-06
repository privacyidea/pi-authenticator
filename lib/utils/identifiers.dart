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

// otp auth
const OTP_AUTH_CREATOR = 'creator';

// Container otp sync
const OTP_AUTH_OTP_VALUES = 'otp';

// Crypto stuff:
const String SIGNING_ALGORITHM = 'SHA-256/RSA';

// Custom error identifiers
const String FIREBASE_TOKEN_ERROR_CODE = 'FIREBASE_TOKEN_ERROR_CODE';

// Container finalization:
const String CONTAINER_CONTAINER_SERIAL = 'container_serial';
const String CONTAINER_PUBLIC_CLIENT_KEY = 'public_client_key';
const String CONTAINER_DEVICE_BRAND = 'device_brand';
const String CONTAINER_DEVICE_MODEL = 'device_model';

// Container sync:
const String CONTAINER_SYNC_PUBLIC_CLIENT_KEY = 'public_enc_key_client';
const String CONTAINER_SYNC_DICT_SERVER = 'container_dict_server';
const String CONTAINER_SYNC_DICT_CLIENT = 'container_dict_client';

const String CONTAINER_SYNC_ENC_ALGORITHM = 'encryption_algorithm';
const String CONTAINER_SYNC_ENC_PARAMS = 'encryption_params';
const String CONTAINER_SYNC_POLICIES = 'policies';
const String CONTAINER_SYNC_PUBLIC_SERVER_KEY = 'public_server_key';
const String CONTAINER_SYNC_SERVER_URL = 'server_url';

const String CONTAINER_DICT_CONTAINER = 'container';
const String CONTAINER_DICT_SERIAL = 'serial';
const String CONTAINER_DICT_TYPE = 'type';
const String CONTAINER_DICT_TYPE_SMARTPHONE = 'smartphone';
const String CONTAINER_DICT_TOKENS = 'tokens';
const String CONTAINER_DICT_TOKENS_ADD = 'add';
const String CONTAINER_DICT_TOKENS_UPDATE = 'update';
const String CONTAINER_SYNC_ENC_PARAMS_MODE = 'mode';
const String CONTAINER_SYNC_ENC_PARAMS_IV = 'init_vector';
const String CONTAINER_SYNC_ENC_PARAMS_TAG = 'tag';
const String CONTAINER_SYNC_DICT_ENCRYPTED = 'container_dict_encrypted';

const String GLOBAL_SECURE_REPO_PREFIX = 'app_v3_';
