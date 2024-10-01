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

import 'package:privacyidea_authenticator/l10n/app_localizations.dart';

import '../../enums/rollout_state.dart';

extension RolloutStateX on RolloutState {
  bool get rolloutStarted => this != RolloutState.notStarted;

  bool get rollOutInProgress => switch (this) {
        RolloutState.notStarted => false,
        RolloutState.generatingKeyPair => true,
        RolloutState.generatingKeyPairFailed => false,
        RolloutState.generatingKeyPairCompleted => false,
        RolloutState.sendingPublicKey => true,
        RolloutState.sendingPublicKeyFailed => false,
        RolloutState.sendingPublicKeyCompleted => false,
        RolloutState.parsingResponse => true,
        RolloutState.parsingResponseFailed => false,
        RolloutState.parsingResponseCompleted => false,
        RolloutState.completed => false,
      };

  bool get isFailed => switch (this) {
        RolloutState.notStarted => false,
        RolloutState.generatingKeyPair => false,
        RolloutState.generatingKeyPairFailed => true,
        RolloutState.generatingKeyPairCompleted => false,
        RolloutState.sendingPublicKey => false,
        RolloutState.sendingPublicKeyFailed => true,
        RolloutState.sendingPublicKeyCompleted => false,
        RolloutState.parsingResponse => false,
        RolloutState.parsingResponseFailed => true,
        RolloutState.parsingResponseCompleted => false,
        RolloutState.completed => false,
      };

  String rolloutMsg(AppLocalizations localizations) => switch (this) {
        RolloutState.notStarted => localizations.rolloutStateNotStarted,
        RolloutState.generatingKeyPair => localizations.rolloutStateGeneratingKeyPair,
        RolloutState.generatingKeyPairFailed => localizations.rolloutStateGeneratingKeyPairFailed,
        RolloutState.generatingKeyPairCompleted => localizations.rolloutStateGeneratingKeyPairCompleted,
        RolloutState.sendingPublicKey => localizations.rolloutStateSendingPublicKey,
        RolloutState.sendingPublicKeyFailed => localizations.rolloutStateSendingPublicKeyFailed,
        RolloutState.sendingPublicKeyCompleted => localizations.rolloutStateSendingPublicKeyCompleted,
        RolloutState.parsingResponse => localizations.rolloutStateParsingResponse,
        RolloutState.parsingResponseFailed => localizations.rolloutStateParsingResponseFailed,
        RolloutState.parsingResponseCompleted => localizations.rolloutStateParsingResponseCompleted,
        RolloutState.completed => localizations.rolloutStateCompleted,
      };
}
