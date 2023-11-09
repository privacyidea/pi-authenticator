import 'package:json_annotation/json_annotation.dart';

import '../utils/identifiers.dart';
import '../utils/logger.dart';

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

  const PushRequest({
    required this.title,
    required this.question,
    required this.uri,
    required this.nonce,
    required this.sslVerify,
    required this.id,
    required this.expirationDate,
    String? serial,
    String? signature,
    this.accepted,
  })  : serial = serial ?? '',
        signature = signature ?? '';

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
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is PushRequest && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PushRequest{title: $title, question: $question, '
        'id: $id, uri: $uri, _nonce: $nonce, sslVerify: $sslVerify, '
        'expirationDate: $expirationDate, serial: $serial, '
        'signature: $signature, accepted: $accepted}';
  }

  factory PushRequest.fromJson(Map<String, dynamic> json) => _$PushRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PushRequestToJson(this);

  factory PushRequest.fromMessageData(Map<String, dynamic> data) {
    try {
      verifyData(data);
    } catch (e, s) {
      Logger.error('Invalid push request data.', name: 'push_request.dart#fromMessageData', error: e, stackTrace: s);
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
    );
  }

  static verifyData(Map<String, dynamic> data) {
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
  }
}
