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

import '../../utils/globals.dart';
import '../../utils/logger.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../utils/rsa_utils.dart';
import '../capabilities/capabilities.dart';
import '../tokens/push_token.dart';
import 'decline_reason.dart';
import 'push_request.dart';

part 'push_default_request.g.dart';

@JsonSerializable()
class PushDefaultRequest extends PushRequest {
  static const String TYPE = 'default';

  PushDefaultRequest({
    required super.title,
    required super.question,
    required super.nonce,
    required super.serial,
    required super.signature,
    required super.expirationDate,
    required super.uri,
    required super.sslVerify,
    super.signedCapabilities,
    super.type = PushDefaultRequest.TYPE,
    super.accepted,
    super.declineReason,
  });

  factory PushDefaultRequest.fromJson(Map<String, dynamic> json) =>
      _$PushDefaultRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PushDefaultRequestToJson(this);

  @override
  String get signedData =>
      '$nonce|$uri|$serial|$question|$title|${sslVerify ? '1' : '0'}';

  factory PushDefaultRequest.fromMessageData(Map<String, dynamic> data) {
    try {
      verifyMessageData(data);
    } catch (e, s) {
      Logger.error('Invalid push request data.', error: e, stackTrace: s);
    }
    return PushDefaultRequest(
      title: data[PushRequest.TITLE],
      question: data[PushRequest.QUESTION],
      uri: Uri.parse(data[PushRequest.URL]),
      nonce: data[PushRequest.NONCE],
      sslVerify: data[PushRequest.SSL_VERIFY] == '1',
      serial: data[PushRequest.SERIAL],
      expirationDate: DateTime.now().add(const Duration(minutes: 2)),
      signature: data[PushRequest.SIGNATURE],
      signedCapabilities: SignedCapabilities.fromMessageData(data),
    );
  }

  @override
  bool verifySignature(
    PushToken token, {
    RsaUtils rsaUtils = const RsaUtils(),
  }) {
    // Re-add url and sslverify to android legacy tokens:
    if (token.url == null) {
      globalRef
          ?.read(tokenProvider.notifier)
          .updateToken(
            token,
            (p0) => p0.copyWith(url: uri, sslVerify: sslVerify),
          );
    }
    return super.verifySignature(token, rsaUtils: rsaUtils);
  }

  /// Verify that the data is valid.
  static void verifyMessageData(Map<String, dynamic> data) {
    PushRequest.verifyMessageData(data);
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
    return 'PushDefaultRequest{title: $title, question: $question, '
        'id: $id, uri: $uri, nonce: $nonce, sslVerify: $sslVerify, '
        'expirationDate: $expirationDate, serial: $serial, '
        'signature: $signature, signedCapabilities: $signedCapabilities, '
        'accepted: $accepted, declineReason: $declineReason}';
  }

  @override
  bool operator ==(Object other) {
    return other is PushDefaultRequest &&
        runtimeType == other.runtimeType &&
        id == other.id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  PushDefaultRequest copyWith({
    String? title,
    String? question,
    Uri? uri,
    String? nonce,
    bool? sslVerify,
    DateTime? expirationDate,
    String? serial,
    String? signature,
    SignedCapabilities? signedCapabilities,
    bool? Function()? accepted,
    DeclineReason? Function()? declineReason,
  }) {
    return PushDefaultRequest(
      title: title ?? this.title,
      question: question ?? this.question,
      uri: uri ?? this.uri,
      nonce: nonce ?? this.nonce,
      sslVerify: sslVerify ?? this.sslVerify,
      expirationDate: expirationDate ?? this.expirationDate,
      serial: serial ?? this.serial,
      signature: signature ?? this.signature,
      signedCapabilities: signedCapabilities ?? this.signedCapabilities,
      accepted: accepted != null ? accepted() : this.accepted,
      declineReason: declineReason != null
          ? declineReason()
          : this.declineReason,
    );
  }

  @override
  PushDefaultRequest dynamicCopyWith({
    bool? Function()? accepted,
    DeclineReason? Function()? declineReason,
    String? selectedAnswer,
  }) {
    return copyWith(accepted: accepted, declineReason: declineReason);
  }
}
