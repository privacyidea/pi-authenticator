/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

import 'package:json_annotation/json_annotation.dart';

import '../../utils/logger.dart';
import '../capabilities/capabilities.dart';
import 'decline_reason.dart';
import 'push_request.dart';

part 'push_code_to_phone_request.g.dart';

@JsonSerializable()
class PushCodeToPhoneRequest extends PushRequest {
  static const String DISPLAY_CODE = 'display_code';
  static const String TYPE = 'code_to_phone';

  final String displayCode;

  PushCodeToPhoneRequest({
    required super.title,
    required super.question,
    required super.nonce,
    required super.serial,
    required super.signature,
    required super.expirationDate,
    required this.displayCode,
    required super.uri,
    required super.sslVerify,
    super.signedCapabilities,
    super.type = PushCodeToPhoneRequest.TYPE,
    super.accepted,
    super.declineReason,
  });

  factory PushCodeToPhoneRequest.fromJson(Map<String, dynamic> json) =>
      _$PushCodeToPhoneRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PushCodeToPhoneRequestToJson(this);

  @override
  String get signedData =>
      '$nonce|$uri|$serial|$question|$title|${sslVerify ? '1' : '0'}|$displayCode';

  factory PushCodeToPhoneRequest.fromMessageData(Map<String, dynamic> data) {
    try {
      verifyMessageData(data);
    } catch (e, s) {
      Logger.error('Invalid push request data.', error: e, stackTrace: s);
    }
    return PushCodeToPhoneRequest(
      title: data[PushRequest.TITLE],
      question: data[PushRequest.QUESTION],
      uri: Uri.parse(data[PushRequest.URL]),
      nonce: data[PushRequest.NONCE],
      sslVerify: data[PushRequest.SSL_VERIFY] == '1',
      serial: data[PushRequest.SERIAL],
      expirationDate: DateTime.now().add(const Duration(minutes: 2)),
      signature: data[PushRequest.SIGNATURE],
      signedCapabilities: SignedCapabilities.fromMessageData(data),
      displayCode: data[DISPLAY_CODE],
    );
  }

  /// Verify that the data is valid.
  static void verifyMessageData(Map<String, dynamic> data) {
    PushRequest.verifyMessageData(data);
    if (data[DISPLAY_CODE] is! String) {
      throw ArgumentError(
        'Push request display code is ${data[DISPLAY_CODE].runtimeType}. Expected String.',
      );
    }
  }

  static bool canHandle(Map<String, dynamic> data) {
    try {
      verifyMessageData(data);
      return true;
    } catch (e, s) {
      Logger.info('Cannot handle push request data.', error: e, stackTrace: s);
      return false;
    }
  }

  @override
  String toString() {
    return 'PushCodeToPhoneRequest{title: $title, question: $question, '
        'id: $id, uri: $uri, nonce: $nonce, sslVerify: $sslVerify, '
        'expirationDate: $expirationDate, serial: $serial, '
        'signature: $signature, signedCapabilities: $signedCapabilities, '
        'accepted: $accepted, declineReason: $declineReason, '
        'displayCode: $displayCode}';
  }

  @override
  bool operator ==(Object other) {
    return other is PushCodeToPhoneRequest &&
        runtimeType == other.runtimeType &&
        id == other.id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  PushCodeToPhoneRequest copyWith({
    String? title,
    String? question,
    String? nonce,
    String? serial,
    String? signature,
    DateTime? expirationDate,
    Uri? uri,
    bool? sslVerify,
    SignedCapabilities? signedCapabilities,
    bool? Function()? accepted,
    DeclineReason? Function()? declineReason,
    String? displayCode,
  }) {
    return PushCodeToPhoneRequest(
      title: title ?? this.title,
      question: question ?? this.question,
      nonce: nonce ?? this.nonce,
      serial: serial ?? this.serial,
      signature: signature ?? this.signature,
      expirationDate: expirationDate ?? this.expirationDate,
      uri: uri ?? this.uri,
      sslVerify: sslVerify ?? this.sslVerify,
      signedCapabilities: signedCapabilities ?? this.signedCapabilities,
      accepted: accepted != null ? accepted() : this.accepted,
      declineReason: declineReason != null
          ? declineReason()
          : this.declineReason,
      displayCode: displayCode ?? this.displayCode,
    );
  }

  @override
  PushCodeToPhoneRequest dynamicCopyWith({
    bool? Function()? accepted,
    DeclineReason? Function()? declineReason,
    String? selectedAnswer,
  }) {
    return copyWith(accepted: accepted, declineReason: declineReason);
  }
}
