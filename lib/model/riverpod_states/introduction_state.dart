import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/introduction.dart';
import '../extensions/enums/introduction_extension.dart';

part 'introduction_state.freezed.dart';
part 'introduction_state.g.dart';

@Freezed()
sealed class IntroductionState with _$IntroductionState {
  // Remove the explicit declaration of the property here.
  // It is automatically handled by the factory constructor.

  const IntroductionState._();
  Set<Introduction> get uncompletedIntroductions => Introduction.values.toSet().difference(completedIntroductions);

  const factory IntroductionState({@Default({}) Set<Introduction> completedIntroductions}) = _IntroductionState;

  static IntroductionState withAllCompleted() => IntroductionState(completedIntroductions: Introduction.values.toSet());

  bool isCompleted(Introduction introduction) => completedIntroductions.contains(introduction);
  bool isUncompleted(Introduction introduction) => !isCompleted(introduction);
  bool isConditionFulfilled(WidgetRef ref, Introduction introduction) => introduction.isConditionFulfilled(ref, this);

  IntroductionState withCompletedIntroduction(Introduction introduction) {
    final newCompletedIntroductions = {...completedIntroductions};
    newCompletedIntroductions.add(introduction);
    return IntroductionState(completedIntroductions: newCompletedIntroductions);
  }

  IntroductionState withCompletedIntroductions(List<Introduction> values) {
    final newCompletedIntroductions = {...completedIntroductions};
    newCompletedIntroductions.addAll(values);
    return IntroductionState(completedIntroductions: newCompletedIntroductions);
  }

  IntroductionState withoutCompletedIntroduction(Introduction introduction) {
    final newCompletedIntroductions = {...completedIntroductions};
    newCompletedIntroductions.remove(introduction);
    return IntroductionState(completedIntroductions: newCompletedIntroductions);
  }

  IntroductionState withoutCompletedIntroductions(List<Introduction> values) {
    final newCompletedIntroductions = {...completedIntroductions};
    newCompletedIntroductions.removeAll(values);
    return IntroductionState(completedIntroductions: newCompletedIntroductions);
  }

  factory IntroductionState.fromJson(Map<String, dynamic> json) => _$IntroductionStateFromJson(json);
}
