import 'package:json_annotation/json_annotation.dart';

part 'push_request.g.dart';

@JsonSerializable()
class PushRequest {
  String _title;
  String _question;

  int _id;

  Uri _uri;
  String _nonce;
  bool _sslVerify;

  DateTime _expirationDate;

  DateTime get expirationDate => _expirationDate;

  int get id => _id;

  String get nonce => _nonce;

  bool get sslVerify => _sslVerify;

  Uri get uri => _uri;

  String get question => _question;

  String get title => _title;

  PushRequest(
      {required String title,
      required String question,
      required Uri uri,
      required String nonce,
      required bool sslVerify,
      required int id,
      required DateTime expirationDate})
      : this._title = title,
        this._question = question,
        this._uri = uri,
        this._nonce = nonce,
        this._sslVerify = sslVerify,
        this._id = id,
        this._expirationDate = expirationDate;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PushRequest && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    return 'PushRequest{_title: $_title, _question: $_question,'
        ' _id: $_id, _uri: $_uri, _nonce: $_nonce, _sslVerify: $_sslVerify}';
  }

  factory PushRequest.fromJson(Map<String, dynamic> json) => _$PushRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PushRequestToJson(this);
}
