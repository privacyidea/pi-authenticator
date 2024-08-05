import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/introduction.dart';
import '../extensions/enums/introduction_extension.dart';

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

  IntroductionState withAllCompleted() => IntroductionState(completedIntroductions: Introduction.values.toSet());

  bool isConditionFulfilled(WidgetRef ref, Introduction introduction) => introduction.isConditionFulfilled(ref, this);

  @override
  String toString() => 'IntroductionState{completedIntroductions: $completedIntroductions}';
}
