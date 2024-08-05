/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
