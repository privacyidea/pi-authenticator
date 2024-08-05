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

import '../../../../model/mixins/sortable_mixin.dart';
import '../../../../model/riverpod_states/token_folder_state.dart';
import '../../../../model/riverpod_states/token_state.dart';
import '../../state_notifiers/sortable_notifier.dart';
import '../../../logger.dart';
import 'token_folder_provider.dart';
import 'token_provider.dart';

final sortableProvider = StateNotifierProvider<SortableNotifier, List<SortableMixin>>(
  (ref) {
    final SortableNotifier notifier = SortableNotifier(ref: ref);
    Logger.info("New sortableProvider created", name: 'sortableProvider');
    ref.listen(tokenProvider, (previous, next) => notifier.handleNewStateList(next.tokens));
    ref.listen(tokenFolderProvider, (previous, next) => notifier.handleNewStateList(next.folders));
    Future.wait(
      [ref.read(tokenProvider.notifier).initState, ref.read(tokenFolderProvider.notifier).initState],
    ).then((values) {
      final sortables = <SortableMixin>[];
      for (final v in values) {
        if (v is TokenState) {
          sortables.addAll(v.tokens);
        } else if (v is TokenFolderState) {
          sortables.addAll(v.folders);
        }
      }
      notifier.handleNewStateList(sortables);
    });
    return notifier;
  },
);
