// Do not rename or remove values, they are used for serialization. Only add new values.
enum Introduction {
  introductionScreen, // 1st start
  scanQrCode, // 1st start && introductionScreen
  addManually, // 1st start && scanQrCode
  tokenSwipe, // 1st token
  editToken, // 1st token && tokenSwipe
  lockToken, // 1st token && editToken
  dragToken, // 2nd token && tokenSwipe
  addFolder, // 3 tokens && 0 groups
  pollForChallenges, // 1st push token && lockToken
  hidePushTokens, // hiding is enabled
  exportTokens, // has to be accepted to export tokens
}
