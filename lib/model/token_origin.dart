import 'package:json_annotation/json_annotation.dart';

import 'enums/token_origin_source_type.dart';

part 'token_origin.g.dart';

@JsonSerializable()
class TokenOriginData {
  TokenOriginSourceType source;
  String? appName;
  String data;
  TokenOriginData({required this.source, required this.data, this.appName});

  // toString prints not data because it contains the secret
  @override
  String toString() => 'TokenOrigin{source: $source, app: $appName}';

  factory TokenOriginData.fromJson(Map<String, dynamic> json) => _$TokenOriginDataFromJson(json);

  Map<String, dynamic> toJson() => _$TokenOriginDataToJson(this);
}
