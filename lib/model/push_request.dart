/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, emailemailemailVersion 2.0 (the 'License');
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

import 'package:base32/base32.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/globals.dart';
import '../utils/identifiers.dart';
import '../utils/logger.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../utils/rsa_utils.dart';
import 'tokens/push_token.dart';

part 'push_request.g.dart';

@JsonSerializable()
class PushRequest {
  final String title;
  final String question;
  final int id;
  final Uri uri;
  final String nonce;
  final bool sslVerify;
  final DateTime expirationDate;
  final String serial;
  final String signature;
  final bool? accepted;
  final List<String>? possibleAnswers;
  final String? selectedAnswer;

  const PushRequest({
    required this.title,
    required this.question,
    required this.uri,
    required this.nonce,
    required this.sslVerify,
    required this.id,
    required this.expirationDate,
    this.serial = '',
    this.signature = '',
    this.accepted,
    this.possibleAnswers,
    this.selectedAnswer,
  });

  PushRequest copyWith({
    String? title,
    String? question,
    Uri? uri,
    String? nonce,
    bool? sslVerify,
    int? id,
    DateTime? expirationDate,
    String? serial,
    String? signature,
    bool? accepted,
    List<String> Function()? possibleAnswers,
    String? Function()? selectedAnswer,
  }) {
    return PushRequest(
      title: title ?? this.title,
      question: question ?? this.question,
      uri: uri ?? this.uri,
      nonce: nonce ?? this.nonce,
      sslVerify: sslVerify ?? this.sslVerify,
      id: id ?? this.id,
      expirationDate: expirationDate ?? this.expirationDate,
      serial: serial ?? this.serial,
      signature: signature ?? this.signature,
      accepted: accepted ?? this.accepted,
      possibleAnswers: possibleAnswers != null ? possibleAnswers() : this.possibleAnswers,
      selectedAnswer: selectedAnswer != null ? selectedAnswer() : this.selectedAnswer,
    );
  }

  @override
  bool operator ==(Object other) => other is PushRequest && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PushRequest{title: $title, question: $question, '
        'id: $id, uri: $uri, _nonce: $nonce, sslVerify: $sslVerify, '
        'expirationDate: $expirationDate, serial: $serial, '
        'signature: $signature, accepted: $accepted, '
        'answers: $possibleAnswers, selectedAnswer: $selectedAnswer}';
  }

  factory PushRequest.fromJson(Map<String, dynamic> json) => _$PushRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PushRequestToJson(this);

  factory PushRequest.fromMessageData(Map<String, dynamic> data) {
    try {
      verifyData(data);
    } catch (e, s) {
      Logger.error('Invalid push request data.', error: e, stackTrace: s);
    }
    return PushRequest(
      title: data[PUSH_REQUEST_TITLE],
      question: data[PUSH_REQUEST_QUESTION],
      uri: Uri.parse(data[PUSH_REQUEST_URL]),
      nonce: data[PUSH_REQUEST_NONCE],
      id: data[PUSH_REQUEST_NONCE].hashCode,
      sslVerify: data[PUSH_REQUEST_SSL_VERIFY] == '1',
      serial: data[PUSH_REQUEST_SERIAL],
      expirationDate: DateTime.now().add(const Duration(minutes: 2)),
      signature: data[PUSH_REQUEST_SIGNATURE],
      possibleAnswers: data[PUSH_REQUEST_ANSWERS] != null ? (data[PUSH_REQUEST_ANSWERS] as String).split(',') : null,
    );
  }

  /// Verify that the data is valid.
  /// Throws ArgumentError if data is invalid
  static void verifyData(Map<String, dynamic> data) {
    if (data[PUSH_REQUEST_TITLE] is! String) {
      throw ArgumentError('Push request title is ${data[PUSH_REQUEST_TITLE].runtimeType}. Expected String.');
    }
    if (data[PUSH_REQUEST_QUESTION] is! String) {
      throw ArgumentError('Push request question is ${data[PUSH_REQUEST_QUESTION].runtimeType}. Expected String.');
    }
    if (data[PUSH_REQUEST_URL] is! String) {
      throw ArgumentError('Push request url is ${data[PUSH_REQUEST_URL].runtimeType}. Expected String.');
    } else if (Uri.tryParse(data[PUSH_REQUEST_URL]) == null) {
      throw ArgumentError('Push request url is a String but not a valid Uri.');
    }
    if (data[PUSH_REQUEST_NONCE] is! String) {
      throw ArgumentError('Push request nonce is ${data[PUSH_REQUEST_NONCE].runtimeType}. Expected String.');
    }
    if (data[PUSH_REQUEST_SSL_VERIFY] is! String) {
      throw ArgumentError('Push request sslVerify is ${data[PUSH_REQUEST_SSL_VERIFY].runtimeType}. Expected String.');
    }
    if (data[PUSH_REQUEST_SERIAL] is! String) {
      throw ArgumentError('Push request serial is ${data[PUSH_REQUEST_SERIAL].runtimeType}. Expected String.');
    }
    if (data[PUSH_REQUEST_SIGNATURE] is! String) {
      throw ArgumentError('Push request signature is ${data[PUSH_REQUEST_SIGNATURE].runtimeType}. Expected String.');
    }
    if (data[PUSH_REQUEST_ANSWERS] is! String?) {
      throw ArgumentError('Push request answers is ${data[PUSH_REQUEST_ANSWERS].runtimeType}. Expected List<String> or null.');
    }
    Logger.debug('Push request data ($data) is valid.');
  }

  Future<bool> verifySignature(PushToken token, {RsaUtils rsaUtils = const RsaUtils()}) async {
    //5NV6KJCFCLNQURT2ZTBRHHGY6FDXOCOR|http://192.168.178.22:5000/ttype/push|PIPU0000E793|Pick a Number!|privacyIDEA|0|["A", "B", "C"]
    Logger.info('Adding push request to token');
    String signedData = '$nonce|'
        '$uri|'
        '$serial|'
        '$question|'
        '$title|'
        '${sslVerify ? '1' : '0'}'
        '${possibleAnswers != null ? '|${possibleAnswers!.join(",")}' : ''}';
    Logger.warning('Signed data: $signedData');

    // Re-add url and sslverify to android legacy tokens:
    if (token.url == null) {
      globalRef?.read(tokenProvider.notifier).updateToken(token, (p0) => p0.copyWith(url: uri, sslVerify: sslVerify));
    }

    bool isVerified = rsaUtils.verifyRSASignature(token.rsaPublicServerKey!, utf8.encode(signedData), base32.decode(signature));

    if (!isVerified) {
      Logger.warning(
        'Validating incoming message failed.',
        error: 'Signature does not match signed data.',
      );
      return false;
    }
    Logger.info('Validating incoming message was successful.');
    return true;
  }
}
