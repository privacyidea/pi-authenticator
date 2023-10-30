import 'package:privacyidea_authenticator/model/states/introductions_state.dart';

abstract class IntroductionRepository {
  Future<bool> saveCompletedIntroductions(IntroductionsState introductions);
  Future<IntroductionsState> loadCompletedIntroductions();
}
