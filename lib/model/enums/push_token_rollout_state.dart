import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

enum PushTokenRollOutState {
  rolloutNotStarted,
  generatingRSAKeyPair,
  generatingRSAKeyPairFailed,
  sendRSAPublicKey,
  sendRSAPublicKeyFailed,
  parsingResponse,
  parsingResponseFailed,
  rolloutComplete,
}

extension PushTokenRollOutStateExtension on PushTokenRollOutState {
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
  String rolloutMsg(BuildContext context) => switch (this) {
        PushTokenRollOutState.rolloutNotStarted => AppLocalizations.of(context)!.rollingOut,
        PushTokenRollOutState.generatingRSAKeyPair => AppLocalizations.of(context)!.generatingRSAKeyPair,
        PushTokenRollOutState.generatingRSAKeyPairFailed => AppLocalizations.of(context)!.generatingRSAKeyPairFailed,
        PushTokenRollOutState.sendRSAPublicKey => AppLocalizations.of(context)!.sendingRSAPublicKey,
        PushTokenRollOutState.sendRSAPublicKeyFailed => AppLocalizations.of(context)!.sendingRSAPublicKeyFailed,
        PushTokenRollOutState.parsingResponse => AppLocalizations.of(context)!.parsingResponse,
        PushTokenRollOutState.parsingResponseFailed => AppLocalizations.of(context)!.parsingResponseFailed,
        PushTokenRollOutState.rolloutComplete => AppLocalizations.of(context)!.rolloutCompleted,
      };
}
