/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
