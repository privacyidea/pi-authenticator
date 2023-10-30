import 'package:json_annotation/json_annotation.dart';

enum Introduction {
  @JsonValue('easyAuthentication')
  easyAuthentication, // 1st start
  @JsonValue('maximaleSecurity')
  maximaleSecurity, // 1st start
  @JsonValue('visitOnGithub')
  visitOnGithub, // 1st start
  @JsonValue('scanQrCode')
  scanQrCode, // 1st start
  @JsonValue('addManually')
  addManually, // 1st start
  @JsonValue('tokenSwipe')
  tokenSwipe, // 1st token
  @JsonValue('editToken')
  editToken, // 1st token && tokenSwipe
  @JsonValue('lockToken')
  lockToken, // 1st token && editToken
  @JsonValue('groupTokens')
  groupTokens, // 3 tokens && 0 groups
  @JsonValue('pollForChanges')
  pollForChanges, // 1st push token && lockToken
  @JsonValue('hidePushToken')
  hidePushToken, // hiding is enabled
}
