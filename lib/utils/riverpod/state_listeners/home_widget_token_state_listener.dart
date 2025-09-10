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
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../interfaces/riverpod/state_listeners/state_notifier_provider_listeners/token_state_listener.dart';
import '../../../model/riverpod_states/token_state.dart';
import '../../../model/tokens/hotp_token.dart';
import '../../../model/tokens/token.dart';
import '../../home_widget_utils.dart';

class HomeWidgetTokenStateListener extends TokenStateListener {
  const HomeWidgetTokenStateListener({required super.provider}) : super(onNewState: _onNewState, listenerName: 'HomeWidgetUtils().updateTokensIfLinked');

  static void _onNewState(AsyncValue<TokenState>? previous, AsyncValue<TokenState> next, WidgetRef ref) {
    final updateTokens = <Token>[];
    final previousTokens = previous?.value?.tokens ?? [];
    final nextTokens = next.value?.lastlyUpdatedTokens ?? [];
    for (final nextToken in nextTokens) {
      final previousToken = previousTokens.firstWhereOrNull((previousToken) => previousToken.id == nextToken.id);
      if (previousToken == null) {
        updateTokens.add(nextToken);
        continue;
      }
      if (previousToken.issuer != nextToken.issuer ||
          previousToken.label != nextToken.label ||
          previousToken.isLocked != nextToken.isLocked ||
          (previousToken is HOTPToken && nextToken is HOTPToken && previousToken.counter != nextToken.counter)) {
        updateTokens.add(nextToken);
      }
    }
    HomeWidgetUtils().updateTokensIfLinked(updateTokens);
  }
}
