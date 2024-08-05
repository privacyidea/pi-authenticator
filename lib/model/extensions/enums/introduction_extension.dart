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

import '../../../l10n/app_localizations.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/settings_provider.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';
import '../../enums/introduction.dart';
import '../../riverpod_states/introduction_state.dart';

extension IntroductionX on Introduction {
  /// Checks if the condition for the given state is fulfilled.
  /// Given ref might be watched to acces the state of different providers.
  bool isConditionFulfilled(WidgetRef ref, IntroductionState state) => switch (this) {
        Introduction.introductionScreen => state.isUncompleted(Introduction.introductionScreen),
        Introduction.scanQrCode => state.isUncompleted(Introduction.scanQrCode),
        Introduction.addManually => state.isCompleted(Introduction.scanQrCode) && state.isUncompleted(Introduction.addManually),
        Introduction.tokenSwipe =>
          ref.watch(tokenProvider).tokens.isNotEmpty && state.isCompleted(Introduction.addManually) && state.isUncompleted(Introduction.tokenSwipe),
        Introduction.editToken => state.isCompleted(Introduction.tokenSwipe) && state.isUncompleted(Introduction.editToken),
        Introduction.lockToken => state.isCompleted(Introduction.editToken) && state.isUncompleted(Introduction.lockToken),
        Introduction.dragToken =>
          ref.watch(tokenProvider).tokens.length >= 2 && state.isCompleted(Introduction.tokenSwipe) && state.isUncompleted(Introduction.dragToken),
        Introduction.addFolder => ref.watch(tokenProvider).tokens.length >= 3 &&
            state.isCompleted(Introduction.dragToken) &&
            state.isUncompleted(Introduction.addFolder) &&
            Introduction.dragToken.isConditionFulfilled(ref, state) == false,
        Introduction.pollForChallenges => ref.watch(tokenProvider).pushTokens.firstOrNull?.isRolledOut == true &&
            state.isCompleted(Introduction.tokenSwipe) &&
            state.isUncompleted(Introduction.pollForChallenges) &&
            Introduction.dragToken.isConditionFulfilled(ref, state) == false &&
            Introduction.addFolder.isConditionFulfilled(ref, state) == false,
        Introduction.hidePushTokens =>
          ref.watch(settingsProvider).hidePushTokens && state.isCompleted(Introduction.pollForChallenges) && state.isUncompleted(Introduction.hidePushTokens),
        Introduction.exportTokens => state.isUncompleted(Introduction.exportTokens),
      };

  String hintText(AppLocalizations localizations) => switch (this) {
        Introduction.introductionScreen => 'Not implemented',
        Introduction.scanQrCode => localizations.introScanQrCode,
        Introduction.addManually => localizations.introAddTokenManually,
        Introduction.tokenSwipe => localizations.introTokenSwipe,
        Introduction.editToken => localizations.introEditToken,
        Introduction.lockToken => localizations.introLockToken,
        Introduction.dragToken => localizations.introDragToken,
        Introduction.addFolder => localizations.introAddFolder,
        Introduction.pollForChallenges => localizations.introPollForChallenges,
        Introduction.hidePushTokens => localizations.introHidePushTokens,
        Introduction.exportTokens => 'Not implemented',
      };
}
