import 'package:json_annotation/json_annotation.dart';

import '../enums/introduction_enum.dart';

part 'introductions_state.g.dart';

@JsonSerializable()
class IntroductionsState {
  Set<Introduction> completedIntroductions;
  IntroductionsState({this.completedIntroductions = const {}});

  factory IntroductionsState.fromJson(Map<String, dynamic> json) => _$IntroductionsStateFromJson(json);
  Map<String, dynamic> toJson() => _$IntroductionsStateToJson(this);

  IntroductionsState withCompletedIntroduction(Introduction introduction) {
    final newCompletedIntroductions = {...completedIntroductions};
    newCompletedIntroductions.add(introduction);
    return IntroductionsState(completedIntroductions: newCompletedIntroductions);
  }

  IntroductionsState withoutCompletedIntroduction(Introduction introduction) {
    final newCompletedIntroductions = {...completedIntroductions};
    newCompletedIntroductions.remove(introduction);
    return IntroductionsState(completedIntroductions: newCompletedIntroductions);
  }
}
