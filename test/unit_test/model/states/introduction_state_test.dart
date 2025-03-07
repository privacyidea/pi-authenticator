import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';

void main() {
  group('IntroductionState', () {
    test('withCompletedIntroduction add introduction', () {
      const introductionState = IntroductionState(completedIntroductions: {Introduction.addFolder});
      final updatedState = introductionState.withCompletedIntroduction(Introduction.addManually);
      expect(updatedState.completedIntroductions, {Introduction.addFolder, Introduction.addManually});
    });

    test('withoutCompletedIntroduction remove introduction', () {
      const introductionState = IntroductionState(completedIntroductions: {Introduction.addFolder, Introduction.addManually});
      final updatedState = introductionState.withoutCompletedIntroduction(Introduction.addManually);
      expect(updatedState.completedIntroductions, {Introduction.addFolder});
    });

    test('withoutCompletedIntroduction add duplicate introduction', () {
      const introductionState = IntroductionState(completedIntroductions: {Introduction.addFolder, Introduction.addManually});
      final updatedState = introductionState.withCompletedIntroduction(Introduction.addManually);
      expect(updatedState.completedIntroductions, {Introduction.addFolder, Introduction.addManually});
    });
  });
}
