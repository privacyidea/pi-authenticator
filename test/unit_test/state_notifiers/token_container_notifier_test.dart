import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/api/interfaces/container_api.dart';
import 'package:privacyidea_authenticator/model/container_policies.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/enums/rollout_state.dart';
import 'package:privacyidea_authenticator/model/enums/sync_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_container_processor.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _testTokenContainerNotifier();
}

TokenContainerState _buildUnfinalizedContainerState() => TokenContainerState(
      containerList: [
        TokenContainerUnfinalized(
          issuer: 'issuer',
          ttl: Duration(minutes: 10),
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

TokenContainerState _buildFinalizedContainerState() => TokenContainerState(
      containerList: [
        TokenContainerFinalized(
          serverName: 'privacyIDEA',
          issuer: 'privacyIDEA',
          nonce: 'dbd2ab5aa9b539484fc3b78cd4bb08375d3eb30e',
          timestamp: DateTime.parse("2024-11-14 09:30:18.288530Z"),
          serverUrl: Uri.parse("http://example.com"),
          serial: "CONTAINER01",
          ecKeyAlgorithm: EcKeyAlgorithm.secp384r1,
          hashAlgorithm: Algorithms.SHA256,
          sslVerify: false,
          publicServerKey: 'publicServerKey',
          publicClientKey: 'publicClientKey',
          privateClientKey: 'privateClientKey',
          finalizationState: RolloutState.completed,
          syncState: SyncState.notStarted,
          passphraseQuestion: null,
          policies: ContainerPolicies(
            rolloverAllowed: false,
            initialTokenTransfer: false,
            tokensDeletable: false,
            unregisterAllowed: false,
          ),
        ),
      ],
    );

void _testTokenContainerNotifier() {
  group('Token Container Notifier Test', () {
    test('load state from repo on creation', () async {
      final container = ProviderContainer();
      var containerRepoState = _buildUnfinalizedContainerState();
      final mockContainerRepo = _setupMockContainerRepo(() => containerRepoState, (state) => containerRepoState = state);
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockContainerRepo.loadContainerState()).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      final state = await container.read(tokenContainerProvider.future);
      verify(mockContainerRepo.loadContainerState()).called(1);
      expect(state, containerRepoState);
    });

    test('addContainer', () async {
      // prepare
      final container = ProviderContainer();
      var containerRepoState = _buildUnfinalizedContainerState();
      final mockContainerRepo = _setupMockContainerRepo(() => containerRepoState, (state) => containerRepoState = state);
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockContainerRepo.loadContainerState()).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      // act
      await container.read(tokenContainerProvider.future);
      await container.read(tokenContainerProvider.notifier).addContainer(
            TokenContainerUnfinalized(
              issuer: 'issuer2',
              ttl: Duration(minutes: 10),
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
      verify(mockContainerRepo.loadContainerState()).called(1);
      verify(mockContainerRepo.saveContainer(any)).called(greaterThanOrEqualTo(2));
      expect(state.containerList.length, equals(2));
      expect(state.containerList.where((e) => e.nonce == 'nonce').length, equals(1));
      expect(state.containerList.where((e) => e.nonce == 'nonce2').length, equals(1));
      expect(state, containerRepoState);
    });
    test('addContainerList', () async {
      // prepare
      final container = ProviderContainer();
      var containerRepoState = _buildUnfinalizedContainerState();
      final mockContainerRepo = _setupMockContainerRepo(() => containerRepoState, (state) => containerRepoState = state);
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockContainerRepo.loadContainerState()).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.saveContainerState(any)).thenAnswer((invocation) {
        containerRepoState = invocation.positionalArguments[0] as TokenContainerState;
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      await container.read(tokenContainerProvider.notifier).addContainerList([
        TokenContainerUnfinalized(
          issuer: 'issuer2',
          ttl: Duration(minutes: 10),
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
          ttl: Duration(minutes: 10),
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
      verify(mockContainerRepo.loadContainerState()).called(1);
      verify(mockContainerRepo.saveContainerState(any)).called(1);
      expect(state.containerList.length, equals(3));
      expect(state.containerList.where((e) => e.nonce == 'nonce').length, equals(1));
      expect(state.containerList.where((e) => e.nonce == 'nonce2').length, equals(1));
      expect(state.containerList.where((e) => e.nonce == 'nonce3').length, equals(1));
      expect(state, containerRepoState);
    });
    test('updateContainer', () async {
      // prepare
      final container = ProviderContainer();
      var containerRepoState = _buildUnfinalizedContainerState();
      final mockContainerRepo = _setupMockContainerRepo(() => containerRepoState, (state) => containerRepoState = state);
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockContainerRepo.loadContainerState()).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);

      // act
      await container.read(tokenContainerProvider.notifier).updateContainer(
            containerRepoState.containerList.first,
            (TokenContainer c) => c.copyWith(issuer: 'issuer2'),
          );

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockContainerRepo.loadContainerState()).called(1);
      verify(mockContainerRepo.saveContainer(any)).called(2);
      expect(state.containerList.length, equals(1));
      expect(state.containerList.first.issuer, equals('issuer2'));
      expect(state, containerRepoState);
    });
    test('updateContainerList', () async {
      // prepare
      final container = ProviderContainer();
      var containerRepoState = _buildUnfinalizedContainerState();
      containerRepoState = containerRepoState.copyWith(
        containerList: [
          containerRepoState.containerList.first,
          TokenContainerUnfinalized(
            issuer: 'issuer2',
            ttl: Duration(minutes: 10),
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
      final mockContainerRepo = _setupMockContainerRepo(() => containerRepoState, (state) => containerRepoState = state);
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockContainerRepo.loadContainerState()).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.saveContainerList(any)).thenAnswer((invocation) {
        final containers = invocation.positionalArguments[0] as List<TokenContainer>;
        final newList = List<TokenContainer>.from(containerRepoState.containerList);
        for (final container in containers) {
          final i = newList.indexWhere((element) => element.serial == container.serial);
          newList[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      await container.read(tokenContainerProvider.notifier).updateContainerList(
            containerRepoState.containerList,
            (c) => c.copyWith(issuer: 'issuer3'),
          );

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockContainerRepo.loadContainerState()).called(1);
      expect(state.containerList.length, equals(2));
      expect(state.containerList.where((e) => e.issuer == 'issuer').length, equals(0));
      expect(state.containerList.where((e) => e.issuer == 'issuer2').length, equals(0));
      expect(state.containerList.where((e) => e.issuer == 'issuer3').length, equals(2));
      expect(state, containerRepoState);
    });
    test('deleteContainer', () async {
      // prepare
      TestWidgetsFlutterBinding.ensureInitialized();
      final container = ProviderContainer();
      var containerRepoState = _buildUnfinalizedContainerState();
      final mockContainerRepo = _setupMockContainerRepo(() => containerRepoState, (state) => containerRepoState = state);
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockContainerRepo.loadContainerState()).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.deleteContainer(any)).thenAnswer((invocation) {
        final serial = invocation.positionalArguments[0] as String;
        final i = containerRepoState.containerList.indexWhere((element) => element.serial == serial);
        if (i == -1) {
          return Future.value(containerRepoState);
        }
        final newList = List<TokenContainer>.from(containerRepoState.containerList)..removeAt(i);
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      await container.read(tokenContainerProvider.notifier).deleteContainer(containerRepoState.containerList.first);

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockContainerRepo.loadContainerState()).called(1);
      expect(state.containerList.length, equals(0));
      expect(state, containerRepoState);
    });
    test('deleteContainerList', () async {
      // prepare
      TestWidgetsFlutterBinding.ensureInitialized();
      final container = ProviderContainer();
      var containerRepoState = _buildUnfinalizedContainerState();
      containerRepoState = containerRepoState.copyWith(
        containerList: [
          containerRepoState.containerList.first,
          TokenContainerUnfinalized(
            issuer: 'issuer2',
            ttl: Duration(minutes: 10),
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
            ttl: Duration(minutes: 10),
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
      final mockContainerRepo = _setupMockContainerRepo(() => containerRepoState, (state) => containerRepoState = state);
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer((_) async => Response('{}', 404));
      when(mockContainerRepo.loadContainerState()).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainerState(any)).thenAnswer((invocation) {
        containerRepoState = invocation.positionalArguments[0] as TokenContainerState;
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act                                                                                    serial                  serial3
      await container.read(tokenContainerProvider.notifier).deleteContainerList([containerRepoState.containerList[0], containerRepoState.containerList[2]]);

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockContainerRepo.loadContainerState()).called(1);
      expect(state.containerList.length, equals(1));
      expect(state.containerList.where((e) => e.serial == 'serial').length, equals(0));
      expect(state.containerList.where((e) => e.serial == 'serial2').length, equals(1));
      expect(state.containerList.where((e) => e.serial == 'serial3').length, equals(0));
      expect(state, containerRepoState);
    });
    test('handleProcessorResult', () async {
      // prepare
      TestWidgetsFlutterBinding.ensureInitialized();
      var containerRepoState = TokenContainerState(containerList: []);
      final mockContainerRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer(
        (_) async {
          final json = {
            "id": 1,
            "jsonrpc": "2.0",
            "result": {
              "status": true,
              "value": {
                "policies": {
                  "client_container_unregister": true,
                  "client_token_deletable": true,
                  "container_client_rollover": true,
                  "container_initial_token_transfer": true
                },
                "public_server_key": "-----BEGIN PUBLIC KEY-----\n"
                    "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEaik84am1122p15/8Z6FYW+q5DYe22RV0\n"
                    "6jimjkz/5J6vDkafcP1oq5fRgIEXTTU6uKarvSrOxcV8nNuW6o80L55iT1ZmZJ+q\n"
                    "tx/ncmaloOEFY4dMh1XNs0TayAxKrCNg\n"
                    "-----END PUBLIC KEY-----",
              }
            },
            "time": 1731941387.8622696,
            "version": "privacyIDEA 3.10",
            "versionnumber": "3.10",
            "signature":
                "rsa_sha256_pss:5d71b5a47b9330cdb26f090b8197fdf76df34919636cc54acf476185e1282beba9a8a800dbcfd834e0068a7d3f653e2193c9b0d2c80b44801d4f85d18c0a7af554d1d9659600a5570106a595687c5131b20a4793e0992dd11c138990c47e959aa391845010f4c85dbeb35aded5a57e85d20f544d79e35b06c3231323e50c2699af6758aeeb6aafb3c9e507c7c2c0d23230e5ec09b7c26b535cd43f51368b3edc1cf4148125f8b92263c7a52eaa0def49db1a6347edc12aa9151ede67a5ab114a72b860ebdd7d9c8b48851e981fa8582a4865389bc14eea26143d36b891278be097bf841bf75697cdb16ce1bba15dcb9ffe9d4717b6f8e8780040fe078f55f7d0"
          };
          return Response(
            jsonEncode(json),
            200,
          );
        },
      );
      when(mockContainerRepo.loadContainerState()).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainerState(any)).thenAnswer((invocation) {
        containerRepoState = invocation.positionalArguments[0] as TokenContainerState;
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });

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

      final mockTokenContainerProvider = TokenContainerNotifier(
        repoOverride: mockContainerRepo,
        containerApiOverride: mockContainerApi,
        eccUtilsOverride: EccUtils(),
      );
      final mockTokenRepo = MockTokenRepository();
      when(mockTokenRepo.loadTokens()).thenAnswer((_) => Future.value([]));
      when(mockTokenRepo.saveOrReplaceTokens(any)).thenAnswer((_) => Future.value([]));
      final mockTokenNotifier = TokenNotifier(
        repoOverride: mockTokenRepo,
      );
      final providerContainer = ProviderContainer(
        overrides: [
          tokenContainerProvider.overrideWith(() => mockTokenContainerProvider),
          tokenProvider.overrideWith(() => mockTokenNotifier),
        ],
      );

      // act
      await providerContainer.read(tokenContainerProvider.future);
      final processorResults = await TokenContainerProcessor().processUri(uri);
      expect(processorResults, isNotNull);
      expect(processorResults!.length, 1);
      final result = processorResults.first;
      await providerContainer.read(tokenContainerProvider.notifier).handleProcessorResult(result, {
        TokenContainerProcessor.ARG_DO_REPLACE: true,
        TokenContainerProcessor.ARG_ADD_DEVICE_INFOS: true,
        TokenContainerProcessor.ARG_INIT_SYNC: false,
      });

      // assert
      final state = await providerContainer.read(tokenContainerProvider.future);
      verify(mockContainerRepo.loadContainerState()).called(1);
      expect(state, containerRepoState);
      final stateContainer = state.containerList.first as TokenContainerFinalized;
      final expectedContainer = TokenContainerFinalized(
        issuer: "privacyIDEA",
        nonce: "dbd2ab5aa9b539484fc3b78cd4bb08375d3eb30e",
        timestamp: DateTime.parse("2024-11-14 09:30:18.288530Z"),
        serverUrl: Uri.parse("http://192.168.2.118:5000/"),
        serial: "SMPH00067A2F",
        ecKeyAlgorithm: EcKeyAlgorithm.secp384r1,
        hashAlgorithm: Algorithms.SHA256,
        finalizationState: RolloutState.completed,
        syncState: SyncState.notStarted,
        passphraseQuestion: "",
        sslVerify: true,
        privateClientKey: "random",
        publicServerKey: "-----BEGIN PUBLIC KEY-----\n"
            "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEaik84am1122p15/8Z6FYW+q5DYe22RV0\n"
            "6jimjkz/5J6vDkafcP1oq5fRgIEXTTU6uKarvSrOxcV8nNuW6o80L55iT1ZmZJ+q\n"
            "tx/ncmaloOEFY4dMh1XNs0TayAxKrCNg\n"
            "-----END PUBLIC KEY-----",
        publicClientKey: "random",
      );
      expect(stateContainer.issuer, expectedContainer.issuer);
      expect(stateContainer.nonce, expectedContainer.nonce);
      expect(stateContainer.timestamp, expectedContainer.timestamp);
      expect(stateContainer.serverUrl, expectedContainer.serverUrl);
      expect(stateContainer.serial, expectedContainer.serial);
      expect(stateContainer.ecKeyAlgorithm, expectedContainer.ecKeyAlgorithm);
      expect(stateContainer.hashAlgorithm, expectedContainer.hashAlgorithm);
      expect(stateContainer.finalizationState, expectedContainer.finalizationState);
      expect(stateContainer.syncState, expectedContainer.syncState);
      expect(stateContainer.passphraseQuestion, expectedContainer.passphraseQuestion);
      expect(stateContainer.sslVerify, expectedContainer.sslVerify);
      expect(stateContainer.privateClientKey, isNotEmpty);
      expect(stateContainer.publicServerKey, expectedContainer.publicServerKey);
      expect(stateContainer.publicClientKey, isNotEmpty);
    });
    test('finalizeContainer', () async {
      // prepare
      TestWidgetsFlutterBinding.ensureInitialized();
      var containerRepoState = _buildUnfinalizedContainerState();
      final mockContainerRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer(
        (_) async {
          final json = {
            "id": 1,
            "jsonrpc": "2.0",
            "result": {
              "status": true,
              "value": {
                "policies": {
                  "client_container_unregister": true,
                  "client_token_deletable": true,
                  "container_client_rollover": true,
                  "container_initial_token_transfer": true
                },
                "public_server_key": "-----BEGIN PUBLIC KEY-----\n"
                    "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEaik84am1122p15/8Z6FYW+q5DYe22RV0\n"
                    "6jimjkz/5J6vDkafcP1oq5fRgIEXTTU6uKarvSrOxcV8nNuW6o80L55iT1ZmZJ+q\n"
                    "tx/ncmaloOEFY4dMh1XNs0TayAxKrCNg\n"
                    "-----END PUBLIC KEY-----",
              }
            },
            "time": 1731941387.8622696,
            "version": "privacyIDEA 3.10",
            "versionnumber": "3.10",
            "signature":
                "rsa_sha256_pss:5d71b5a47b9330cdb26f090b8197fdf76df34919636cc54acf476185e1282beba9a8a800dbcfd834e0068a7d3f653e2193c9b0d2c80b44801d4f85d18c0a7af554d1d9659600a5570106a595687c5131b20a4793e0992dd11c138990c47e959aa391845010f4c85dbeb35aded5a57e85d20f544d79e35b06c3231323e50c2699af6758aeeb6aafb3c9e507c7c2c0d23230e5ec09b7c26b535cd43f51368b3edc1cf4148125f8b92263c7a52eaa0def49db1a6347edc12aa9151ede67a5ab114a72b860ebdd7d9c8b48851e981fa8582a4865389bc14eea26143d36b891278be097bf841bf75697cdb16ce1bba15dcb9ffe9d4717b6f8e8780040fe078f55f7d0"
          };
          return Response(
            jsonEncode(json),
            200,
          );
        },
      );
      when(mockContainerRepo.loadContainerState()).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainerState(any)).thenAnswer((invocation) {
        containerRepoState = invocation.positionalArguments[0] as TokenContainerState;
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere((element) => element.serial == container.serial);
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });

      final mockTokenContainerProvider = TokenContainerNotifier(
        repoOverride: mockContainerRepo,
        containerApiOverride: mockContainerApi,
        eccUtilsOverride: EccUtils(),
      );
      final mockTokenRepo = MockTokenRepository();
      when(mockTokenRepo.loadTokens()).thenAnswer((_) => Future.value([]));
      when(mockTokenRepo.saveOrReplaceTokens(any)).thenAnswer((_) => Future.value([]));
      final mockTokenNotifier = TokenNotifier(
        repoOverride: mockTokenRepo,
      );
      final providerContainer = ProviderContainer(
        overrides: [
          tokenContainerProvider.overrideWith(() => mockTokenContainerProvider),
          tokenProvider.overrideWith(() => mockTokenNotifier),
        ],
      );
      final container = containerRepoState.containerList.first as TokenContainerUnfinalized;
      // act

      await providerContainer.read(tokenContainerProvider.notifier).finalize(containerRepoState.containerList.first, isManually: false);

      // assert
      final state = await providerContainer.read(tokenContainerProvider.future);
      verify(mockContainerRepo.loadContainerState()).called(1);
      expect(state, containerRepoState);
      final stateContainer = state.containerList.first as TokenContainerFinalized;
      final expectedContainer = TokenContainerFinalized(
        issuer: "issuer",
        nonce: "nonce",
        timestamp: container.timestamp,
        serverUrl: Uri.parse("https://example.com"),
        serial: "serial",
        ecKeyAlgorithm: EcKeyAlgorithm.secp521r1,
        hashAlgorithm: Algorithms.SHA512,
        finalizationState: RolloutState.completed,
        syncState: SyncState.notStarted,
        passphraseQuestion: null,
        sslVerify: true,
        privateClientKey: "random",
        publicServerKey: "-----BEGIN PUBLIC KEY-----\n"
            "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEaik84am1122p15/8Z6FYW+q5DYe22RV0\n"
            "6jimjkz/5J6vDkafcP1oq5fRgIEXTTU6uKarvSrOxcV8nNuW6o80L55iT1ZmZJ+q\n"
            "tx/ncmaloOEFY4dMh1XNs0TayAxKrCNg\n"
            "-----END PUBLIC KEY-----",
        publicClientKey: "random",
      );
      verify(mockContainerApi.finalizeContainer(any, any)).called(1);
      expect(stateContainer.issuer, expectedContainer.issuer);
      expect(stateContainer.nonce, expectedContainer.nonce);
      expect(stateContainer.timestamp, expectedContainer.timestamp);
      expect(stateContainer.serverUrl, expectedContainer.serverUrl);
      expect(stateContainer.serial, expectedContainer.serial);
      expect(stateContainer.ecKeyAlgorithm, expectedContainer.ecKeyAlgorithm);
      expect(stateContainer.hashAlgorithm, expectedContainer.hashAlgorithm);
      expect(stateContainer.finalizationState, expectedContainer.finalizationState);
      expect(stateContainer.syncState, expectedContainer.syncState);
      expect(stateContainer.passphraseQuestion, expectedContainer.passphraseQuestion);
      expect(stateContainer.sslVerify, expectedContainer.sslVerify);
      expect(stateContainer.privateClientKey, isNotEmpty);
      expect(stateContainer.publicServerKey, expectedContainer.publicServerKey);
      expect(stateContainer.publicClientKey, isNotEmpty);
    });
    test('sync', () async {
      // prepare
      TestWidgetsFlutterBinding.ensureInitialized();
      var containerRepoState = _buildFinalizedContainerState();
      final containerToSync = containerRepoState.containerList.first as TokenContainerFinalized;
      final mockContainerApi = MockTokenContainerApi();
      final updatedTokens = <Token>[
        HOTPToken(
          id: 'ID01',
          serial: "HOTPTOKEN01",
          containerSerial: "CONTAINER01",
          algorithm: Algorithms.SHA256,
          digits: 6,
          secret: "SECRET01",
          counter: 8,
        ),
        TOTPToken(
          id: "ID03",
          serial: "TOTPTOKEN01",
          period: 30,
          algorithm: Algorithms.SHA256,
          digits: 8,
          secret: "SECRET03",
        ),
      ];
      when(mockContainerApi.sync(any, any)).thenAnswer(
        (v) async => ContainerSyncUpdates(
          containerSerial: 'CONTAINER01',
          updatedTokens: updatedTokens,
          deleteTokenSerials: ["HOTPTOKEN02"],
          newPolicies: ContainerPolicies(
            rolloverAllowed: true,
            initialTokenTransfer: true,
            tokensDeletable: true,
            unregisterAllowed: true,
          ),
        ),
      );

      final mockContainerRepo = _setupMockContainerRepo(() => containerRepoState, (state) => containerRepoState = state);

      final mockTokenContainerProvider = TokenContainerNotifier(
        repoOverride: mockContainerRepo,
        containerApiOverride: mockContainerApi,
        eccUtilsOverride: EccUtils(),
      );
      // prepare - token notifier
      var repoTokens = <String, Token>{
        'ID01': HOTPToken(
          id: 'ID01',
          serial: "HOTPTOKEN01",
          containerSerial: "CONTAINER01",
          algorithm: Algorithms.SHA256,
          digits: 8,
          secret: "SECRET01",
          counter: 10,
        ),
        "ID02": HOTPToken(
          id: "ID02",
          serial: "HOTPTOKEN02",
          containerSerial: null,
          algorithm: Algorithms.SHA256,
          digits: 6,
          secret: "SECRET02",
          counter: 12,
        ),
        "ID04": TOTPToken(
          id: "ID04",
          serial: "TOTPTOKEN02",
          period: 30,
          algorithm: Algorithms.SHA512,
          digits: 6,
          secret: "SECRET04",
        ),
      };
      final mockTokenRepo = MockTokenRepository();
      when(mockTokenRepo.loadTokens()).thenAnswer((_) => Future.value(repoTokens.values.toList()));
      when(mockTokenRepo.saveOrReplaceTokens(any)).thenAnswer((invocation) {
        final tokens = invocation.positionalArguments[0] as List<Token>;
        for (final token in tokens) {
          repoTokens[token.id] = token;
        }
        return Future.value([]);
      });

      final mockTokenNotifier = TokenNotifier(
        repoOverride: mockTokenRepo,
      );

      // prepare - settings notifier
      final MockSettingsRepository mockSettingsRepo = MockSettingsRepository();
      when(mockSettingsRepo.loadSettings()).thenAnswer((_) => Future.value(SettingsState()));
      when(mockSettingsRepo.saveSettings(any)).thenAnswer((invocation) => Future.value(invocation.positionalArguments[0]));
      final SettingsNotifier settingsNotifier = SettingsNotifier(repoOverride: mockSettingsRepo);

      // prepare - provider container
      final providerContainer = ProviderContainer(
        overrides: [
          tokenContainerProvider.overrideWith(() => mockTokenContainerProvider),
          tokenProvider.overrideWith(() => mockTokenNotifier),
          settingsProvider.overrideWith(() => settingsNotifier),
        ],
      );

      // act
      var tokenState = providerContainer.read(tokenProvider);
      await providerContainer.read(tokenContainerProvider.notifier).sync(tokenState: tokenState, isManually: false);

      // assert
      final expectedStateUnordered = TokenState(tokens: [...updatedTokens, repoTokens["ID04"]!]);
      final containerState = await providerContainer.read(tokenContainerProvider.future);
      await Future.delayed(const Duration(milliseconds: 1000)); // wait for the sync to finish
      tokenState = providerContainer.read(tokenProvider);
      verify(mockContainerRepo.loadContainerState()).called(1);
      expect(containerState, containerRepoState);
      final stateContainer = containerState.containerList.first as TokenContainerFinalized;
      final expectedContainer = containerToSync.copyWith(
        policies: ContainerPolicies(
          rolloverAllowed: true,
          initialTokenTransfer: true,
          tokensDeletable: true,
          unregisterAllowed: true,
        ),
      );
      verify(mockContainerApi.sync(any, any)).called(1);
      expect(stateContainer.policies, expectedContainer.policies);
      expect(stateContainer.syncState, SyncState.completed);
      expect(tokenState.tokens.length, 3);
      expect(tokenState.tokens, unorderedEquals(expectedStateUnordered.tokens));
    });
    test('getTransferQrData', () async {
      // prepare
      final providerContainer = ProviderContainer();
      var containerRepoState = _buildFinalizedContainerState();
      final qrDataContainer = containerRepoState.containerList.first as TokenContainerFinalized;
      final mockContainerRepo = _setupMockContainerRepo(() => containerRepoState, (state) => containerRepoState = state);
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.getTransferQrData(any)).thenAnswer((_) async => 'Some Random Data to be transferred');
      final tokenContainerProvider = tokenContainerNotifierProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await providerContainer.read(tokenContainerProvider.future);

      // act
      // TODO: implement test
      final qrData = await providerContainer.read(tokenContainerProvider.notifier).getTransferQrData(qrDataContainer);

      // assert
      verify(mockContainerApi.getTransferQrData(any)).called(1);
      expect(qrData, 'Some Random Data to be transferred');
    });
  });
}

MockTokenContainerRepository _setupMockContainerRepo(
  TokenContainerState Function() stateGetter,
  void Function(TokenContainerState) stateSetter,
) {
  final mockContainerRepo = MockTokenContainerRepository();
  when(mockContainerRepo.loadContainerState()).thenAnswer((_) => Future.value(stateGetter()));
  when(mockContainerRepo.loadContainer(any)).thenAnswer((invocation) {
    final serial = invocation.positionalArguments[0] as String;
    if (stateGetter().containerList.isEmpty) return Future.value(null);
    return Future.value(stateGetter().containerList.firstWhereOrNull((element) => element.serial == serial));
  });
  when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
    final container = invocation.positionalArguments[0] as TokenContainer;
    final i = stateGetter().containerList.indexWhere((element) => element.serial == container.serial);
    final List<TokenContainer> newList;
    if (i == -1) {
      newList = List<TokenContainer>.from(stateGetter().containerList)..add(container);
    } else {
      newList = List<TokenContainer>.from(stateGetter().containerList)..[i] = container;
    }
    stateSetter(TokenContainerState(containerList: newList));
    return Future.value(stateGetter());
  });
  when(mockContainerRepo.saveContainerState(any)).thenAnswer((invocation) {
    stateSetter(invocation.positionalArguments[0] as TokenContainerState);
    return Future.value(stateGetter());
  });
  when(mockContainerRepo.saveContainerList(any)).thenAnswer((invocation) {
    final containers = invocation.positionalArguments[0] as List<TokenContainer>;
    final newList = List<TokenContainer>.from(stateGetter().containerList);
    for (final container in containers) {
      final i = newList.indexWhere((element) => element.serial == container.serial);
      if (i == -1) {
        newList.add(container);
      } else {
        newList[i] = container;
      }
    }
    stateSetter(TokenContainerState(containerList: newList));
    return Future.value(stateGetter());
  });
  when(mockContainerRepo.deleteContainer(any)).thenAnswer((invocation) {
    final serial = invocation.positionalArguments[0] as String;
    final i = stateGetter().containerList.indexWhere((element) => element.serial == serial);
    if (i == -1) {
      return Future.value(stateGetter());
    }
    final newList = List<TokenContainer>.from(stateGetter().containerList)..removeAt(i);
    stateSetter(TokenContainerState(containerList: newList));
    return Future.value(stateGetter());
  });
  when(mockContainerRepo.deleteAllContainer()).thenAnswer((_) {
    stateSetter(TokenContainerState(containerList: []));
    return Future.value(stateGetter());
  });

  when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
    final container = invocation.positionalArguments[0] as TokenContainer;
    final i = stateGetter().containerList.indexWhere((element) => element.serial == container.serial);
    final List<TokenContainer> newList;
    if (i == -1) {
      newList = List<TokenContainer>.from(stateGetter().containerList)..add(container);
    } else {
      newList = List<TokenContainer>.from(stateGetter().containerList)..[i] = container;
    }
    stateSetter(TokenContainerState(containerList: newList));
    return Future.value(stateGetter());
  });
  return mockContainerRepo;
}
