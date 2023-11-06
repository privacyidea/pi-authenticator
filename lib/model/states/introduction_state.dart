import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';

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
  bool isTokenSwipeConditionFulfilled(WidgetRef ref) {
    final stateHasToken = ref.watch(tokenProvider).tokens.isNotEmpty;
    return stateHasToken && isUncompleted(Introduction.tokenSwipe);
  }

  bool isEditTokenConditionFulfilled() => isCompleted(Introduction.tokenSwipe) && isUncompleted(Introduction.editToken);
  bool isLockTokenConditionFulfilled() => isCompleted(Introduction.editToken) && isUncompleted(Introduction.lockToken);
  bool isAddFolderConditionFulfilled(WidgetRef ref) {
    final hasThreeTokens = ref.watch(tokenProvider).tokens.length >= 3;
    return hasThreeTokens && isUncompleted(Introduction.addFolder);
  }

  bool isPollForChangesConditionFulfilled(WidgetRef ref) {
    final hasPushToken = ref.watch(tokenProvider).pushTokens.isNotEmpty;
    return hasPushToken && isCompleted(Introduction.tokenSwipe) && isUncompleted(Introduction.pollForChanges) && isAddFolderConditionFulfilled(ref) == false;
  }

  bool isHidePushTokenConditionFulfilled(WidgetRef ref) {
    final hidePushTokens = ref.watch(settingsProvider).hidePushTokens;
    return hidePushTokens && isCompleted(Introduction.pollForChanges) && isUncompleted(Introduction.hidePushTokens);
  }
}
