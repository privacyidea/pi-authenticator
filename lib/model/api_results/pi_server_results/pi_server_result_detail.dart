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
import '../../../utils/logger.dart';
import '../../../utils/object_validator/object_validators.dart';

sealed class PiServerResultDetail {
  static D? fromResultDetail<D extends PiServerResultDetail>(
    dynamic resultDetail,
  ) {
    if (resultDetail == null) return null;
    Logger.debug('PiServerResultValue.uriMapOfType<$D>');
    return switch (D) {
      const (PushResultDetail) =>
        PushResultDetail.fromUriMap(resultDetail) as D,

      _ => _returnNullForUnimplementedType<D>(),
    };
  }

  static D? _returnNullForUnimplementedType<D>() {
    Logger.warning(
      'PiServerResultDetail.fromResultDetail: No implementation for type $D',
    );
    return null;
  }

  const PiServerResultDetail();
}

class EmptyResultDetail extends PiServerResultDetail {
  const EmptyResultDetail();
  @override
  String toString() => 'EmptyResultDetail()';
}

class PushResultDetail extends PiServerResultDetail {
  static const String DISPLAY_CODE = 'display_code';
  static const String THREAD_ID = 'threadid';
  static const String MESSAGE = 'message';

  final String? displayCode;
  final int? threadId;
  final String? message;

  const PushResultDetail({
    required this.displayCode,
    required this.threadId,
    this.message,
  });

  factory PushResultDetail.fromUriMap(Map<String, dynamic> uriMap) {
    final map = validateMap(
      map: uriMap,
      validators: <String, BaseValidator>{
        DISPLAY_CODE: stringValidatorOptional,
        THREAD_ID: const OptionalObjectValidator<int>(),
        MESSAGE: stringValidatorOptional,
      },
      name: 'ContainerChallenge#fromUriMap',
    );
    return PushResultDetail(
      displayCode: map[DISPLAY_CODE] as String?,
      threadId: map[THREAD_ID] as int?,
      message: map[MESSAGE] as String?,
    );
  }

  @override
  String toString() =>
      'PushResultDetail(displayCode: $displayCode, threadId: $threadId)';
}
