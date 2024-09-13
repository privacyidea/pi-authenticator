// import 'package:flutter_test/flutter_test.dart';
// import 'package:privacyidea_authenticator/api/token_container_api_endpoint.dart';
// import 'package:privacyidea_authenticator/interfaces/repo/container_repository.dart';
// import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
// import 'package:privacyidea_authenticator/model/token_template.dart';
// import 'package:privacyidea_authenticator/model/tokens/container_credentials.dart';
// import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
// import 'package:privacyidea_authenticator/repo/token_container_state_repositorys/hybrid_token_container_state_repository.dart';
// import 'package:privacyidea_authenticator/repo/token_container_state_repositorys/remote_token_container_state_repository.dart';

// class MockTokenContainerRepository implements TokenContainerRepository {
//   TokenContainer savedState;
//   bool _doesThrow = false;
//   MockTokenContainerRepository({TokenContainer? initialState}) : savedState = initialState ?? const TokenContainer.uninitialized();

//   void setThrow(bool value) {
//     _doesThrow = value;
//   }

//   @override
//   Future<TokenContainer> loadContainerState() {
//     if (_doesThrow) throw Exception('Test exception');
//     return Future.value(savedState);
//   }

//   @override
//   Future<TokenContainer> saveContainerState(TokenContainer containerState) {
//     if (_doesThrow) throw Exception('Test exception');
//     savedState = containerState;
//     return Future.value(savedState);
//   }
// }

// class MockTokenContainerApiEndpoint implements PrivacyideaContainerApi {
//   TokenContainer state;
//   MockTokenContainerApiEndpoint({required TokenContainer initialState}) : state = initialState;

//   @override
//   Future<TokenContainer> fetch() {
//     return Future.value(state);
//   }

//   @override
//   Future<TokenContainer> sync(TokenContainer containerState) {
//     state = containerState.copyTransformInto<TokenContainerSynced>(lastSyncAt: DateTime.now());
//     return Future.value(state);
//   }

//   @override
//   ContainerCredential get credential => throw UnimplementedError();
// }

// void main() {
//   _testHybridTokenContainerRepository();
// }

// void _testHybridTokenContainerRepository() {
//   group('HybridTokenContainerRepository test', () {
//     test('HybridTokenContainerRepository test', () async {
//       final token = TOTPToken(
//         period: 30,
//         id: 'TOTP_1',
//         algorithm: Algorithms.SHA1,
//         digits: 6,
//         secret: 'SECRET',
//         issuer: 'issuer',
//       );
//       TokenContainer? remoteState = TokenContainer.synced(
//         serial: 'containerSerial',
//         description: 'description',
//         syncedTokenTemplates: [token.toTemplate()],
//         lastSyncAt: DateTime.now(),
//         localTokenTemplates: [],
//       );
//       TokenContainer? localState = TokenContainer.modified(
//         lastModifiedAt: DateTime.now(),
//         lastSyncAt: DateTime.now().subtract(const Duration(days: 1)),
//         serial: 'containerSerial',
//         description: 'description',
//         syncedTokenTemplates: [],
//         localTokenTemplates: [token.toTemplate()],
//       );

//       final localRepo = MockTokenContainerRepository(initialState: localState);
//       final remoteRepo = RemoteTokenContainerRepository(apiEndpoint: MockTokenContainerApiEndpoint(initialState: remoteState));

//       final hybridRepo = HybridTokenContainerRepository(
//         localRepository: localRepo,
//         remoteRepository: remoteRepo,
//       );
//       final dateTimeBefore = DateTime.now();
//       final state = await hybridRepo.loadContainerState();
//       await Future.delayed(const Duration(milliseconds: 1));
//       final dateTimeAfter = DateTime.now();
//       expect(state, isA<TokenContainerSynced>());
//       state as TokenContainerSynced;
//       expect(state.lastSyncAt.isAfter(dateTimeBefore), isTrue);
//       expect(state.lastSyncAt.isBefore(dateTimeAfter), isTrue);
//       expect(state.syncedTokenTemplates.length, 1);
//       final template = state.syncedTokenTemplates.first;
//       expect(template.data, token.toOtpAuthMap(), reason: 'Should be the remote state if both are changed since last sync');
//     });
//   });
// }
