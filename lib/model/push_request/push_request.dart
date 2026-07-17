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
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart'
    show PushRequestFactory;

import '../../utils/logger.dart';
import '../../utils/rsa_utils.dart';
import '../tokens/push_token.dart';
import 'decline_reason.dart';

part 'push_request.g.dart';

@JsonSerializable(createFactory: false)
abstract class PushRequest {
  // Keys used in the incoming push message data.
  static const String NONCE = 'nonce';
  static const String URL = 'url';
  static const String SERIAL = 'serial';
  static const String QUESTION = 'question';
  static const String TITLE = 'title';
  static const String SSL_VERIFY = 'sslverify';
  static const String SIGNATURE = 'signature';

  final String type;
  final String title;
  final String question;
  final String nonce;
  final String serial;
  final String signature;
  final DateTime expirationDate;
  final Uri uri;
  final bool sslVerify;
  final bool? accepted;
  final DeclineReason? declineReason;

  const PushRequest({
    required this.type,
    required this.title,
    required this.question,
    required this.nonce,
    required this.serial,
    required this.signature,
    required this.expirationDate,
    required this.uri,
    required this.sslVerify,
    this.accepted,
    this.declineReason,
  });

  factory PushRequest.fromJson(Map<String, dynamic> json) =>
      PushRequestFactory.fromJson(json);

  PushRequest copyWith({
    String? title,
    String? question,
    String? nonce,
    String? serial,
    String? signature,
    DateTime? expirationDate,
    Uri? uri,
    bool? sslVerify,
    bool? Function()? accepted,
    DeclineReason? Function()? declineReason,
  });

  /// Dynamically applies an update to this push request. Unlike [copyWith],
  /// this is available on the base type so callers that only hold a
  /// [PushRequest] (not a concrete subtype) can still update it.
  PushRequest dynamicCopyWith({
    bool? Function()? accepted,
    DeclineReason? Function()? declineReason,
    String? selectedAnswer,
  });

  Map<String, dynamic> toJson() => _$PushRequestToJson(this);

  @JsonKey(includeFromJson: false, includeToJson: false)
  int get id => nonce.hashCode;

  /// The data that is signed by the server and must be verified against
  /// [signature] to trust an incoming push request.
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get signedData;

  bool verifySignature(PushToken token, {RsaUtils rsaUtils = const RsaUtils()});

  /// The form data sent back to the server as the response to this push
  /// request.
  Map<String, dynamic> getResponseData(PushToken token) => {
    'serial': token.serial,
    'nonce': nonce,
    if (accepted == false) 'decline': '1',
    if (accepted == false && declineReason != null)
      'decline_reason': declineReason!.value,
  };

  /// The message that must be signed with the token's private key and sent
  /// alongside [getResponseData] to authenticate the response.
  String getResponseSignMsg(PushToken token) =>
      '$nonce|${token.serial}'
      '${accepted == false ? '|decline' : ''}'
      '${accepted == false && declineReason != null ? '|${declineReason!.value}' : ''}';

  @override
  String toString() =>
      'PushRequest{type: $type, title: $title, question: $question, '
      'id: $id, uri: $uri, nonce: $nonce, sslVerify: $sslVerify, '
      'expirationDate: $expirationDate, serial: $serial, '
      'signature: $signature, accepted: $accepted, '
      'declineReason: $declineReason}';

  @override
  bool operator ==(Object other) =>
      other is PushRequest &&
      runtimeType == other.runtimeType &&
      id == other.id;

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Verifies that [data] contains all fields required to construct a
  /// [PushRequest].
  /// Throws an [ArgumentError] if a field is missing or has the wrong type.
  static void verifyMessageData(Map<String, dynamic> data) {
    const requiredStringFields = [
      TITLE,
      QUESTION,
      URL,
      NONCE,
      SSL_VERIFY,
      SERIAL,
      SIGNATURE,
    ];
    for (final field in requiredStringFields) {
      if (data[field] is! String) {
        throw ArgumentError(
          'Push request $field is ${data[field].runtimeType}. Expected String.',
        );
      }
    }
    if (Uri.tryParse(data[URL] as String) == null) {
      throw ArgumentError('Push request url is a String but not a valid Uri.');
    }

    Logger.debug('Push request data ($data) is valid.');
  }
}
