/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

class DeepLink {
  final Uri uri;
  final bool fromInit;
  const DeepLink(this.uri, {this.fromInit = false});

  // Intentionally no == / hashCode override: each DeepLink represents a
  // distinct incoming event (e.g. a widget tap), not a piece of state.
  // Riverpod's ref.listen skips notifying listeners when the new state
  // equals the previous one, which would silently drop repeated identical
  // deep links (e.g. tapping the same home widget link twice in a row).

  @override
  String toString() => 'DeepLink(uri: $uri, fromInit: $fromInit)';
}
