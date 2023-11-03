import 'package:json_annotation/json_annotation.dart';

enum Introduction {
  @JsonValue('introductionScreen')
  introductionScreen, // 1st start
  @JsonValue('scanQrCode')
  scanQrCode, // 1st start && introductionScreen
  @JsonValue('addManually')
  addTokenManually, // 1st start && scanQrCode
  @JsonValue('tokenSwipe')
  tokenSwipe, // 1st token
  @JsonValue('editToken')
  editToken, // 1st token && tokenSwipe
  @JsonValue('lockToken')
  lockToken, // 1st token && editToken
  @JsonValue('addFolder')
  addFolder, // 3 tokens && 0 groups
  @JsonValue('pollForChanges')
  pollForChanges, // 1st push token && lockToken
  @JsonValue('hidePushTokens')
  hidePushTokens, // hiding is enabled
}
