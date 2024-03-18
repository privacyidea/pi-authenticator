import 'package:json_annotation/json_annotation.dart';

import '../enums/token_origin_source_type.dart';

part 'token_origin_data.g.dart';

@JsonSerializable()
class TokenOriginData {
  TokenOriginSourceType source;
  String? appName;
  String data;
  TokenOriginData({required this.source, required this.data, this.appName});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokenOriginData && other.source == source && other.appName == appName && other.data == data;
  }

  @override
  int get hashCode => Object.hashAll([source, appName, data]);

  // toString prints not data because it contains the secret
  @override
  String toString() => 'TokenOrigin{source: $source, app: $appName}';

  factory TokenOriginData.fromJson(Map<String, dynamic> json) => _$TokenOriginDataFromJson(json);

  Map<String, dynamic> toJson() => _$TokenOriginDataToJson(this);
}
