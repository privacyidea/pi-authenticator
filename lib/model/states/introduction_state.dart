import 'package:json_annotation/json_annotation.dart';

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
  bool isEditTokenConditionFulfilled({required bool editTokenVisible}) =>
      isCompleted(Introduction.tokenSwipe) && editTokenVisible && isUncompleted(Introduction.editToken);
  bool isLockTokenConditionFulfilled({required bool lockTokenVisible}) =>
      isCompleted(Introduction.editToken) && lockTokenVisible && isUncompleted(Introduction.lockToken);
  bool isAddFolderConditionFulfilled({required bool hasThreeTokens}) => hasThreeTokens && isUncompleted(Introduction.addFolder);
  bool isPollForChangesConditionFulfilled({required bool hasPushToken}) =>
      hasPushToken && isCompleted(Introduction.tokenSwipe) && isUncompleted(Introduction.pollForChanges);
  bool isHidePushTokenConditionFulfilled({required bool hidePushTokens}) =>
      hidePushTokens && isCompleted(Introduction.pollForChanges) && isUncompleted(Introduction.hidePushTokens);
}
