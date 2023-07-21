/*
  privacyIDEA Authenticator

  Authors: Nils Behlen <nils.behlen@netknights.it>

  Copyright (c) 2017-2023 NetKnights GmbH

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

package it.netknights.pi_authenticator_legacy;

public class AppConstants {

    public static final String APP_TITLE = " privacyIDEA Authenticator";
    public static final String PACKAGE_NAME = "it.netknights.piauthenticator";
    public static final String TAG = "PI-Authenticator";

    public static final int INTENT_ADD_TOKEN_MANUALLY = 101;
    public static final int INTENT_ABOUT = 102;
    public static final int PERMISSIONS_REQUEST_CAMERA = 103;

    // ----- CRYPTO CONSTANTS -----
    public static final String CRYPT_ALGORITHM = "AES/GCM/NoPadding";
    public static final String KEY_WRAP_ALGORITHM = "RSA/ECB/PKCS1Padding";
    public static final int KEY_LENGTH = 16;
    public static final int IV_LENGTH = 12;
    public static final String SIGNING_ALGORITHM = "SHA256withRSA";

    // ----- FILE NAMES -----
    public static final String DATAFILE = "data.dat";
    public static final String KEYFILE = "key.key";
    public static final String PUBKEYFILE = "pubkey.key";
    public static final String FB_CONFIG_FILE = "fbconf.dat";
    // -----------------------

    public static final String DIGITS = "digits";
    public static final String PERIOD = "period";
    public static final String ALGORITHM = "algorithm";
    public static final String ISSUER = "issuer";
    public static final String SECRET = "secret";
    public static final String TYPE = "type";
    public static final String LABEL = "label";
    public static final String COUNTER = "counter";
    public static final String TOTP = "totp";
    public static final String HOTP = "hotp";
    public static final String TAPTOSHOW = "taptoshow";
    public static final String PIN = "pin";
    public static final String WITHPIN = "withpin";
    public static final String TWOSTEP_SALT = "2step_salt";                // Size of the random bytes generated by the smartphone, which are used as salt for PBKDF2
    public static final String TWOSTEP_DIFFICULTY = "2step_difficulty";    // PBKDF2 iterations
    public static final String TWOSTEP_OUTPUT = "2step_output";            // size of the key generated by PBKDF2
    public static final String PROPERTY_PROGRESS = "progress";
    public static final String PERSISTENT = "persistent";

    public static final String SHA1 = "SHA1";
    public static final String SHA256 = "SHA256";
    public static final String SHA512 = "SHA512";
    public static final String HMACSHA1 = "HmacSHA1";
    public static final String HMACSHA256 = "HmacSHA256";
    public static final String HMACSHA512 = "HmacSHA512";

    public static final String PERIOD_30_STR = "30s";
    public static final String PERIOD_60_STR = "60s";
    public static final int PERIOD_30 = 30;
    public static final int PERIOD_60 = 60;

    public static final String DIGITS_6_STR = "6";
    public static final String DIGITS_8_STR = "8";

    // ----- Stuff for push -----
    // Attribute names
    public static final String PUSH = "pipush";
    public static final String URL = "url";
    public static final String TTL = "ttl";
    public static final String PROJECT_ID = "projectid";
    public static final String APP_ID = "appid";
    public static final String API_KEY = "apikey";
    public static final String PROJECT_NUMBER = "projectnumber";
    public static final String FB_TOKEN = "fbtoken";
    public static final String ENROLLMENT_CRED = "enrollment_credential";

    // TODO
    public static final String TITLE = "title";
    public static final String NONCE = "nonce";
    public static final String SIGNATURE = "signature";
    public static final String SERIAL = "serial";
    public static final String QUESTION = "question";
    public static final String ROLLOUT_STATE = "rollout_state";
    public static final String ROLLOUT_EXPIRATION = "rollout_expiration";
    public static final String PUSH_VERSION = "v";
    public static final String SSL_VERIFY = "sslverify";
    public static final String PUBKEY = "pubkey";
    public static final String NOTIFICATION_ID = "notificationID";
    public static final String PENDING_AUTHS = "pending_auths";
    public static final String RESPONSE_DETAIL = "detail";
    public static final String RESPONSE_PUBLIC_KEY = "public_key";
    public static final String RESPONSE_RESULT = "result";
    public static final String RESPONSE_VALUE = "value";

    public enum State {
        UNFINISHED("unfinished"),
        ROLLING_OUT("rolling_out"),
        FINISHED("finished"),
        AUTHENTICATING("authenticating");

        String state;

        State(String state) {
            this.state = state;
        }
    }

    // Constants
    public static final int READ_TIMEOUT = 10000;
    public static final int CONNECT_TIMEOUT = 15000;

    public static final String CHANNEL_ID_HIGH_PRIO = "privacyIDEAPush_high";
    public static final String CHANNEL_ID_LOW_PRIO = "privacyIDEAPush_low";

    public static final String INTENT_FILTER = "privacyIDEAAuthenticator";

    // Status codes
    public static final int PRO_STATUS_STEP_1 = 1001;
    public static final int PRO_STATUS_STEP_2 = 1002;
    public static final int PRO_STATUS_STEP_3 = 1003;
    public static final int PRO_STATUS_DONE = 1004;
    public static final int PRO_STATUS_KEY_RECEIVED = 1005;
    public static final int PRO_STATUS_REGISTRATION_TIME_EXPIRED = 1010;
    public static final int PRO_STATUS_RESPONSE_NO_KEY = 1011;

    public static final int PRO_STATUS_BAD_BASE64 = 1013;
    public static final int PRO_STATUS_MALFORMED_JSON = 1015;
    public static final int PRO_STATUS_RESPONSE_NOT_OK = 1016;

    public static final int PA_INVALID_SIGNATURE = 2001;
    public static final int PA_SIGNING_FAILURE = 2002;
    public static final int PA_AUTHENTICATION_FINISHED = 2003;

    public static final int STATUS_INIT_FIREBASE = 3101;
    public static final int STATUS_INIT_FIREBASE_DONE = 3102;
    public static final int STATUS_TWO_STEP_ROLLOUT = 3103;
    public static final int STATUS_TWO_STEP_ROLLOUT_DONE = 3104;
    public static final int STATUS_STANDARD_ROLLOUT_DONE = 3105;

    public static final int STATUS_ENDPOINT_SENDING_COMPLETE = 4001;
    public static final int STATUS_ENDPOINT_UNKNOWN_HOST = 4002;
    public static final int STATUS_ENDPOINT_MALFORMED_URL = 4003;
    public static final int STATUS_ENDPOINT_RESPONSE_RECEIVED = 4004;
    public static final int STATUS_ENDPOINT_ERROR = 4005;
    public static final int STATUS_ENDPOINT_SSL_ERROR = 4006;
}
