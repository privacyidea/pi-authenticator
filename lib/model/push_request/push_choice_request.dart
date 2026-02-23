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

import 'package:base32/base32.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../utils/globals.dart';
import '../../utils/logger.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../utils/rsa_utils.dart';
import '../tokens/push_token.dart';
import 'push_default_request.dart';
import 'push_request.dart';

part 'push_choice_request.g.dart';

@JsonSerializable()
class PushChoiceRequest extends PushDefaultRequest {
  static const String SELECTED_ANSWER = 'presence_answer';
  static const String ANSWERS = 'require_presence';
  static const String TYPE = 'choice';

  final String? selectedAnswer;
  final List<String> possibleAnswers;

  PushChoiceRequest({
    required super.title,
    required super.question,
    required super.nonce,
    required super.serial,
    required super.signature,
    required super.expirationDate,
    required super.uri,
    required super.sslVerify,
    required this.possibleAnswers,
    super.type = PushChoiceRequest.TYPE,
    this.selectedAnswer,
    bool? accepted,
  }) : super(accepted: selectedAnswer != null);

  factory PushChoiceRequest.fromJson(Map<String, dynamic> json) =>
      _$PushChoiceRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PushChoiceRequestToJson(this);

  @override
  String get signedData =>
      '$nonce|$uri|$serial|$question|$title|${sslVerify ? '1' : '0'}${'|${possibleAnswers.join(",")}'}';

  factory PushChoiceRequest.fromMessageData(Map<String, dynamic> data) {
    try {
      verifyMessageData(data);
    } catch (e, s) {
      Logger.error('Invalid push request data.', error: e, stackTrace: s);
    }
    return PushChoiceRequest(
      title: data[PushRequest.TITLE],
      question: data[PushRequest.QUESTION],
      uri: Uri.parse(data[PushRequest.URL]),
      nonce: data[PushRequest.NONCE],
      sslVerify: data[PushRequest.SSL_VERIFY] == '1',
      serial: data[PushRequest.SERIAL],
      expirationDate: DateTime.now().add(const Duration(minutes: 2)),
      signature: data[PushRequest.SIGNATURE],
      possibleAnswers: (data[ANSWERS] as String).split(','),
    );
  }

  @override
  Map<String, dynamic> getResponseData(PushToken token) => {
    ...super.getResponseData(token),
    if (selectedAnswer != null) SELECTED_ANSWER: selectedAnswer,
  };

  @override
  String getResponseSignMsg(PushToken token) {
    final baseMsg = super.getResponseSignMsg(token);
    return selectedAnswer != null ? '$baseMsg|$selectedAnswer' : baseMsg;
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

    final verified = rsaUtils.verifyRSASignature(
      token.rsaPublicServerKey!,
      utf8.encode(signedData),
      base32.decode(signature),
    );
    if (!verified) {
      Logger.warning(
        'Validating incoming message failed.',
        error: 'Signature does not match signed data.',
      );
      return false;
    }
    Logger.info('Validating incoming message was successful.');
    return true;
  }

  // Verify that the data is valid.
  static void verifyMessageData(Map<String, dynamic> data) {
    PushDefaultRequest.verifyMessageData(data);
    if (data[ANSWERS] is! String) {
      throw ArgumentError(
        'Push request answers is ${data[ANSWERS].runtimeType}. Expected String.',
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PushChoiceRequest &&
        runtimeType == other.runtimeType &&
        id == other.id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PushChoiceRequest{title: $title, question: $question, '
        'id: $id, uri: $uri, _nonce: $nonce, sslVerify: $sslVerify, '
        'expirationDate: $expirationDate, serial: $serial, '
        'signature: $signature, accepted: $accepted, '
        'possibleAnswers: $possibleAnswers, selectedAnswer: $selectedAnswer}';
  }

  @override
  PushChoiceRequest copyWith({
    String? title,
    String? question,
    Uri? uri,
    String? nonce,
    bool? sslVerify,
    DateTime? expirationDate,
    String? serial,
    String? signature,
    List<String>? possibleAnswers,
    String? selectedAnswer,
    bool? Function()? accepted,
  }) {
    return PushChoiceRequest(
      title: title ?? this.title,
      question: question ?? this.question,
      uri: uri ?? this.uri,
      nonce: nonce ?? this.nonce,
      sslVerify: sslVerify ?? this.sslVerify,
      expirationDate: expirationDate ?? this.expirationDate,
      serial: serial ?? this.serial,
      signature: signature ?? this.signature,
      possibleAnswers: possibleAnswers ?? this.possibleAnswers,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      accepted: accepted != null ? accepted() : this.accepted,
    );
  }
}
