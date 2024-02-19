import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/states/introduction_state.dart';

void main() {
  group('IntroductionState', () {
    test('withCompletedIntroduction add introduction', () {
      const introductionState = IntroductionState(completedIntroductions: {Introduction.addFolder});
      final updatedState = introductionState.withCompletedIntroduction(Introduction.addTokenManually);
      expect(updatedState.completedIntroductions, {Introduction.addFolder, Introduction.addTokenManually});
    });

    test('withoutCompletedIntroduction remove introduction', () {
      const introductionState = IntroductionState(completedIntroductions: {Introduction.addFolder, Introduction.addTokenManually});
      final updatedState = introductionState.withoutCompletedIntroduction(Introduction.addTokenManually);
      expect(updatedState.completedIntroductions, {Introduction.addFolder});
    });

    test('withoutCompletedIntroduction add duplicate introduction', () {
      const introductionState = IntroductionState(completedIntroductions: {Introduction.addFolder, Introduction.addTokenManually});
      final updatedState = introductionState.withCompletedIntroduction(Introduction.addTokenManually);
      expect(updatedState.completedIntroductions, {Introduction.addFolder, Introduction.addTokenManually});
    });
  });
}
