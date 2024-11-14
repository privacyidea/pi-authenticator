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

// otp auth
const OTP_AUTH_VERSION = 'v';
const OTP_AUTH_CREATOR = 'creator';
const OTP_AUTH_TYPE = 'type';

/// [String] (optional) default = null
const OTP_AUTH_SERIAL = 'serial';

/// [String] (required)
const OTP_AUTH_SECRET_BASE32 = 'secret';

/// [String] (optional) default =' 0'
const OTP_AUTH_COUNTER = 'counter';

/// [String] (optional) default = '30'
const OTP_AUTH_PERIOD_SECONDS = 'period';

/// [String] (optional) default = 'SHA1'
const OTP_AUTH_ALGORITHM = 'algorithm';

/// [String] (optional) default = '6'
const OTP_AUTH_DIGITS = 'digits';

/// [String] (optional) default = ''
const OTP_AUTH_LABEL = 'label';

/// [String] (optional) default = ''
const OTP_AUTH_ISSUER = 'issuer';

/// [String] 'True' / 'False' (optional) default = 'False'
const OTP_AUTH_PIN = 'pin';

/// [String] (optional) default = 'False'
const OTP_AUTH_PIN_TRUE = 'True';
const OTP_AUTH_PIN_FALSE = 'False';

/// [String] (optional) default = ''
const OTP_AUTH_IMAGE = 'image';

// OTP auth push

/// [String] (required for PUSH)
const OTP_AUTH_PUSH_ROLLOUT_URL = 'url';
const OTP_AUTH_PUSH_TTL_MINUTES = 'ttl';

/// [String] (optional) default = null
const OTP_AUTH_PUSH_ENROLLMENT_CREDENTIAL = 'enrollment_credential';

/// [String] '1' / '0' (optional) default = '1'
const OTP_AUTH_PUSH_SSL_VERIFY = 'sslverify';
const OTP_AUTH_PUSH_SSL_VERIFY_TRUE = '1';
const OTP_AUTH_PUSH_SSL_VERIFY_FALSE = '0';

// otp auth 2step

/// [String] (required for 2step)
const OTP_AUTH_2STEP_SALT_LENTH = '2step_salt';

/// [String] (required for 2step)
const OTP_AUTH_2STEP_OUTPUT_LENTH = '2step_output';

/// [String] (required for 2step)
const OTP_AUTH_2STEP_ITERATIONS = '2step_difficulty';

// Container otp sync

const OTP_AUTH_OTP_VALUES = 'otp';

const OTP_AUTH_STEAM_ISSUER = 'Steam';

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

// Container challenge:
const String CONTAINER_CHAL_KEY_ALGORITHM = 'enc_key_algorithm';
const String CONTAINER_CHAL_NONCE = 'nonce';
const String CONTAINER_CHAL_TIMESTAMP = 'time_stamp';
const String CONTAINER_CHAL_SIGNATURE = 'signature';

// Container registration:
const String CONTAINER_ISSUER = 'issuer';
const String CONTAINER_NONCE = 'nonce';
const String CONTAINER_TIMESTAMP = 'time';
const String CONTAINER_FINALIZATION_URL = 'url';
const String CONTAINER_EC_KEY_ALGORITHM = 'key_algorithm';
const String CONTAINER_SERIAL = 'serial';
const String CONTAINER_HASH_ALGORITHM = 'hash_algorithm';
const String CONTAINER_PASSPHRASE_QUESTION = 'passphrase';
const String CONTAINER_SSL_VERIFY = 'ssl_verify';
const String CONTAINER_SERVER_URL = 'container_sync_url';
const String CONTAINER_SCOPE = 'scope';
const String CONTAINER_POLICIES = 'policies';

// Container finalization:
const String CONTAINER_CONTAINER_SERIAL = 'container_serial';
const String CONTAINER_PUBLIC_CLIENT_KEY = 'public_client_key';
const String CONTAINER_DEVICE_BRAND = 'device_brand';
const String CONTAINER_DEVICE_MODEL = 'device_model';

// Container sync:
const String CONTAINER_SYNC_PUBLIC_CLIENT_KEY = 'public_enc_key_client';
const String CONTAINER_SYNC_DICT_SERVER = 'container_dict_server';
const String CONTAINER_SYNC_DICT_CLIENT = 'container_dict_client';
const String CONTAINER_DICT_SERIAL = 'serial';
const String CONTAINER_DICT_TYPE = 'type';
const String CONTAINER_DICT_TYPE_SMARTPHONE = 'smartphone';
const String CONTAINER_DICT_TOKENS = 'tokens';
const String CONTAINER_DICT_TOKENS_ADD = 'add';
const String CONTAINER_DICT_TOKENS_UPDATE = 'update';
const String CONTAINER_SYNC_PUBLIC_SERVER_KEY = 'public_server_key';
const String CONTAINER_SYNC_ENC_ALGORITHM = 'encryption_algorithm';
const String CONTAINER_SYNC_ENC_PARAMS = 'encryption_params';
const String CONTAINER_SYNC_ENC_PARAMS_MODE = 'mode';
const String CONTAINER_SYNC_ENC_PARAMS_IV = 'init_vector';
const String CONTAINER_SYNC_ENC_PARAMS_TAG = 'tag';
const String CONTAINER_SYNC_DICT_ENCRYPTED = 'container_dict_encrypted';

const String GLOBAL_SECURE_REPO_PREFIX = 'app_v3_';
