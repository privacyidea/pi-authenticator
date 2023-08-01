import 'package:json_annotation/json_annotation.dart';

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

  PushRequest({
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
}
