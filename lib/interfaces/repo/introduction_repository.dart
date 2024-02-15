import '../../model/states/introduction_state.dart';

abstract class IntroductionRepository {
  Future<bool> saveCompletedIntroductions(IntroductionState introductions);
  Future<IntroductionState> loadCompletedIntroductions();
}
