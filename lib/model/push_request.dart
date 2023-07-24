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
    required String title,
    required String question,
    required Uri uri,
    required String nonce,
    required bool sslVerify,
    required int id,
    required DateTime expirationDate,
    String? serial,
    String? signature,
    bool? accepted,
  })  : this.title = title,
        this.question = question,
        this.uri = uri,
        this.nonce = nonce,
        this.sslVerify = sslVerify,
        this.id = id,
        this.expirationDate = expirationDate,
        this.serial = serial ?? '',
        this.signature = signature ?? '',
        this.accepted = accepted;

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
