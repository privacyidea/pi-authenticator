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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/riverpod_states/token_folder_state.dart';
import '../../../../repo/preference_token_folder_repository.dart';
import '../../state_notifiers/token_folder_notifier.dart';
import '../../../logger.dart';

final tokenFolderProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>(
  (ref) {
    Logger.info("New TokenFolderNotifier created", name: 'tokenFolderProvider');
    return TokenFolderNotifier(repository: PreferenceTokenFolderRepository());
  },
  name: 'tokenFolderProvider',
);
