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

import 'package:privacyidea_authenticator/utils/errors.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

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

// Pi Server Error
const String PI_SERVER_ERROR_CODE = 'code';
const String PI_SERVER_ERROR_MESSAGE = 'message';

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
const String CONTAINER_ISSUER = 'issuer';
const String CONTAINER_NONCE = 'nonce';
const String CONTAINER_TIMESTAMP = 'time';
const String CONTAINER_FINALIZATION_URL = 'url';
const String CONTAINER_SERIAL = 'serial';
const String CONTAINER_EC_KEY_ALGORITHM = 'key_algorithm';
const String CONTAINER_HASH_ALGORITHM = 'hash_algorithm';
const String CONTAINER_PASSPHRASE_QUESTION = 'passphrase';

// Container sync:
const String CONTAINER_SYNC_NONCE = 'nonce';
const String CONTAINER_SYNC_TIMESTAMP = 'time_stamp';
const String CONTAINER_SYNC_KEY_ALGORITHM = 'key_algorithm';
const String CONTAINER_SYNC_URL = 'container_sync_url';
const String CONTAINER_SYNC_SIGNATURE = 'signature';
const String CONTAINER_SYNC_PUBLIC_CLIENT_KEY = 'public_enc_key_client';
const String CONTAINER_SYNC_DICT_SERVER = 'container_dict_server';
const String CONTAINER_SYNC_DICT_CLIENT = 'container_dict_client';

const String CONTAINER_DICT_SERIAL = 'serial';
const String CONTAINER_DICT_TYPE = 'type';
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

T? validateOptional<T extends Object>({required dynamic value, required ObjectValidatorNullable<T> validator, required String name}) {
  if (validator.isTypeOf(value)) {
    return validator.transform(value);
  } else {
    throw LocalizedArgumentError(
      localizedMessage: (localizations, value, name) => localizations.invalidValue(value.runtimeType.toString(), value, name),
      unlocalizedMessage: 'The ${value.runtimeType} "$value" is not valid for "$name"',
      invalidValue: value,
      name: name,
    );
  }
}

T validate<T extends Object>({required dynamic value, required ObjectValidator<T> validator, required String name}) {
  if (validator.isTypeOf(value)) {
    return validator.transform(value);
  } else {
    throw LocalizedArgumentError(
      localizedMessage: (localizations, value, name) => localizations.invalidValue(value.runtimeType.toString(), value, name),
      unlocalizedMessage: 'The ${value.runtimeType} "$value" is not valid for "$name"',
      invalidValue: value,
      name: name,
    );
  }
}

/// Validates a map by checking if it contains all required keys and if the values are of the correct type.
///
/// Throws a [LocalizedArgumentError] if the map is invalid.
/// <br />If the validator provides a transformer function, the value will be transformed before checking the type.
/// <br />The returned map will contain the transformed values.
Map<String, RV> validateMap<RV>({required Map<String, dynamic> map, required Map<String, ObjectValidatorNullable<RV>> validators, required String? name}) {
  Map<String, RV> validatedMap = {};
  for (String key in validators.keys) {
    final validator = validators[key]!;
    final mapEntry = map[key];
    if (validator.isTypeOf(mapEntry)) {
      if (validator.valueIsAllowed(mapEntry)) {
        final newValue = validator.transform(mapEntry);
        if (newValue != null) validatedMap[key] = newValue;
      } else {
        throw LocalizedArgumentError(
          localizedMessage: name != null
              ? (localizations, value, key) => localizations.valueNotAllowedIn(value.runtimeType.toString(), value.toString(), key, name)
              : (localizations, value, key) => localizations.valueNotAllowed(value.runtimeType.toString(), value.toString(), key),
          unlocalizedMessage: 'The ${mapEntry.runtimeType} "$mapEntry" is not an allowed value for "$key"',
          invalidValue: mapEntry.toString(),
          name: key,
        );
      }
    } else {
      if (mapEntry == null) {
        throw LocalizedArgumentError(
          localizedMessage: name != null
              ? (localizations, value, key) => localizations.missingRequiredParameterIn(key, name)
              : (localizations, value, key) => localizations.missingRequiredParameter(key),
          unlocalizedMessage: 'Map does not contain required key "$key"',
          invalidValue: mapEntry.toString(),
          name: key,
        );
      }
      throw LocalizedArgumentError(
        localizedMessage: name != null
            ? (localizations, value, key) => localizations.invalidValueIn(value.runtimeType.toString(), value.toString(), key, name)
            : (localizations, value, key) => localizations.invalidValue(value.runtimeType.toString(), value.toString(), key),
        unlocalizedMessage: 'The ${mapEntry.runtimeType} "$mapEntry" is not valid for "$key"${name != null ? ' in $name' : ''}',
        invalidValue: mapEntry.toString(),
        name: key,
      );
    }
  }
  return validatedMap;
}

