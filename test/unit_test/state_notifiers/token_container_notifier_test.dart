import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_container_processor.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _testTokenContainerNotifier();
}

TokenContainerState _getBaseState() => TokenContainerState(
      container: [
        TokenContainerUnfinalized(
          issuer: 'issuer',
          nonce: 'nonce',
          timestamp: DateTime.now(),
          serverUrl: Uri.parse('https://example.com'),
          serial: 'serial',
          ecKeyAlgorithm: EcKeyAlgorithm.secp521r1,
          hashAlgorithm: Algorithms.SHA512,
          sslVerify: true,
        ),
      ],
    );

void _testTokenContainerNotifier() {
  group('Token Container Notifier Test', () {
    test('load state from repo on creation', () async {
      final container = ProviderContainer();
      var repoState = _getBaseState();
      final mockRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockRepo.loadContainerState()).thenAnswer((_) => Future.value(repoState));
      when(mockRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = repoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(repoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(repoState.containerList)..[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      final state = await container.read(tokenContainerProvider.future);
      verify(mockRepo.loadContainerState()).called(1);
      expect(state, repoState);
    });
    // container.read(tokenContainerProvider.notifier).addContainer;
    // container.read(tokenContainerProvider.notifier).addContainerList;
    // container.read(tokenContainerProvider.notifier).updateContainer;
    // container.read(tokenContainerProvider.notifier).updateContainerList;
    // container.read(tokenContainerProvider.notifier).deleteContainer;
    // container.read(tokenContainerProvider.notifier).deleteContainerList;
    // container.read(tokenContainerProvider.notifier).handleProcessorResult;
    // container.read(tokenContainerProvider.notifier).handleProcessorResults;
    // container.read(tokenContainerProvider.notifier).finalizeContainer;
    // container.read(tokenContainerProvider.notifier).syncTokens;
    // container.read(tokenContainerProvider.notifier).getTransferQrData;

    test('addContainer', () async {
      // prepare
      final container = ProviderContainer();
      var repoState = _getBaseState();
      final mockRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockRepo.loadContainerState()).thenAnswer((_) => Future.value(repoState));
      when(mockRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = repoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(repoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(repoState.containerList)..[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      // act
      await container.read(tokenContainerProvider.future);
      await container.read(tokenContainerProvider.notifier).addContainer(
            TokenContainerUnfinalized(
              issuer: 'issuer2',
              nonce: 'nonce2',
              timestamp: DateTime.now().add(const Duration(days: 1)),
              serverUrl: Uri.parse('https://example.com'),
              serial: 'serial2',
              ecKeyAlgorithm: EcKeyAlgorithm.secp112r1,
              hashAlgorithm: Algorithms.SHA256,
              sslVerify: true,
            ),
          );

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockRepo.loadContainerState()).called(1);
      verify(mockRepo.saveContainer(any)).called(greaterThanOrEqualTo(2));
      expect(state.containerList.length, equals(2));
      expect(state.containerList.where((e) => e.nonce == 'nonce').length, equals(1));
      expect(state.containerList.where((e) => e.nonce == 'nonce2').length, equals(1));
      expect(state, repoState);
    });
    test('addContainerList', () async {
      // prepare
      final container = ProviderContainer();
      var repoState = _getBaseState();
      final mockRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockRepo.loadContainerState()).thenAnswer((_) => Future.value(repoState));
      when(mockRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = repoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(repoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(repoState.containerList)..[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      when(mockRepo.saveContainerState(any)).thenAnswer((invocation) {
        repoState = invocation.positionalArguments[0] as TokenContainerState;
        return Future.value(repoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      await container.read(tokenContainerProvider.notifier).addContainerList([
        TokenContainerUnfinalized(
          issuer: 'issuer2',
          nonce: 'nonce2',
          timestamp: DateTime.now().add(const Duration(days: 1)),
          serverUrl: Uri.parse('https://example.com'),
          serial: 'serial2',
          ecKeyAlgorithm: EcKeyAlgorithm.secp112r1,
          hashAlgorithm: Algorithms.SHA256,
          sslVerify: true,
        ),
        TokenContainerUnfinalized(
          issuer: 'issuer3',
          nonce: 'nonce3',
          timestamp: DateTime.now().add(const Duration(days: 2)),
          serverUrl: Uri.parse('https://example.com'),
          serial: 'serial3',
          ecKeyAlgorithm: EcKeyAlgorithm.secp112r1,
          hashAlgorithm: Algorithms.SHA256,
          sslVerify: true,
        ),
      ]);

      final state = await container.read(tokenContainerProvider.future);
      // assert
      verify(mockRepo.loadContainerState()).called(1);
      verify(mockRepo.saveContainerState(any)).called(1);
      expect(state.containerList.length, equals(3));
      expect(state.containerList.where((e) => e.nonce == 'nonce').length, equals(1));
      expect(state.containerList.where((e) => e.nonce == 'nonce2').length, equals(1));
      expect(state.containerList.where((e) => e.nonce == 'nonce3').length, equals(1));
      expect(state, repoState);
    });
    test('updateContainer', () async {
      // prepare
      final container = ProviderContainer();
      var repoState = _getBaseState();
      final mockRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockRepo.loadContainerState()).thenAnswer((_) => Future.value(repoState));
      when(mockRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = repoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(repoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(repoState.containerList)..[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);

      // act
      await container.read(tokenContainerProvider.notifier).updateContainer(
            repoState.containerList.first,
            (c) => c.copyWith(issuer: 'issuer2'),
          );

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockRepo.loadContainerState()).called(1);
      verify(mockRepo.saveContainer(any)).called(2);
      expect(state.containerList.length, equals(1));
      expect(state.containerList.first.issuer, equals('issuer2'));
      expect(state, repoState);
    });
    test('updateContainerList', () async {
      // prepare
      final container = ProviderContainer();
      var repoState = _getBaseState();
      repoState = repoState.copyWith(
        container: [
          repoState.containerList.first,
          TokenContainerUnfinalized(
            issuer: 'issuer2',
            nonce: 'nonce2',
            timestamp: DateTime.now().add(const Duration(days: 1)),
            serverUrl: Uri.parse('https://example.com'),
            serial: 'serial2',
            ecKeyAlgorithm: EcKeyAlgorithm.secp112r1,
            hashAlgorithm: Algorithms.SHA256,
            sslVerify: true,
          ),
        ],
      );
      final mockRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockRepo.loadContainerState()).thenAnswer((_) => Future.value(repoState));
      when(mockRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = repoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(repoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(repoState.containerList)..[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      when(mockRepo.saveContainerList(any)).thenAnswer((invocation) {
        final containers = invocation.positionalArguments[0] as List<TokenContainer>;
        final newList = List<TokenContainer>.from(repoState.containerList);
        for (final container in containers) {
          final i = newList.indexWhere((element) => element.serial == container.serial);
          newList[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      await container.read(tokenContainerProvider.notifier).updateContainerList(
            repoState.containerList,
            (c) => c.copyWith(issuer: 'issuer3'),
          );

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockRepo.loadContainerState()).called(1);
      expect(state.containerList.length, equals(2));
      expect(state.containerList.where((e) => e.issuer == 'issuer').length, equals(0));
      expect(state.containerList.where((e) => e.issuer == 'issuer2').length, equals(0));
      expect(state.containerList.where((e) => e.issuer == 'issuer3').length, equals(2));
      expect(state, repoState);
    });
    test('deleteContainer', () async {
      // prepare
      TestWidgetsFlutterBinding.ensureInitialized();
      final container = ProviderContainer();
      var repoState = _getBaseState();
      final mockRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockRepo.loadContainerState()).thenAnswer((_) => Future.value(repoState));
      when(mockRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = repoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(repoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(repoState.containerList)..[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      when(mockRepo.deleteContainer(any)).thenAnswer((invocation) {
        final serial = invocation.positionalArguments[0] as String;
        final i = repoState.containerList.indexWhere((element) => element.serial == serial);
        if (i == -1) {
          return Future.value(repoState);
        }
        final newList = List<TokenContainer>.from(repoState.containerList)..removeAt(i);
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      await container.read(tokenContainerProvider.notifier).deleteContainer(repoState.containerList.first);

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockRepo.loadContainerState()).called(1);
      expect(state.containerList.length, equals(0));
      expect(state, repoState);
    });
    test('deleteContainerList', () async {
      // prepare
      TestWidgetsFlutterBinding.ensureInitialized();
      final container = ProviderContainer();
      var repoState = _getBaseState();
      repoState = repoState.copyWith(
        container: [
          repoState.containerList.first,
          TokenContainerUnfinalized(
            issuer: 'issuer2',
            nonce: 'nonce2',
            timestamp: DateTime.now().add(const Duration(days: 1)),
            serverUrl: Uri.parse('https://example.com'),
            serial: 'serial2',
            ecKeyAlgorithm: EcKeyAlgorithm.secp112r1,
            hashAlgorithm: Algorithms.SHA256,
            sslVerify: true,
          ),
          TokenContainerUnfinalized(
            issuer: 'issuer3',
            nonce: 'nonce3',
            timestamp: DateTime.now().add(const Duration(days: 2)),
            serverUrl: Uri.parse('https://example.com'),
            serial: 'serial3',
            ecKeyAlgorithm: EcKeyAlgorithm.secp112r1,
            hashAlgorithm: Algorithms.SHA256,
            sslVerify: true,
          ),
        ],
      );
      final mockRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockRepo.loadContainerState()).thenAnswer((_) => Future.value(repoState));
      when(mockRepo.saveContainerState(any)).thenAnswer((invocation) {
        repoState = invocation.positionalArguments[0] as TokenContainerState;
        return Future.value(repoState);
      });
      when(mockRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = repoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(repoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(repoState.containerList)..[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act                                                                                    serial                  serial3
      await container.read(tokenContainerProvider.notifier).deleteContainerList([repoState.containerList[0], repoState.containerList[2]]);

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockRepo.loadContainerState()).called(1);
      expect(state.containerList.length, equals(1));
      expect(state.containerList.where((e) => e.serial == 'serial').length, equals(0));
      expect(state.containerList.where((e) => e.serial == 'serial2').length, equals(1));
      expect(state.containerList.where((e) => e.serial == 'serial3').length, equals(0));
      expect(state, repoState);
    });
    test('handleProcessorResult', () async {
      // prepare
      TestWidgetsFlutterBinding.ensureInitialized();
      final container = ProviderContainer();
      var repoState = _getBaseState();
      final mockRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockRepo.loadContainerState()).thenAnswer((_) => Future.value(repoState));
      when(mockRepo.saveContainerState(any)).thenAnswer((invocation) {
        repoState = invocation.positionalArguments[0] as TokenContainerState;
        return Future.value(repoState);
      });
      when(mockRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = repoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(repoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(repoState.containerList)..[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);

      final Uri uri = Uri.parse(
        'pia://container/SMPH00067A2F?'
        'issuer=privacyIDEA&'
        'ttl=10&'
        'nonce=dbd2ab5aa9b539484fc3b78cd4bb08375d3eb30e&'
        'time=2024-11-14T09%3A30%3A18.288530%2B00%3A00&'
        'url=http://192.168.2.118:5000/&'
        'serial=SMPH00067A2F&'
        'key_algorithm=secp384r1&'
        'hash_algorithm=SHA256&'
        'ssl_verify=True&'
        'passphrase=',
      );
      // act
      final processorResults = await TokenContainerProcessor().processUri(uri);
      expect(processorResults, isNotNull);
      expect(processorResults!.length, 1);
      final result = processorResults.first;
      await container.read(tokenContainerProvider.notifier).handleProcessorResult(result, {});

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockRepo.loadContainerState()).called(1);
      expect(state, repoState);
    });
    test('handleProcessorResults', () async {
      // prepare
      final container = ProviderContainer();
      var repoState = _getBaseState();
      final mockRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockRepo.loadContainerState()).thenAnswer((_) => Future.value(repoState));
      when(mockRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = repoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(repoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(repoState.containerList)..[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      // TODO: implement test

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockRepo.loadContainerState()).called(1);
      expect(state, repoState);
    });
    test('finalizeContainer', () async {
      // prepare
      final container = ProviderContainer();
      var repoState = _getBaseState();
      final mockRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockRepo.loadContainerState()).thenAnswer((_) => Future.value(repoState));
      when(mockRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = repoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(repoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(repoState.containerList)..[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      // TODO: implement test

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockRepo.loadContainerState()).called(1);
      expect(state, repoState);
    });
    test('syncTokens', () async {
      // prepare
      final container = ProviderContainer();
      var repoState = _getBaseState();
      final mockRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockRepo.loadContainerState()).thenAnswer((_) => Future.value(repoState));
      when(mockRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = repoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(repoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(repoState.containerList)..[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      // TODO: implement test

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockRepo.loadContainerState()).called(1);
      expect(state, repoState);
    });
    test('getTransferQrData', () async {
      // prepare
      final container = ProviderContainer();
      var repoState = _getBaseState();
      final mockRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockRepo.loadContainerState()).thenAnswer((_) => Future.value(repoState));
      when(mockRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = repoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(repoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(repoState.containerList)..[i] = container;
        }
        repoState = TokenContainerState(container: newList);
        return Future.value(repoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      // TODO: implement test

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockRepo.loadContainerState()).called(1);
      expect(state, repoState);
    });
  });
}
