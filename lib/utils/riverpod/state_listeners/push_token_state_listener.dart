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
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import 'package:privacyidea_authenticator/views/view_interface.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../interfaces/riverpod/state_listeners/state_notifier_provider_listeners/token_state_listener.dart';
import '../../../model/riverpod_states/token_state.dart';

class PushProviderTokenStateListener extends TokenStateListener {
  const PushProviderTokenStateListener({required super.provider})
      : super(
          onNewState: _onNewState,
          listenerName: 'pushRequestProvider: initFirebase',
        );

  static void _onNewState(AsyncValue<TokenState>? previous, AsyncValue<TokenState> next, WidgetRef ref) {
    final previousValue = previous?.valueOrNull;
    final nextValue = next.valueOrNull;
    if (previousValue?.needsFirebase == nextValue?.needsFirebase) return;
    if (nextValue?.needsFirebase != true) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pushRequestProvider.notifier).initFirebase();
    });
  }
}
