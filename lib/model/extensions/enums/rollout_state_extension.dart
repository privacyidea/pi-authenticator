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

import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../l10n/app_localizations_en.dart';
import '../../enums/rollout_state.dart';

extension RolloutStateX on FinalizationState {
  bool get rolloutStarted => this != FinalizationState.notStarted;

  bool get rollOutInProgress => switch (this) {
        FinalizationState.notStarted => false,
        FinalizationState.generatingKeyPair => true,
        FinalizationState.generatingKeyPairFailed => false,
        FinalizationState.generatingKeyPairCompleted => false,
        FinalizationState.sendingPublicKey => true,
        FinalizationState.sendingPublicKeyFailed => false,
        FinalizationState.sendingPublicKeyCompleted => false,
        FinalizationState.parsingResponse => true,
        FinalizationState.parsingResponseFailed => false,
        FinalizationState.parsingResponseCompleted => false,
        FinalizationState.completed => false,
      };
  FinalizationState get asFailed => switch (this) {
        FinalizationState.notStarted => FinalizationState.notStarted,
        FinalizationState.generatingKeyPair => FinalizationState.generatingKeyPairFailed,
        FinalizationState.generatingKeyPairFailed => FinalizationState.generatingKeyPairFailed,
        FinalizationState.generatingKeyPairCompleted => FinalizationState.generatingKeyPairFailed,
        FinalizationState.sendingPublicKey => FinalizationState.sendingPublicKeyFailed,
        FinalizationState.sendingPublicKeyFailed => FinalizationState.sendingPublicKeyFailed,
        FinalizationState.sendingPublicKeyCompleted => FinalizationState.sendingPublicKeyFailed,
        FinalizationState.parsingResponse => FinalizationState.parsingResponseFailed,
        FinalizationState.parsingResponseFailed => FinalizationState.parsingResponseFailed,
        FinalizationState.parsingResponseCompleted => FinalizationState.parsingResponseFailed,
        FinalizationState.completed => FinalizationState.completed,
      };

  FinalizationState get asCompleted => switch (this) {
        FinalizationState.notStarted => FinalizationState.notStarted,
        FinalizationState.generatingKeyPair => FinalizationState.generatingKeyPairCompleted,
        FinalizationState.generatingKeyPairFailed => FinalizationState.generatingKeyPairCompleted,
        FinalizationState.generatingKeyPairCompleted => FinalizationState.generatingKeyPairCompleted,
        FinalizationState.sendingPublicKey => FinalizationState.sendingPublicKeyCompleted,
        FinalizationState.sendingPublicKeyFailed => FinalizationState.sendingPublicKeyCompleted,
        FinalizationState.sendingPublicKeyCompleted => FinalizationState.sendingPublicKeyCompleted,
        FinalizationState.parsingResponse => FinalizationState.parsingResponseCompleted,
        FinalizationState.parsingResponseFailed => FinalizationState.parsingResponseCompleted,
        FinalizationState.parsingResponseCompleted => FinalizationState.parsingResponseCompleted,
        FinalizationState.completed => FinalizationState.completed,
      };

  FinalizationState get next => switch (this) {
        FinalizationState.notStarted => FinalizationState.generatingKeyPair,
        FinalizationState.generatingKeyPair => FinalizationState.sendingPublicKey,
        FinalizationState.generatingKeyPairFailed => FinalizationState.generatingKeyPair,
        FinalizationState.generatingKeyPairCompleted => FinalizationState.sendingPublicKey,
        FinalizationState.sendingPublicKey => FinalizationState.parsingResponse,
        FinalizationState.sendingPublicKeyFailed => FinalizationState.sendingPublicKey,
        FinalizationState.sendingPublicKeyCompleted => FinalizationState.parsingResponse,
        FinalizationState.parsingResponse => FinalizationState.completed,
        FinalizationState.parsingResponseFailed => FinalizationState.parsingResponse,
        FinalizationState.parsingResponseCompleted => FinalizationState.completed,
        FinalizationState.completed => FinalizationState.completed,
      };

  bool get isFailed => switch (this) {
        FinalizationState.notStarted => false,
        FinalizationState.generatingKeyPair => false,
        FinalizationState.generatingKeyPairFailed => true,
        FinalizationState.generatingKeyPairCompleted => false,
        FinalizationState.sendingPublicKey => false,
        FinalizationState.sendingPublicKeyFailed => true,
        FinalizationState.sendingPublicKeyCompleted => false,
        FinalizationState.parsingResponse => false,
        FinalizationState.parsingResponseFailed => true,
        FinalizationState.parsingResponseCompleted => false,
        FinalizationState.completed => false,
      };

  String get rolloutMsg => rolloutMsgLocalized(AppLocalizationsEn());
  String rolloutMsgLocalized(AppLocalizations localizations) => switch (this) {
        FinalizationState.notStarted => localizations.rolloutStateNotStarted,
        FinalizationState.generatingKeyPair => localizations.rolloutStateGeneratingKeyPair,
        FinalizationState.generatingKeyPairFailed => localizations.rolloutStateGeneratingKeyPairFailed,
        FinalizationState.generatingKeyPairCompleted => localizations.rolloutStateGeneratingKeyPairCompleted,
        FinalizationState.sendingPublicKey => localizations.rolloutStateSendingPublicKey,
        FinalizationState.sendingPublicKeyFailed => localizations.rolloutStateSendingPublicKeyFailed,
        FinalizationState.sendingPublicKeyCompleted => localizations.rolloutStateSendingPublicKeyCompleted,
        FinalizationState.parsingResponse => localizations.rolloutStateParsingResponse,
        FinalizationState.parsingResponseFailed => localizations.rolloutStateParsingResponseFailed,
        FinalizationState.parsingResponseCompleted => localizations.rolloutStateParsingResponseCompleted,
        FinalizationState.completed => localizations.rolloutStateCompleted,
      };
}
