import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/push_token_rollout_state_extension.dart';

void main() {
  _testPushTokenRolloutstateExtension();
}

void _testPushTokenRolloutstateExtension() {
  group('Push-Token Rolloutstate Extension', () {
    test('rollOutInProgress', () {
      expect(PushTokenRollOutState.rolloutNotStarted.rollOutInProgress, false);
      expect(PushTokenRollOutState.generatingRSAKeyPair.rollOutInProgress, true);
      expect(PushTokenRollOutState.generatingRSAKeyPairFailed.rollOutInProgress, false);
      expect(PushTokenRollOutState.sendRSAPublicKey.rollOutInProgress, true);
      expect(PushTokenRollOutState.sendRSAPublicKeyFailed.rollOutInProgress, false);
      expect(PushTokenRollOutState.parsingResponse.rollOutInProgress, true);
      expect(PushTokenRollOutState.parsingResponseFailed.rollOutInProgress, false);
      expect(PushTokenRollOutState.rolloutComplete.rollOutInProgress, false);
    });
    test('getFailed', () {
      expect(PushTokenRollOutState.rolloutNotStarted.getFailed(), PushTokenRollOutState.rolloutNotStarted);
      expect(PushTokenRollOutState.generatingRSAKeyPair.getFailed(), PushTokenRollOutState.generatingRSAKeyPairFailed);
      expect(PushTokenRollOutState.generatingRSAKeyPairFailed.getFailed(), PushTokenRollOutState.generatingRSAKeyPairFailed);
      expect(PushTokenRollOutState.sendRSAPublicKey.getFailed(), PushTokenRollOutState.sendRSAPublicKeyFailed);
      expect(PushTokenRollOutState.sendRSAPublicKeyFailed.getFailed(), PushTokenRollOutState.sendRSAPublicKeyFailed);
      expect(PushTokenRollOutState.parsingResponse.getFailed(), PushTokenRollOutState.parsingResponseFailed);
      expect(PushTokenRollOutState.parsingResponseFailed.getFailed(), PushTokenRollOutState.parsingResponseFailed);
      expect(PushTokenRollOutState.rolloutComplete.getFailed(), PushTokenRollOutState.rolloutComplete);
    });
  });
}
