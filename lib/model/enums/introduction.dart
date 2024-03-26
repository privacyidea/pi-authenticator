import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/riverpod_providers.dart';
import '../states/introduction_state.dart';

// Do not rename or remove JsonValue values, they are used for serialization. Only add new values.
enum Introduction {
  @JsonValue('introductionScreen')
  introductionScreen, // 1st start
  @JsonValue('scanQrCode')
  scanQrCode, // 1st start && introductionScreen
  @JsonValue('addManually')
  addTokenManually, // 1st start && scanQrCode
  @JsonValue('tokenSwipe')
  tokenSwipe, // 1st token
  @JsonValue('editToken')
  editToken, // 1st token && tokenSwipe
  @JsonValue('lockToken')
  lockToken, // 1st token && editToken
  @JsonValue('dragToken')
  dragToken, // 2nd token && tokenSwipe
  @JsonValue('addFolder')
  addFolder, // 3 tokens && 0 groups
  @JsonValue('pollForChallenges')
  pollForChallenges, // 1st push token && lockToken
  @JsonValue('hidePushTokens')
  hidePushTokens, // hiding is enabled
}

extension IntroductionX on Introduction {
  bool isConditionFulfilled(WidgetRef ref, IntroductionState state) => switch (this) {
        Introduction.introductionScreen => state.isUncompleted(Introduction.introductionScreen),
        Introduction.scanQrCode => state.isUncompleted(Introduction.scanQrCode),
        Introduction.addTokenManually => state.isCompleted(Introduction.scanQrCode) && state.isUncompleted(Introduction.addTokenManually),
        Introduction.tokenSwipe =>
          ref.watch(tokenProvider).tokens.isNotEmpty && state.isCompleted(Introduction.addTokenManually) && state.isUncompleted(Introduction.tokenSwipe),
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
      };

  String hintText(BuildContext context) => switch (this) {
        Introduction.introductionScreen => '',
        Introduction.scanQrCode => AppLocalizations.of(context)!.introScanQrCode,
        Introduction.addTokenManually => AppLocalizations.of(context)!.introAddTokenManually,
        Introduction.tokenSwipe => AppLocalizations.of(context)!.introTokenSwipe,
        Introduction.editToken => AppLocalizations.of(context)!.introEditToken,
        Introduction.lockToken => AppLocalizations.of(context)!.introLockToken,
        Introduction.dragToken => AppLocalizations.of(context)!.introDragToken,
        Introduction.addFolder => AppLocalizations.of(context)!.introAddFolder,
        Introduction.pollForChallenges => AppLocalizations.of(context)!.introPollForChallenges,
        Introduction.hidePushTokens => AppLocalizations.of(context)!.introHidePushTokens,
      };
}
