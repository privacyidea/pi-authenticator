import 'dart:convert';

import 'package:base32/base32.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../utils/logger.dart';
import '../../utils/rsa_utils.dart';
import '../tokens/push_token.dart';
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
    super.type = PushCodeToPhoneRequest.TYPE,
    super.accepted,
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
      displayCode: data[DISPLAY_CODE],
    );
  }

  // Verify that the data is valid.
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
  bool verifySignature(
    PushToken token, {
    RsaUtils rsaUtils = const RsaUtils(),
  }) {
    if (token.rsaPublicServerKey == null) {
      Logger.warning(
        'Validating incoming message failed.',
        error: 'Push token does not contain a public server key.',
      );
      return false;
    }
    final isVerified = rsaUtils.verifyRSASignature(
      token.rsaPublicServerKey!,
      utf8.encode(signedData),
      base32.decode(signature),
    );
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

  @override
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
      accepted: accepted != null ? accepted() : this.accepted,
      displayCode: displayCode ?? this.displayCode,
    );
  }
}
