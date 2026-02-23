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
// lib/model/push_request/push_requests.dart

import '../../utils/logger.dart';
import 'push_requests.dart';

export 'push_choice_request.dart';
export 'push_code_to_phone_request.dart';
export 'push_default_request.dart';
export 'push_request.dart';

abstract class PushRequestFactory {
  static PushRequest fromMessageData(Map<String, dynamic> data) {
    Logger.debug('Creating PushRequest from message data: $data');
    if (PushChoiceRequest.canHandle(data)) {
      Logger.debug('Identified as PushChoiceRequest');
      return PushChoiceRequest.fromMessageData(data);
    }
    if (PushCodeToPhoneRequest.canHandle(data)) {
      Logger.debug('Identified as PushCodeToPhoneRequest');
      return PushCodeToPhoneRequest.fromMessageData(data);
    }

    if (PushDefaultRequest.canHandle(data)) {
      Logger.debug('Identified as PushDefaultRequest');
      return PushDefaultRequest.fromMessageData(data);
    }
    throw ArgumentError('Unsupported push request data: $data');
  }

  static PushRequest fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    if (type == PushCodeToPhoneRequest.TYPE) {
      return PushCodeToPhoneRequest.fromJson(json);
    }
    if (type == PushChoiceRequest.TYPE) {
      return PushChoiceRequest.fromJson(json);
    }
    if (type == PushDefaultRequest.TYPE || type == null) {
      return PushDefaultRequest.fromJson(json);
    }
    throw ArgumentError('Unsupported push request type: $type');
  }
}
