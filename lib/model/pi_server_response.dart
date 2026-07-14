/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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
import '../utils/object_validator/object_validators.dart';
import 'api_results/pi_server_results/pi_server_result.dart';
import 'api_results/pi_server_results/pi_server_result_detail.dart';
import 'api_results/pi_server_results/pi_server_result_value.dart';
import 'exception_errors/error_codes.dart';
import 'exception_errors/pi_server_result_error.dart';

part 'pi_server_response.freezed.dart';

@Freezed(copyWith: false)
sealed class PiServerResponse<
  V extends PiServerResultValue,
  D extends PiServerResultDetail
>
    with _$PiServerResponse {
  static const RESULT = 'result';
  static const DETAIL = 'detail';
  static const ID = 'id';
  static const JSONRPC = 'jsonrpc';
  static const TIME = 'time';
  static const VERSION = 'version';
  static const VERSION_NUMBER = 'versionnumber';
  static const SIGNATURE = 'signature';

  const PiServerResponse._();
  factory PiServerResponse.success({
    required int statusCode,
    @Default(null) int? id,
    @Default(null) String? jsonrpc,
    required PiServerResult<V> result,
    @Default(null) double? time,
    @Default(null) String? version,
    @Default(null) String? versionNumber,
    @Default(null) String? signature,
    @Default(null) D? detail,
  }) = PiSuccessResponse;
  bool get isSuccess => this is PiSuccessResponse;
  PiSuccessResponse<V, D>? get asSuccess =>
      this is PiSuccessResponse<V, D> ? this as PiSuccessResponse<V, D> : null;

  factory PiServerResponse.error({
    required int statusCode,
    @Default(null) int? id,
    @Default(null) String? jsonrpc,
    @Default(null) D? detail,

    /// This is a throwable error
    required PiServerResultError piServerResultError,
    @Default(null) double? time,
    @Default(null) String? version,
    @Default(null) String? versionNumber,
    @Default(null) String? signature,
  }) = PiErrorResponse;
  bool get isError => this is PiErrorResponse;
  PiErrorResponse<V, D>? get asError =>
      this is PiErrorResponse<V, D> ? this as PiErrorResponse<V, D> : null;

  static PiServerResponse<V, D> fromJson<
    V extends PiServerResultValue,
    D extends PiServerResultDetail
  >(Map<String, dynamic> json, {int statusCode = 200}) {
    Logger.debug('Received container sync response: $json');
    final map = validateMap(
      map: json,
      validators: <String, BaseValidator>{
        ID: Validators.intOptional,
        JSONRPC: Validators.stringOptional,
        RESULT: RequiredObjectValidator<Map<String, dynamic>>(),
        TIME: OptionalObjectValidator<double>(),
        VERSION: OptionalObjectValidator<String>(
          transformer: (v) {
            final s = v as String;
            return s.contains(' ') ? s : null;
          },
        ),
        VERSION_NUMBER: Validators.stringOptional,
        DETAIL: OptionalObjectValidator<Object>(),
        SIGNATURE: Validators.stringOptional,
      },
      name: 'PiServerResponse#fromJson',
    );
    return PiServerResponse<V, D>.success(
      statusCode: statusCode,
      id: map[ID] as int?,
      jsonrpc: map[JSONRPC] as String?,
      result: PiServerResult<V>.fromResultMap(
        map[RESULT] as Map<String, dynamic>,
      ),
      time: map[TIME] as double?,
      version: map[VERSION] as String?,
      versionNumber:
          map[VERSION_NUMBER] as String? ??
          (map[VERSION] as String?)?.split(' ')[1],
      detail: PiServerResultDetail.fromResultDetail<D>(map[DETAIL]),
      signature: map[SIGNATURE] as String?,
    );
  }

  static PiServerResponse<V, D> fromResponse<
    V extends PiServerResultValue,
    D extends PiServerResultDetail
  >(Response response) {
    late final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body);
    } catch (e) {
      Logger.warning('Failed to parse server response', error: response.body);
      final rawBody = response.body.trim();
      const maxMessageLength = 200;
      final truncatedBody = rawBody.length > maxMessageLength
          ? '${rawBody.substring(0, maxMessageLength)}...'
          : rawBody;
      return PiServerResponse.error(
        statusCode: response.statusCode,
        piServerResultError: PiServerResultError(
          code: InAppErrorCodes.jsonParseError,
          message: truncatedBody.isNotEmpty
              ? truncatedBody
              : 'Empty response body (HTTP ${response.statusCode})',
        ),
      );
    }

    return PiServerResponse.fromJson<V, D>(
      json,
      statusCode: response.statusCode,
    );
  }
}
