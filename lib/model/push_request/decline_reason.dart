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

/// The reason a push request was declined, sent to the server as
/// `decline_reason` and included in the signed payload.
enum DeclineReason {
  /// The push request was not triggered by the user.
  unknownTrigger,

  /// The push request was triggered by the user, but is being cancelled anyway.
  cancelled;

  String get value => switch (this) {
    DeclineReason.unknownTrigger => 'unknown_trigger',
    DeclineReason.cancelled => 'cancelled',
  };
}
