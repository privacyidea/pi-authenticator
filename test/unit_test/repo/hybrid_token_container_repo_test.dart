
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/interfaces/repo/container_repository.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/repo/token_container_state_repositorys/hybrid_token_container_state_repository.dart';

class MockTokenContainerStateRepository implements TokenContainerStateRepository {
  TokenContainerState savedState;
  bool _doesThrow = false;
  MockTokenContainerStateRepository({TokenContainerState? initialState}) : savedState = initialState ?? TokenContainerState.uninitialized([]);

  void setThrow(bool value) {
    _doesThrow = value;
  }

  @override
  Future<TokenContainerState> loadContainerState() {
    if (_doesThrow) throw Exception('Test exception');
    return Future.value(savedState);
  }

  @override
  Future<TokenContainerState> saveContainerState(TokenContainerState containerState) {
    if (_doesThrow) throw Exception('Test exception');
    savedState = containerState;
    return Future.value(savedState);
  }

}

void main() {
  _testHybridTokenContainerStateRepository();
}

void _testHybridTokenContainerStateRepository() {
  group('HybridTokenContainerStateRepository test', () {
    test('HybridTokenContainerStateRepository test', () async {
      final token = TOTPToken(
        period: 30,
        id: 'TOTP_1',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'SECRET',
        issuer: 'issuer',
      );
      TokenContainerState? remoteState = TokenContainerStateSynced(
        serial: 'containerSerial',
        description: 'description',
        type: 'type',
        syncedTokenTemplates: [TokenTemplate(data: token.toUriMap())],
      );
      TokenContainerState? localState = TokenContainerStateModified(
        lastModifiedAt: DateTime.now(),
        lastSyncedAt: DateTime.now().subtract(const Duration(days: 1)),
        serial: 'containerSerial',
        description: 'description',
        type: 'type',
        syncedTokenTemplates: [],
        localTokenTemplates: [TokenTemplate(data: token.toUriMap())],
      );

      final localRepo = MockTokenContainerStateRepository(initialState: localState);
      final remoteRepo = MockTokenContainerStateRepository(initialState: remoteState);

      final hybridRepo = HybridTokenContainerStateRepository(
        localRepository: localRepo,
        remoteRepository: remoteRepo,
      );
      final dateTimeBefore = DateTime.now();
      final state = await hybridRepo.loadContainerState();
      await Future.delayed(const Duration(milliseconds: 1));
      final dateTimeAfter = DateTime.now();
      expect(state, isA<TokenContainerStateSynced>());
      state as TokenContainerStateSynced;
      expect(state.lastSyncedAt?.isAfter(dateTimeBefore), isTrue);
      expect(state.lastSyncedAt?.isBefore(dateTimeAfter), isTrue);
      expect(state.syncedTokenTemplates.length, 1);
      final template = state.syncedTokenTemplates.first;
      expect(template.data, token.toUriMap(), reason: 'Should be the remote state if both are changed since last sync');
    });
  });
}
