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
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';

import '../utils/globals.dart';
import '../utils/logger.dart';
import '../utils/object_validator.dart';
import '../utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import '../utils/view_utils.dart';

part 'processor_result.freezed.dart';

@freezed
abstract class ProcessorResult<T> with _$ProcessorResult<T> {
  const ProcessorResult._();
  const factory ProcessorResult.success(
    T resultData, {
    ObjectValidator<ResultHandler>? resultHandlerType,
  }) = ProcessorResultSuccess;
  const factory ProcessorResult.failed(
    String Function(AppLocalizations) message, {
    dynamic error,
    ObjectValidator<ResultHandler>? resultHandlerType,
  }) = ProcessorResultFailed;

  bool get isSuccess => this is ProcessorResultSuccess<T>;
  bool get isFailed => this is ProcessorResultFailed<T>;
  ProcessorResultSuccess<T>? get asSuccess => this is ProcessorResultSuccess<T> ? this as ProcessorResultSuccess<T> : null;
  ProcessorResultFailed<T>? get asFailed => this is ProcessorResultFailed<T> ? this as ProcessorResultFailed<T> : null;
}

extension ListProcessorResult<T> on List<ProcessorResult<T>> {
  List<ProcessorResultSuccess<T>> get successResults => where((element) => element.isSuccess).map((e) => e.asSuccess!).toList();
  List<ProcessorResultFailed<T>> get failedResults => where((element) => !element.isSuccess).map((e) => e.asFailed!).toList();

  List<T> getData() {
    final results = toList();
    if (results.isEmpty) {
      showStatusMessage(message: (_) => 'No data found in QR code.'); // TODO: Localize
      Logger.warning('No data found in QR code.');
      return [];
    }
    final failedResults = results.whereType<ProcessorResultFailed>().toList();
    // add postframe callback to show the message after the current frame

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (var failedResult in failedResults) {
        globalRef?.read(statusMessageProvider.notifier).state = StatusMessage(
          message: (localization) => localization.malformedData,
          details: failedResult.message,
        );
      }
    });

    final successData = results.where((result) => result.isSuccess).map((e) => e.asSuccess!.resultData).toList();
    return successData;
  }
}

mixin ResultHandler {
  Future handleProcessorResult(ProcessorResult result, Map<String, dynamic> args);
  Future handleProcessorResults(List<ProcessorResult> results, Map<String, dynamic> args);
}
