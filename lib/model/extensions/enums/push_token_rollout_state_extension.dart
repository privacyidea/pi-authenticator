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
import '../../../l10n/app_localizations.dart';
import '../../enums/push_token_rollout_state.dart';

extension PushTokenRollOutStateX on PushTokenRollOutState {
  bool get rollOutInProgress => switch (this) {
        PushTokenRollOutState.rolloutNotStarted => false,
        PushTokenRollOutState.generatingRSAKeyPair => true,
        PushTokenRollOutState.generatingRSAKeyPairFailed => false,
        PushTokenRollOutState.receivingFirebaseToken => true,
        PushTokenRollOutState.receivingFirebaseTokenFailed => false,
        PushTokenRollOutState.sendRSAPublicKey => true,
        PushTokenRollOutState.sendRSAPublicKeyFailed => false,
        PushTokenRollOutState.parsingResponse => true,
        PushTokenRollOutState.parsingResponseFailed => false,
        PushTokenRollOutState.rolloutComplete => false,
      };

  bool get rolloutFailed => switch (this) {
        PushTokenRollOutState.generatingRSAKeyPairFailed => true,
        PushTokenRollOutState.receivingFirebaseTokenFailed => true,
        PushTokenRollOutState.sendRSAPublicKeyFailed => true,
        PushTokenRollOutState.parsingResponseFailed => true,
        _ => false,
      };

  PushTokenRollOutState getFailed() => switch (this) {
        PushTokenRollOutState.rolloutNotStarted => PushTokenRollOutState.rolloutNotStarted,
        PushTokenRollOutState.generatingRSAKeyPair => PushTokenRollOutState.generatingRSAKeyPairFailed,
        PushTokenRollOutState.generatingRSAKeyPairFailed => PushTokenRollOutState.generatingRSAKeyPairFailed,
        PushTokenRollOutState.receivingFirebaseToken => PushTokenRollOutState.receivingFirebaseTokenFailed,
        PushTokenRollOutState.receivingFirebaseTokenFailed => PushTokenRollOutState.receivingFirebaseTokenFailed,
        PushTokenRollOutState.sendRSAPublicKey => PushTokenRollOutState.sendRSAPublicKeyFailed,
        PushTokenRollOutState.sendRSAPublicKeyFailed => PushTokenRollOutState.sendRSAPublicKeyFailed,
        PushTokenRollOutState.parsingResponse => PushTokenRollOutState.parsingResponseFailed,
        PushTokenRollOutState.parsingResponseFailed => PushTokenRollOutState.parsingResponseFailed,
        PushTokenRollOutState.rolloutComplete => PushTokenRollOutState.rolloutComplete,
      };

  String rolloutMsg(AppLocalizations localizations) => switch (this) {
        PushTokenRollOutState.rolloutNotStarted => localizations.rolloutStateNotStarted,
        PushTokenRollOutState.generatingRSAKeyPair => localizations.rolloutStateGeneratingKeyPair,
        PushTokenRollOutState.generatingRSAKeyPairFailed => localizations.rolloutStateGeneratingKeyPairFailed,
        PushTokenRollOutState.receivingFirebaseToken => 'localizations.rolloutStateReceivingFirebaseToken',
        PushTokenRollOutState.receivingFirebaseTokenFailed => 'localizations.rolloutStateReceivingFirebaseTokenFailed',
        PushTokenRollOutState.sendRSAPublicKey => localizations.rolloutStateSendingPublicKey,
        PushTokenRollOutState.sendRSAPublicKeyFailed => localizations.rolloutStateSendingPublicKeyFailed,
        PushTokenRollOutState.parsingResponse => localizations.rolloutStateParsingResponse,
        PushTokenRollOutState.parsingResponseFailed => localizations.rolloutStateParsingResponseFailed,
        PushTokenRollOutState.rolloutComplete => localizations.rolloutStateCompleted,
      };
}
