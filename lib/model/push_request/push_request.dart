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

part 'push_request.g.dart';

@JsonSerializable(createFactory: false)
abstract class PushRequest {
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
  });

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
  });

  factory PushRequest.fromJson(Map<String, dynamic> json) =>
      PushRequestFactory.fromJson(json);

  Map<String, dynamic> toJson() => _$PushRequestToJson(this);

  @JsonKey(includeFromJson: false, includeToJson: false)
  int get id => nonce.hashCode;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get signedData;

  Map<String, dynamic> getResponseData(PushToken token) => {
    'serial': token.serial,
    'nonce': nonce,
    if (accepted == false) 'decline': '1',
  };

  String getResponseSignMsg(PushToken token) =>
      '$nonce|${token.serial}${accepted == false ? '|decline' : ''}';

  bool verifySignature(PushToken token, {RsaUtils rsaUtils = const RsaUtils()});

  @override
  String toString() {
    return 'PushRequest{type: $type, title: $title, question: $question, '
        'id: $id, uri: $uri, nonce: $nonce, sslVerify: $sslVerify, '
        'expirationDate: $expirationDate, serial: $serial, '
        'signature: $signature, accepted: $accepted}';
  }

  @override
  bool operator ==(Object other) {
    return other is PushRequest &&
        runtimeType == other.runtimeType &&
        id == other.id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Verify that the data is valid.
  /// Throws ArgumentError if data is invalid
  static void verifyMessageData(Map<String, dynamic> data) {
    if (data[TITLE] is! String) {
      throw ArgumentError(
        'Push request title is ${data[TITLE].runtimeType}. Expected String.',
      );
    }
    if (data[QUESTION] is! String) {
      throw ArgumentError(
        'Push request question is ${data[QUESTION].runtimeType}. Expected String.',
      );
    }
    if (data[URL] is! String) {
      throw ArgumentError(
        'Push request url is ${data[URL].runtimeType}. Expected String.',
      );
    } else if (Uri.tryParse(data[URL]) == null) {
      throw ArgumentError('Push request url is a String but not a valid Uri.');
    }
    if (data[NONCE] is! String) {
      throw ArgumentError(
        'Push request nonce is ${data[NONCE].runtimeType}. Expected String.',
      );
    }
    if (data[SSL_VERIFY] is! String) {
      throw ArgumentError(
        'Push request sslVerify is ${data[SSL_VERIFY].runtimeType}. Expected String.',
      );
    }
    if (data[SERIAL] is! String) {
      throw ArgumentError(
        'Push request serial is ${data[SERIAL].runtimeType}. Expected String.',
      );
    }
    if (data[SIGNATURE] is! String) {
      throw ArgumentError(
        'Push request signature is ${data[SIGNATURE].runtimeType}. Expected String.',
      );
    }

    Logger.debug('Push request data ($data) is valid.');
  }
}
