import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/rollout_state.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/rollout_state_extension.dart';

void main() {
  group('FinalizationState extension', () {
    test('rolloutStarted is false only for notStarted', () {
      expect(FinalizationState.notStarted.rolloutStarted, isFalse);
      for (final state in FinalizationState.values) {
        if (state != FinalizationState.notStarted) {
          expect(state.rolloutStarted, isTrue, reason: '$state');
        }
      }
    });

    test('rollOutInProgress is true only for active states', () {
      final inProgressStates = {
        FinalizationState.generatingKeyPair,
        FinalizationState.sendingPublicKey,
        FinalizationState.parsingResponse,
      };
      for (final state in FinalizationState.values) {
        expect(
          state.rollOutInProgress,
          inProgressStates.contains(state),
          reason: '$state',
        );
      }
    });

    test('isFailed is true only for failed states', () {
      final failedStates = {
        FinalizationState.generatingKeyPairFailed,
        FinalizationState.sendingPublicKeyFailed,
        FinalizationState.parsingResponseFailed,
      };
      for (final state in FinalizationState.values) {
        expect(state.isFailed, failedStates.contains(state), reason: '$state');
      }
    });

    test('asFailed returns correct failed state', () {
      expect(
        FinalizationState.generatingKeyPair.asFailed,
        FinalizationState.generatingKeyPairFailed,
      );
      expect(
        FinalizationState.sendingPublicKey.asFailed,
        FinalizationState.sendingPublicKeyFailed,
      );
      expect(
        FinalizationState.parsingResponse.asFailed,
        FinalizationState.parsingResponseFailed,
      );
      expect(FinalizationState.completed.asFailed, FinalizationState.completed);
    });

    test('asCompleted returns correct completed state', () {
      expect(
        FinalizationState.generatingKeyPair.asCompleted,
        FinalizationState.generatingKeyPairCompleted,
      );
      expect(
        FinalizationState.sendingPublicKey.asCompleted,
        FinalizationState.sendingPublicKeyCompleted,
      );
      expect(
        FinalizationState.parsingResponse.asCompleted,
        FinalizationState.parsingResponseCompleted,
      );
    });

    test('next returns correct next state', () {
      expect(
        FinalizationState.notStarted.next,
        FinalizationState.generatingKeyPair,
      );
      expect(
        FinalizationState.generatingKeyPair.next,
        FinalizationState.sendingPublicKey,
      );
      expect(
        FinalizationState.generatingKeyPairCompleted.next,
        FinalizationState.sendingPublicKey,
      );
      expect(
        FinalizationState.sendingPublicKey.next,
        FinalizationState.parsingResponse,
      );
      expect(
        FinalizationState.parsingResponse.next,
        FinalizationState.completed,
      );
      expect(FinalizationState.completed.next, FinalizationState.completed);
    });

    test('failed states retry via next', () {
      expect(
        FinalizationState.generatingKeyPairFailed.next,
        FinalizationState.generatingKeyPair,
      );
      expect(
        FinalizationState.sendingPublicKeyFailed.next,
        FinalizationState.sendingPublicKey,
      );
      expect(
        FinalizationState.parsingResponseFailed.next,
        FinalizationState.parsingResponse,
      );
    });

    test('rolloutMsg returns non-empty string for all states', () {
      for (final state in FinalizationState.values) {
        expect(state.rolloutMsg.isNotEmpty, isTrue, reason: '$state');
      }
    });
  });
}
