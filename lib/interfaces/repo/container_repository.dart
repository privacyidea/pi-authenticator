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

import '../../model/token_container.dart';

abstract class TokenContainerRepository {
  /// Save the container state to the repository
  /// Returns the state that was actually written
  Future<TokenContainer> saveContainerState(TokenContainer containerState);

  /// Load the container state from the repository
  /// Returns the loaded state
  Future<TokenContainer> loadContainerState();

  // /// Save a token template to the repository
  // /// Returns the template that was actually written
  // Future<TokenTemplate> saveTokenTemplate(TokenTemplate tokenTemplate);

  // /// Load a token template from the repository
  // /// Returns the loaded template
  // Future<TokenTemplate?> loadTokenTemplate(String tokenTemplateId);
}
