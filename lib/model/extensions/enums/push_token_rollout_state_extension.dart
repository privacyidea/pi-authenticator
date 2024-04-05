import '../../../l10n/app_localizations.dart';
import '../../enums/push_token_rollout_state.dart';

extension PushTokenRollOutStateX on PushTokenRollOutState {
  bool get rollOutInProgress => switch (this) {
        PushTokenRollOutState.rolloutNotStarted => false,
        PushTokenRollOutState.generatingRSAKeyPair => true,
        PushTokenRollOutState.generatingRSAKeyPairFailed => false,
        PushTokenRollOutState.sendRSAPublicKey => true,
        PushTokenRollOutState.sendRSAPublicKeyFailed => false,
        PushTokenRollOutState.parsingResponse => true,
        PushTokenRollOutState.parsingResponseFailed => false,
        PushTokenRollOutState.rolloutComplete => false,
      };
  String rolloutMsg(AppLocalizations localizations) => switch (this) {
        PushTokenRollOutState.rolloutNotStarted => localizations.rollingOut,
        PushTokenRollOutState.generatingRSAKeyPair => localizations.generatingRSAKeyPair,
        PushTokenRollOutState.generatingRSAKeyPairFailed => localizations.generatingRSAKeyPairFailed,
        PushTokenRollOutState.sendRSAPublicKey => localizations.sendingRSAPublicKey,
        PushTokenRollOutState.sendRSAPublicKeyFailed => localizations.sendingRSAPublicKeyFailed,
        PushTokenRollOutState.parsingResponse => localizations.parsingResponse,
        PushTokenRollOutState.parsingResponseFailed => localizations.parsingResponseFailed,
        PushTokenRollOutState.rolloutComplete => localizations.rolloutCompleted,
      };
}
