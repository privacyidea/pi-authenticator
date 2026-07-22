/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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

import '../capabilities/capabilities.dart';

/// Names of the optional push features this app knows about, the vocabulary
/// shared with the server.
abstract final class PushCapability {
  /// Sending the reason why a push request was declined.
  static const String declineReason = 'decline_reason';
}

/// The push features this app implements.
///
/// Announced to the server when a push token is enrolled and negotiated against
/// what a server advertises.
final Capabilities appPushCapabilities = Capabilities.declared({
  PushCapability.declineReason: true,
});