class ObjectValidatorNullable<T extends Object?> {
  final T Function(dynamic value)? transformer;
  final T? defaultValue;
  final bool Function(T)? allowedValues;

  const ObjectValidatorNullable({
    this.transformer,
    this.defaultValue,
    this.allowedValues,
  });

  /// Checks if the value is of the correct type, or sub-type.
  /// If the transformer is provided, the value will be transformed before checking the type.
  bool isTypeOf(dynamic value) {
    Logger.debug('Checking type (${T.runtimeType}) of nullable value "$value" and default value "$defaultValue" with transformer "$transformer".');
    if (value == null) return true;
    if (transformer == null) return value is T?;
    try {
      transformer!(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool valueIsAllowed(dynamic value) {
    if (!isTypeOf(value)) return false;
    if (allowedValues == null) return true;
    if (value == null) return true;
    final transformedValue = transform(value);
    if (transformedValue == null) return true;
    if (allowedValues!(transformedValue)) return true;
    return false;
  }

  /// Transforms the value if a transformer is provided, otherwise returns the value as is.
  /// May throw an error if the value is not of the correct type.
  /// To prevent an error, use isTypeOf before calling transform.
  T? transform(dynamic value) {
    if (value == null) return defaultValue;
    if (transformer == null) return value as T;
    try {
      return transformer!.call(value);
    } catch (e) {
      return defaultValue;
    }
  }

  ObjectValidatorNullable<T> nullable() => ObjectValidatorNullable<T>(transformer: transformer, defaultValue: defaultValue, allowedValues: allowedValues);
  ObjectValidatorNullable<T> withDefault(T? defaultValue) =>
      ObjectValidatorNullable<T>(transformer: transformer, defaultValue: defaultValue, allowedValues: allowedValues);

  String get type => RegExp('(?<=<).+(?=>)').firstMatch(toString())!.group(0)!;

  @override
  String toString() => runtimeType.toString();

  @override
  bool operator ==(Object other) => other is ObjectValidatorNullable<T>;

  @override
  int get hashCode => toString().hashCode;
}

class ObjectValidator<T extends Object> extends ObjectValidatorNullable<T> {
  const ObjectValidator({
    super.transformer,
    super.defaultValue,
    super.allowedValues,
  });

  /// Transforms the value if a transformer is provided, otherwise returns the value as is.
  /// May throw an error if the value is not of the correct type.
  /// To prevent an error, use isTypeOf before calling transform.
  @override
  T transform(dynamic value) {
    try {
      if (value == null) return defaultValue!;
      if (transformer == null) return value is T ? value : defaultValue!;
      return transformer!.call(value);
    } catch (e) {
      if (defaultValue != null) return defaultValue!;
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, name) => localizations.invalidValue(value.runtimeType.toString(), value, name),
        unlocalizedMessage: 'The type ${value.runtimeType} for value "$value" is not valid.',
        invalidValue: value,
        name: type,
      );
    }
  }

  /// Checks if the value is of the correct type, or sub-type.
  /// If the transformer is provided, the value will be transformed before checking the type.
  @override
  bool isTypeOf(dynamic value) {
    Logger.debug('Checking type (${T.runtimeType}) of value "$value" and default value "$defaultValue" with transformer "$transformer".');
    if (value == null) return defaultValue != null;
    if (transformer == null) return value is T;
    try {
      transformer!(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool valueIsAllowed(dynamic value) {
    if (!isTypeOf(value)) return false;
    value ??= defaultValue;
    if (value == null) return false;
    if (allowedValues == null) return true;
    return allowedValues!(transform(value));
  }
}
