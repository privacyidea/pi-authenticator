import 'package:json_annotation/json_annotation.dart';
import 'settings_state.dart';
import 'token_folder_state.dart';
import 'token_state.dart';

import '../enums/introduction_enum.dart';

part 'introduction_state.g.dart';

@JsonSerializable()
class IntroductionState {
  final Set<Introduction> completedIntroductions;
  Set<Introduction> get uncompletedIntroductions => Introduction.values.toSet().difference(completedIntroductions);

  bool isCompleted(Introduction introduction) => completedIntroductions.contains(introduction);
  bool isUncompleted(Introduction introduction) => !isCompleted(introduction);

  const IntroductionState({this.completedIntroductions = const {}});

  factory IntroductionState.fromJson(Map<String, dynamic> json) => _$IntroductionStateFromJson(json);
  Map<String, dynamic> toJson() => _$IntroductionStateToJson(this);

  IntroductionState withCompletedIntroduction(Introduction introduction) {
    final newCompletedIntroductions = {...completedIntroductions};
    newCompletedIntroductions.add(introduction);
    return IntroductionState(completedIntroductions: newCompletedIntroductions);
  }

  IntroductionState withoutCompletedIntroduction(Introduction introduction) {
    final newCompletedIntroductions = {...completedIntroductions};
    newCompletedIntroductions.remove(introduction);
    return IntroductionState(completedIntroductions: newCompletedIntroductions);
  }

  bool isIntroductionScreenConditionFulfilled() => isUncompleted(Introduction.introductionScreen);
  bool isScanQrCodeConditionFulfilled() => isCompleted(Introduction.introductionScreen) && isUncompleted(Introduction.scanQrCode);
  bool isAddTokenManuallyConditionFulfilled() => isCompleted(Introduction.scanQrCode) && isUncompleted(Introduction.addTokenManually);
  bool isTokenSwipeConditionFulfilled({required bool stateHasToken}) => stateHasToken && isUncompleted(Introduction.tokenSwipe);
  bool isEditTokenConditionFulfilled(TokenState tokenState) =>
      isCompleted(Introduction.tokenSwipe) && tokenState.tokens.isNotEmpty && isUncompleted(Introduction.editToken);
  bool isLockTokenConditionFulfilled(TokenState tokenState) =>
      isCompleted(Introduction.editToken) && tokenState.tokens.isNotEmpty && isUncompleted(Introduction.lockToken);
  bool isGroupTokensConditionFulfilled(TokenState tokenState, TokenFolderState tokenFolderState) =>
      tokenState.tokens.length >= 3 && tokenFolderState.folders.isEmpty && isUncompleted(Introduction.groupTokens);
  bool isPollForChangesConditionFulfilled(TokenState tokenState) =>
      tokenState.hasPushTokens && isCompleted(Introduction.lockToken) && isUncompleted(Introduction.pollForChanges);
  bool isHidePushTokenConditionFulfilled(TokenState tokenState, SettingsState settingsState) =>
      settingsState.hidePushTokens && isCompleted(Introduction.pollForChanges) && isUncompleted(Introduction.hidePushToken);
}
