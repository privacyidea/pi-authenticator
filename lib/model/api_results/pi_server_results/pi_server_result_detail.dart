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
import '../../../utils/object_validator.dart';
import 'pi_server_result.dart';

sealed class PiServerResultDetail<V> extends PiServerResult {
  @override
  bool get status => true;

  static D? fromResultDetail<D extends PiServerResultDetail>(
    dynamic resultDetail,
  ) {
    if (resultDetail == null) return null;
    Logger.debug('PiServerResultValue.uriMapOfType<$D>');
    return switch (D) {
      const (CodeToPhoneResultDetail) =>
        CodeToPhoneResultDetail.fromUriMap(resultDetail) as D,

      _ => _returnNullForUnimplementedType<D>(),
    };
  }

  static D? _returnNullForUnimplementedType<D>() {
    Logger.warning(
      'PiServerResultDetail.fromResultDetail: No implementation for type $D',
    );
    return null;
  }

  V toResultDetail();

  const PiServerResultDetail();
}

class BooleanResultDetail extends PiServerResultDetail<bool> {
  final bool value;

  const BooleanResultDetail(this.value);

  @override
  bool toResultDetail() {
    return value;
  }
}

class EmptyResultDetail extends PiServerResultDetail<Null> {
  const EmptyResultDetail();

  @override
  Null toResultDetail() => null;
}

class CodeToPhoneResultDetail
    extends PiServerResultDetail<Map<String, dynamic>> {
  static const String DISPLAY_CODE = 'display_code';
  static const String THREAD_ID = 'threadid';

  final String displayCode;
  final String threadId;

  const CodeToPhoneResultDetail({
    required this.displayCode,
    required this.threadId,
  });

  factory CodeToPhoneResultDetail.fromUriMap(Map<String, dynamic> uriMap) {
    final map = validateMap(
      map: uriMap,
      validators: {
        DISPLAY_CODE: const ObjectValidator<String>(),
        THREAD_ID: const ObjectValidator<String>(),
      },
      name: 'ContainerChallenge#fromUriMap',
    );
    return CodeToPhoneResultDetail(
      displayCode: map[DISPLAY_CODE] as String,
      threadId: map[THREAD_ID] as String,
    );
  }

  @override
  Map<String, dynamic> toResultDetail() {
    return {DISPLAY_CODE: displayCode, THREAD_ID: threadId};
  }
}
