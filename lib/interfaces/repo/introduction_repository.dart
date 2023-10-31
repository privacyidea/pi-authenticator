import '../../model/states/Introductions_state.dart';

abstract class IntroductionRepository {
  Future<bool> saveCompletedIntroductions(IntroductionsState introductions);
  Future<IntroductionsState> loadCompletedIntroductions();
}
