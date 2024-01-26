import 'package:json_annotation/json_annotation.dart';

import 'enums/token_origin_source_type.dart';

part 'token_origin.g.dart';

@JsonSerializable()
class TokenOrigin {
  TokenOriginSourceType source;
  String? appName;
  String data;
  TokenOrigin({required this.source, required this.data, this.appName});

  // toString prints not data because it contains the secret
  @override
  String toString() => 'TokenOrigin{source: $source, app: $appName}';

  factory TokenOrigin.fromJson(Map<String, dynamic> json) => _$TokenOriginFromJson(json);

  Map<String, dynamic> toJson() => _$TokenOriginToJson(this);
}
