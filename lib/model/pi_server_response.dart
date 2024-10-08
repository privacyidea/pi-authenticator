// ignore_for_file: constant_identifier_names

/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';

import '../utils/logger.dart';
import '../utils/object_validator.dart';
import 'api_results/pi_server_results/pi_server_result_error.dart';
import 'api_results/pi_server_results/pi_server_result_value.dart';

part 'pi_server_response.freezed.dart';

@freezed
class PiServerResponse<T extends PiServerResultValue> with _$PiServerResponse {
  static const RESULT = 'result';
  static const DETAIL = 'detail';
  static const ID = 'id';
  static const JSONRPC = 'jsonrpc';
  static const TIME = 'time';
  static const VERSION = 'version';
  static const SIGNATURE = 'signature';

  static const RESULT_STATUS = 'status';
  static const RESULT_VALUE = 'value';
  static const RESULT_ERROR = 'error';

  const PiServerResponse._();
  factory PiServerResponse.success({
    required dynamic detail,
    required int id,
    required String jsonrpc,
    required T resultValue,
    required double time,
    required String version,
    required String signature,
  }) = PiServerResponseSuccess;
  bool get isSuccess => this is PiServerResponseSuccess;
  PiServerResponseSuccess<T> get asSuccess => this as PiServerResponseSuccess<T>;

  factory PiServerResponse.error({
    required dynamic detail,
    required int id,
    required String jsonrpc,
    required PiServerResultError resultError,
    required double time,
    required String version,
    required String signature,
  }) = PiServerResponseError;
  bool get isError => this is PiServerResponseError;
  PiServerResponseError get asError => this as PiServerResponseError;

  factory PiServerResponse.fromJson(Map<String, dynamic> json) {
    Logger.debug('Received container sync response: $json');
    final map = validateMap<dynamic>(
      map: json,
      validators: {
        RESULT: const ObjectValidator<Map<String, dynamic>>(),
        ID: const ObjectValidator<int>(),
        JSONRPC: const ObjectValidator<String>(),
        DETAIL: const ObjectValidatorNullable<dynamic>(),
        TIME: const ObjectValidator<double>(),
        VERSION: const ObjectValidator<String>(),
        SIGNATURE: const ObjectValidator<String>(),
      },
      name: 'PiServerResponse#fromJson',
    );
    final result = validateMap<dynamic>(
      map: map[RESULT],
      validators: {
        RESULT_STATUS: const ObjectValidator<bool>(),
        RESULT_VALUE: const ObjectValidatorNullable<Map<String, dynamic>>(),
        RESULT_ERROR: const ObjectValidatorNullable<Map<String, dynamic>>(),
      },
      name: 'PiServerResponse#fromJson#result',
    );
    if (result[RESULT_STATUS] == true && result.containsKey(RESULT_VALUE)) {
      return PiServerResponse.success(
        detail: map[DETAIL],
        id: map[ID],
        jsonrpc: map[JSONRPC],
        resultValue: PiServerResultValue.fromJsonOfType<T>(result[RESULT_VALUE]),
        time: map[TIME],
        version: map[VERSION],
        signature: map[SIGNATURE],
      );
    }
    if (result[RESULT_STATUS] == false && result.containsKey(RESULT_ERROR)) {
      return PiServerResponse.error(
        detail: map[DETAIL],
        id: json[ID],
        jsonrpc: map[JSONRPC],
        resultError: PiServerResultError.fromResult(result[RESULT_ERROR]),
        time: map[TIME],
        version: map[VERSION],
        signature: map[SIGNATURE],
      );
    }
    Logger.info('Status: ${result[RESULT_STATUS]}'
        '\nContains error: ${result.containsKey(RESULT_ERROR)}'
        '\nContains value: ${result.containsKey(RESULT_VALUE)}');

    throw UnimplementedError('Unknown PiServerResponse type');
  }

  factory PiServerResponse.fromResponse(Response response) {
    return PiServerResponse.fromJson(jsonDecode(response.body));
  }
}
