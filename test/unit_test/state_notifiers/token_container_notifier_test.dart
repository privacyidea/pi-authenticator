import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show Response;
import 'package:logger/logger.dart' as printer;
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/api/impl/privacy_idea_container_api.dart';
import 'package:privacyidea_authenticator/api/interfaces/container_api.dart';
import 'package:privacyidea_authenticator/interfaces/repo/settings_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_container_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_value.dart';
import 'package:privacyidea_authenticator/model/container_policies.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/enums/rollout_state.dart';
import 'package:privacyidea_authenticator/model/enums/sync_state.dart';
import 'package:privacyidea_authenticator/model/exception_errors/error_codes.dart';
import 'package:privacyidea_authenticator/model/exception_errors/pi_server_result_error.dart';
import 'package:privacyidea_authenticator/model/exception_errors/response_error.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/rollout_state_extension.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_container_processor.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/dialogs/delete_container_dialogs.dart/delete_container_dialog.dart';

import '../../tests_app_wrapper.dart';
import '../../tests_app_wrapper.mocks.dart';

void main() {
  TokenContainerState buildUnfinalizedContainerState() => TokenContainerState(
    containerList: [
      TokenContainerUnfinalized(
        issuer: 'issuer',
        ttl: Duration(minutes: 10),
        nonce: 'nonce',
        // Keep this in the future so `build()`'s unawaited finalize doesn't
        // delete the container as expired before the test's assertions run.
        timestamp: DateTime.now(),
        serverUrl: Uri.parse('https://example.com'),
        serial: 'serial',
        ecKeyAlgorithm: EcKeyAlgorithm.secp521r1,
        hashAlgorithm: Algorithms.SHA512,
        sslVerify: true,
      ),
    ],
  );

  TokenContainerState buildFinalizedContainerState() => TokenContainerState(
    containerList: [
      TokenContainerFinalized(
        issuer: 'privacyIDEA',
        nonce: 'dbd2ab5aa9b539484fc3b78cd4bb08375d3eb30e',
        timestamp: DateTime.parse("2024-11-14 09:30:18.288530Z"),
        serverUrl: Uri.parse("http://example.com"),
        serial: "CONTAINER01",
        ecKeyAlgorithm: EcKeyAlgorithm.secp384r1,
        hashAlgorithm: Algorithms.SHA256,
        sslVerify: false,
        publicClientKey: 'publicClientKey',
        privateClientKey: 'privateClientKey',
        policies: ContainerPolicies(
          rolloverAllowed: false,
          initialTokenAssignment: false,
          disabledTokenDeletion: true,
          disabledUnregister: true,
        ),
      ),
    ],
  );

  MockTokenContainerRepository setupMockContainerRepo(
    TokenContainerState Function() stateGetter,
    void Function(TokenContainerState) stateSetter,
  ) {
    final mockContainerRepo = MockTokenContainerRepository();
    when(
      mockContainerRepo.loadContainerState(),
    ).thenAnswer((_) => Future.value(stateGetter()));
    when(mockContainerRepo.loadContainer(any)).thenAnswer((invocation) {
      final serial = invocation.positionalArguments[0] as String;
      if (stateGetter().containerList.isEmpty) return Future.value();
      return Future.value(
        stateGetter().containerList.firstWhereOrNull(
          (element) => element.serial == serial,
        ),
      );
    });
    when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
      final container = invocation.positionalArguments[0] as TokenContainer;
      final i = stateGetter().containerList.indexWhere(
        (element) => element.serial == container.serial,
      );
      final List<TokenContainer> newList;
      if (i == -1) {
        newList = List<TokenContainer>.from(stateGetter().containerList)
          ..add(container);
      } else {
        newList = List<TokenContainer>.from(stateGetter().containerList)
          ..[i] = container;
      }
      stateSetter(TokenContainerState(containerList: newList));
      return Future.value(stateGetter());
    });
    when(mockContainerRepo.saveContainerState(any)).thenAnswer((invocation) {
      stateSetter(invocation.positionalArguments[0] as TokenContainerState);
      return Future.value(stateGetter());
    });
    when(mockContainerRepo.saveContainerList(any)).thenAnswer((invocation) {
      final containers =
          invocation.positionalArguments[0] as List<TokenContainer>;
      final newList = List<TokenContainer>.from(stateGetter().containerList);
      for (final container in containers) {
        final i = newList.indexWhere(
          (element) => element.serial == container.serial,
        );
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
      final i = stateGetter().containerList.indexWhere(
        (element) => element.serial == serial,
      );
      if (i == -1) {
        return Future.value(stateGetter());
      }
      final newList = List<TokenContainer>.from(stateGetter().containerList)
        ..removeAt(i);
      stateSetter(TokenContainerState(containerList: newList));
      return Future.value(stateGetter());
    });
    when(mockContainerRepo.deleteAllContainer()).thenAnswer((_) {
      stateSetter(TokenContainerState(containerList: []));
      return Future.value(stateGetter());
    });
    return mockContainerRepo;
  }

  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    provideDummy<TokenContainerState>(TokenContainerState(containerList: []));
  });
  final ContainerFinalizationResponse containerFinalizationResponseExample =
      ContainerFinalizationResponse(
        policies: ContainerPolicies(
          rolloverAllowed: false,
          initialTokenAssignment: false,
          disabledTokenDeletion: true,
          disabledUnregister: true,
        ),
      );
  group('Token Container Notifier Test', () {
    test('load state from repo on creation', () async {
      final container = ProviderContainer();
      var containerRepoState = buildUnfinalizedContainerState();
      final mockContainerRepo = setupMockContainerRepo(
        () => containerRepoState,
        (state) => containerRepoState = state,
      );
      final mockContainerApi = MockTokenContainerApi();
      when(
        mockContainerApi.finalizeContainer(any, any),
      ).thenAnswer((_) async => containerFinalizationResponseExample);
      when(
        mockContainerRepo.loadContainerState(),
      ).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere(
          (element) => element.serial == container.serial,
        );
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerProviderOf(
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
      var containerRepoState = buildUnfinalizedContainerState();
      final mockContainerRepo = setupMockContainerRepo(
        () => containerRepoState,
        (state) => containerRepoState = state,
      );
      final mockContainerApi = MockTokenContainerApi();
      when(
        mockContainerApi.finalizeContainer(any, any),
      ).thenAnswer((_) async => containerFinalizationResponseExample);
      when(
        mockContainerRepo.loadContainerState(),
      ).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere(
          (element) => element.serial == container.serial,
        );
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      // act
      await container.read(tokenContainerProvider.future);
      await container
          .read(tokenContainerProvider.notifier)
          .addContainer(
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
      verify(
        mockContainerRepo.saveContainer(any),
      ).called(greaterThanOrEqualTo(1));
      expect(state.containerList.length, equals(2));
      expect(
        state.containerList.where((e) => e.nonce == 'nonce').length,
        equals(1),
      );
      expect(
        state.containerList.where((e) => e.nonce == 'nonce2').length,
        equals(1),
      );
      expect(state, containerRepoState);
    });
    test('addContainerList', () async {
      // prepare
      final container = ProviderContainer();
      var containerRepoState = buildUnfinalizedContainerState();
      final mockContainerRepo = setupMockContainerRepo(
        () => containerRepoState,
        (state) => containerRepoState = state,
      );
      final mockContainerApi = MockTokenContainerApi();
      when(
        mockContainerApi.finalizeContainer(any, any),
      ).thenAnswer((_) async => containerFinalizationResponseExample);
      when(
        mockContainerRepo.loadContainerState(),
      ).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere(
          (element) => element.serial == container.serial,
        );
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.saveContainerState(any)).thenAnswer((invocation) {
        containerRepoState =
            invocation.positionalArguments[0] as TokenContainerState;
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerProviderOf(
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
      expect(
        state.containerList.where((e) => e.nonce == 'nonce').length,
        equals(1),
      );
      expect(
        state.containerList.where((e) => e.nonce == 'nonce2').length,
        equals(1),
      );
      expect(
        state.containerList.where((e) => e.nonce == 'nonce3').length,
        equals(1),
      );
      expect(state, containerRepoState);
    });
    test('updateContainer', () async {
      // prepare
      final container = ProviderContainer();
      var containerRepoState = buildUnfinalizedContainerState();
      final mockContainerRepo = setupMockContainerRepo(
        () => containerRepoState,
        (state) => containerRepoState = state,
      );
      final mockContainerApi = MockTokenContainerApi();
      when(
        mockContainerApi.finalizeContainer(any, any),
      ).thenAnswer((_) async => containerFinalizationResponseExample);
      when(
        mockContainerRepo.loadContainerState(),
      ).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere(
          (element) => element.serial == container.serial,
        );
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);

      // act
      await container
          .read(tokenContainerProvider.notifier)
          .updateContainer(
            containerRepoState.containerList.first,
            (TokenContainer c) => c.copyWith(issuer: 'issuer2'),
          );

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockContainerRepo.loadContainerState()).called(1);
      verify(mockContainerRepo.saveContainer(any)).called(1);
      expect(state.containerList.length, equals(1));
      expect(state.containerList.first.issuer, equals('issuer2'));
      expect(state, containerRepoState);
    });
    test('updateContainerList', () async {
      // prepare
      final container = ProviderContainer();
      var containerRepoState = buildUnfinalizedContainerState();
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
      final mockContainerRepo = setupMockContainerRepo(
        () => containerRepoState,
        (state) => containerRepoState = state,
      );
      final mockContainerApi = MockTokenContainerApi();
      when(
        mockContainerApi.finalizeContainer(any, any),
      ).thenAnswer((_) async => containerFinalizationResponseExample);
      when(
        mockContainerRepo.loadContainerState(),
      ).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere(
          (element) => element.serial == container.serial,
        );
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.saveContainerList(any)).thenAnswer((invocation) {
        final containers =
            invocation.positionalArguments[0] as List<TokenContainer>;
        final newList = List<TokenContainer>.from(
          containerRepoState.containerList,
        );
        for (final container in containers) {
          final i = newList.indexWhere(
            (element) => element.serial == container.serial,
          );
          newList[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      await container
          .read(tokenContainerProvider.notifier)
          .updateContainerList(
            containerRepoState.containerList,
            (c) => c.copyWith(issuer: 'issuer3'),
          );

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockContainerRepo.loadContainerState()).called(1);
      expect(state.containerList.length, equals(2));
      expect(
        state.containerList.where((e) => e.issuer == 'issuer').length,
        equals(0),
      );
      expect(
        state.containerList.where((e) => e.issuer == 'issuer2').length,
        equals(0),
      );
      expect(
        state.containerList.where((e) => e.issuer == 'issuer3').length,
        equals(2),
      );
      expect(state, containerRepoState);
    });
    test('deleteContainer', () async {
      // prepare
      TestWidgetsFlutterBinding.ensureInitialized();
      final container = ProviderContainer();
      var containerRepoState = buildUnfinalizedContainerState();
      final mockContainerRepo = setupMockContainerRepo(
        () => containerRepoState,
        (state) => containerRepoState = state,
      );
      final mockContainerApi = MockTokenContainerApi();
      when(
        mockContainerApi.finalizeContainer(any, any),
      ).thenAnswer((_) async => containerFinalizationResponseExample);
      when(
        mockContainerRepo.loadContainerState(),
      ).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere(
          (element) => element.serial == container.serial,
        );
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.deleteContainer(any)).thenAnswer((invocation) {
        final serial = invocation.positionalArguments[0] as String;
        final i = containerRepoState.containerList.indexWhere(
          (element) => element.serial == serial,
        );
        if (i == -1) {
          return Future.value(containerRepoState);
        }
        final newList = List<TokenContainer>.from(
          containerRepoState.containerList,
        )..removeAt(i);
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      await container
          .read(tokenContainerProvider.notifier)
          .deleteContainer(containerRepoState.containerList.first);

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
      var containerRepoState = buildUnfinalizedContainerState();
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
      final mockContainerRepo = setupMockContainerRepo(
        () => containerRepoState,
        (state) => containerRepoState = state,
      );
      final mockContainerApi = MockTokenContainerApi();
      when(
        mockContainerApi.finalizeContainer(any, any),
      ).thenAnswer((_) async => containerFinalizationResponseExample);
      when(
        mockContainerRepo.loadContainerState(),
      ).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainerState(any)).thenAnswer((invocation) {
        containerRepoState =
            invocation.positionalArguments[0] as TokenContainerState;
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere(
          (element) => element.serial == container.serial,
        );
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      final tokenContainerProvider = tokenContainerProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await container.read(tokenContainerProvider.future);
      // act
      await container.read(tokenContainerProvider.notifier).deleteContainerList(
        [
          containerRepoState.containerList[0],
          containerRepoState.containerList[2],
        ],
      );

      // assert
      final state = await container.read(tokenContainerProvider.future);
      verify(mockContainerRepo.loadContainerState()).called(1);
      expect(state.containerList.length, equals(1));
      expect(
        state.containerList.where((e) => e.serial == 'serial').length,
        equals(0),
      );
      expect(
        state.containerList.where((e) => e.serial == 'serial2').length,
        equals(1),
      );
      expect(
        state.containerList.where((e) => e.serial == 'serial3').length,
        equals(0),
      );
      expect(state, containerRepoState);
    });
    test('handleProcessorResult', () async {
      // prepare
      TestWidgetsFlutterBinding.ensureInitialized();
      var containerRepoState = TokenContainerState(containerList: []);
      final mockContainerRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer(
        (_) async => ContainerFinalizationResponse(
          policies: ContainerPolicies(
            initialTokenAssignment: true,
            rolloverAllowed: true,
            disabledTokenDeletion: false,
            disabledUnregister: false,
          ),
        ),
      );
      when(
        mockContainerRepo.loadContainerState(),
      ).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainerState(any)).thenAnswer((invocation) {
        containerRepoState =
            invocation.positionalArguments[0] as TokenContainerState;
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere(
          (element) => element.serial == container.serial,
        );
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..[i] = container;
        }
        containerRepoState = TokenContainerState(containerList: newList);
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.deleteContainer(any)).thenAnswer((invocation) {
        return Future.value(containerRepoState);
      });

      final timeStamp = DateTime.now();
      final Uri uri = Uri.parse(
        'pia://container/SMPH00067A2F?'
        'issuer=privacyIDEA&'
        'ttl=10&'
        'nonce=dbd2ab5aa9b539484fc3b78cd4bb08375d3eb30e&'
        'time=$timeStamp&'
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
      when(
        mockTokenRepo.saveOrReplaceTokens(any),
      ).thenAnswer((_) => Future.value([]));
      final mockTokenNotifier = TokenNotifier(repoOverride: mockTokenRepo);
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
      await providerContainer
          .read(tokenContainerProvider.notifier)
          .handleProcessorResult(
            result,
            args: {
              TokenContainerProcessor.ARG_DO_REPLACE: true,
              TokenContainerProcessor.ARG_ADD_DEVICE_INFOS: true,
              TokenContainerProcessor.ARG_INIT_SYNC: false,
              TokenContainerProcessor.ARG_URL_IS_OK: true,
            },
          );

      // assert
      final state = await providerContainer.read(tokenContainerProvider.future);
      verify(mockContainerRepo.loadContainerState()).called(1);
      expect(state, containerRepoState);
      final stateContainer =
          state.containerList.first as TokenContainerFinalized;

      expect(stateContainer.issuer, "privacyIDEA");
      expect(stateContainer.nonce, "dbd2ab5aa9b539484fc3b78cd4bb08375d3eb30e");
      expect(stateContainer.timestamp, timeStamp);
      expect(stateContainer.serverUrl, Uri.parse("http://192.168.2.118:5000/"));
      expect(stateContainer.serial, "SMPH00067A2F");
      expect(stateContainer.ecKeyAlgorithm, EcKeyAlgorithm.secp384r1);
      expect(stateContainer.hashAlgorithm, Algorithms.SHA256);
      expect(stateContainer.finalizationState, FinalizationState.completed);

      expect(stateContainer.passphraseQuestion, "");
      expect(stateContainer.sslVerify, true);
      expect(stateContainer.privateClientKey, isNotNull);
      expect(stateContainer.publicClientKey, isNotNull);
    });
    test('finalizeContainer', () async {
      // prepare
      TestWidgetsFlutterBinding.ensureInitialized();
      var containerRepoState = buildUnfinalizedContainerState();
      final mockContainerRepo = MockTokenContainerRepository();
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.finalizeContainer(any, any)).thenAnswer(
        (_) async => ContainerFinalizationResponse(
          policies: ContainerPolicies(
            initialTokenAssignment: true,
            rolloverAllowed: true,
            disabledTokenDeletion: false,
            disabledUnregister: false,
          ),
        ),
      );
      when(
        mockContainerRepo.loadContainerState(),
      ).thenAnswer((_) => Future.value(containerRepoState));
      when(mockContainerRepo.saveContainerState(any)).thenAnswer((invocation) {
        containerRepoState =
            invocation.positionalArguments[0] as TokenContainerState;
        return Future.value(containerRepoState);
      });
      when(mockContainerRepo.saveContainer(any)).thenAnswer((invocation) {
        final container = invocation.positionalArguments[0] as TokenContainer;
        final i = containerRepoState.containerList.indexWhere(
          (element) => element.serial == container.serial,
        );
        final List<TokenContainer> newList;
        if (i == -1) {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..add(container);
        } else {
          newList = List<TokenContainer>.from(containerRepoState.containerList)
            ..[i] = container;
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
      when(
        mockTokenRepo.saveOrReplaceTokens(any),
      ).thenAnswer((_) => Future.value([]));
      final mockTokenNotifier = TokenNotifier(repoOverride: mockTokenRepo);
      final providerContainer = ProviderContainer(
        overrides: [
          tokenContainerProvider.overrideWith(() => mockTokenContainerProvider),
          tokenProvider.overrideWith(() => mockTokenNotifier),
        ],
      );
      final container =
          containerRepoState.containerList.first as TokenContainerUnfinalized;
      // act

      await providerContainer
          .read(tokenContainerProvider.notifier)
          .finalize(
            containerRepoState.containerList.first,
            isManually: false,
            urlIsOk: true,
          );

      // assert
      final state = await providerContainer.read(tokenContainerProvider.future);
      verify(mockContainerRepo.loadContainerState()).called(1);
      expect(state, containerRepoState);
      final stateContainer =
          state.containerList.first as TokenContainerFinalized;
      final expectedContainer = TokenContainerFinalized(
        issuer: "issuer",
        nonce: "nonce",
        timestamp: container.timestamp,
        serverUrl: Uri.parse("https://example.com"),
        serial: "serial",
        ecKeyAlgorithm: EcKeyAlgorithm.secp521r1,
        hashAlgorithm: Algorithms.SHA512,
        sslVerify: true,
        privateClientKey: "random",
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
      expect(
        stateContainer.finalizationState,
        expectedContainer.finalizationState,
      );
      expect(stateContainer.syncState, expectedContainer.syncState);
      expect(
        stateContainer.passphraseQuestion,
        expectedContainer.passphraseQuestion,
      );
      expect(stateContainer.sslVerify, expectedContainer.sslVerify);
      expect(stateContainer.privateClientKey, isNotEmpty);
      expect(stateContainer.publicClientKey, isNotEmpty);
    });
    group('sync', () {
      test('sync', () async {
        // prepare
        TestWidgetsFlutterBinding.ensureInitialized();
        var containerRepoState = buildFinalizedContainerState();
        final containerToSync =
            containerRepoState.containerList.first as TokenContainerFinalized;
        final mockContainerApi = MockTokenContainerApi();
        // final updatedTokens = <Token>[];
        when(
          mockContainerApi.sync(any, any, isInitSync: anyNamed('isInitSync')),
        ).thenAnswer(
          (v) async => ContainerSyncUpdates(
            containerSerial: 'CONTAINER01',
            newTokens: [
              TOTPToken(
                id: "ID03",
                serial: "TOTPTOKEN01",
                period: 30,
                algorithm: Algorithms.SHA256,
                digits: 8,
                secret: "SECRET03",
              ),
            ],
            updatedTokens: [
              HOTPToken(
                id: 'ID01',
                serial: "HOTPTOKEN01",
                containerSerial: "CONTAINER01",
                algorithm: Algorithms.SHA256,
                digits: 6,
                secret: "SECRET01",
                counter: 8,
              ),
            ],
            deletedTokens: [
              HOTPToken(
                id: "ID02",
                serial: "HOTPTOKEN02",
                containerSerial: "CONTAINER01",
                algorithm: Algorithms.SHA256,
                digits: 6,
                secret: "SECRET02",
                counter: 12,
              ),
            ],
            initAssignmentChecked: [],
            newPolicies: ContainerPolicies(
              rolloverAllowed: true,
              initialTokenAssignment: true,
              disabledTokenDeletion: false,
              disabledUnregister: false,
            ),
          ),
        );

        final mockContainerRepo = setupMockContainerRepo(
          () => containerRepoState,
          (state) => containerRepoState = state,
        );

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
            containerSerial: "CONTAINER01",
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
        when(
          mockTokenRepo.loadTokens(),
        ).thenAnswer((_) => Future.value(repoTokens.values.toList()));
        when(mockTokenRepo.saveOrReplaceTokens(any)).thenAnswer((invocation) {
          final tokens = invocation.positionalArguments[0] as List<Token>;
          for (final token in tokens) {
            repoTokens[token.id] = token;
          }
          return Future.value([]);
        });

        final mockTokenNotifier = TokenNotifier(repoOverride: mockTokenRepo);

        // prepare - settings notifier
        final MockSettingsRepository mockSettingsRepo =
            MockSettingsRepository();
        when(
          mockSettingsRepo.loadSettings(),
        ).thenAnswer((_) => Future.value(SettingsState()));
        when(mockSettingsRepo.saveSettings(any)).thenAnswer(
          (invocation) => Future.value(invocation.positionalArguments[0]),
        );
        final SettingsNotifier settingsNotifier = SettingsNotifier(
          repoOverride: mockSettingsRepo,
        );

        // prepare - provider container
        final providerContainer = ProviderContainer(
          overrides: [
            tokenContainerProvider.overrideWith(
              () => mockTokenContainerProvider,
            ),
            tokenProvider.overrideWith(() => mockTokenNotifier),
            settingsProvider.overrideWith(() => settingsNotifier),
          ],
        );

        // act
        var tokenState = await providerContainer.read(tokenProvider.future);
        await providerContainer
            .read(tokenContainerProvider.notifier)
            .syncContainers(
              tokenState: tokenState,
              isManually: false,
              isInitSync: false,
            );

        // assert
        final expectedStateUnordered = TokenState(
          tokens: [
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
            TOTPToken(
              id: "ID04",
              serial: "TOTPTOKEN02",
              period: 30,
              algorithm: Algorithms.SHA512,
              digits: 6,
              secret: "SECRET04",
            ),
          ],
        );
        final containerState = await providerContainer.read(
          tokenContainerProvider.future,
        );
        await Future.delayed(
          const Duration(milliseconds: 1000),
        ); // wait for the sync to finish
        tokenState = await providerContainer.read(tokenProvider.future);
        verify(mockContainerRepo.loadContainerState()).called(1);
        expect(containerState, containerRepoState);
        final stateContainer =
            containerState.containerList.first as TokenContainerFinalized;
        final expectedContainer = containerToSync.copyWith(
          policies: ContainerPolicies(
            rolloverAllowed: true,
            initialTokenAssignment: true,
            disabledTokenDeletion: false,
            disabledUnregister: false,
          ),
        );
        verify(
          mockContainerApi.sync(any, any, isInitSync: anyNamed('isInitSync')),
        ).called(1);
        expect(stateContainer.policies, expectedContainer.policies);
        expect(stateContainer.syncState, SyncState.completed);
        expect(stateContainer.initSynced, isTrue);
        expect(tokenState.tokens.length, 3);
        expect(
          tokenState.tokens,
          unorderedEquals(expectedStateUnordered.tokens),
        );
      });
    });
    test('getRolloverQrData', () async {
      // prepare
      final providerContainer = ProviderContainer();
      var containerRepoState = buildFinalizedContainerState();
      final qrDataContainer =
          containerRepoState.containerList.first as TokenContainerFinalized;
      final mockContainerRepo = setupMockContainerRepo(
        () => containerRepoState,
        (state) => containerRepoState = state,
      );
      final mockContainerApi = MockTokenContainerApi();
      when(mockContainerApi.getRolloverQrData(any)).thenAnswer(
        (_) async => TransferQrData(
          description: 'Some Random Data to be transferred',
          value: 'Some Random Data to be transferred',
        ),
      );
      final tokenContainerProvider = tokenContainerProviderOf(
        repo: mockContainerRepo,
        containerApi: mockContainerApi,
        eccUtils: EccUtils(),
      );
      await providerContainer.read(tokenContainerProvider.future);

      // act
      final qrData = await providerContainer
          .read(tokenContainerProvider.notifier)
          .getRolloverQrData(qrDataContainer);

      // assert
      verify(mockContainerApi.getRolloverQrData(any)).called(1);
      expect(qrData, 'Some Random Data to be transferred');
    });

    group('unregisterDelete', () {
      Future<ProviderContainer> setupContainer({
        required TokenContainerState Function() stateGetter,
        required void Function(TokenContainerState) stateSetter,
        required MockTokenContainerApi mockContainerApi,
      }) async {
        final mockContainerRepo = setupMockContainerRepo(
          stateGetter,
          stateSetter,
        );
        final mockTokenContainerProvider = TokenContainerNotifier(
          repoOverride: mockContainerRepo,
          containerApiOverride: mockContainerApi,
          eccUtilsOverride: EccUtils(),
        );
        final mockTokenRepo = MockTokenRepository();
        when(mockTokenRepo.loadTokens()).thenAnswer((_) => Future.value([]));
        when(
          mockTokenRepo.saveOrReplaceTokens(any),
        ).thenAnswer((_) => Future.value([]));
        final mockTokenNotifier = TokenNotifier(repoOverride: mockTokenRepo);
        final providerContainer = ProviderContainer(
          overrides: [
            tokenContainerProvider.overrideWith(
              () => mockTokenContainerProvider,
            ),
            tokenProvider.overrideWith(() => mockTokenNotifier),
          ],
        );
        await providerContainer.read(tokenContainerProvider.future);
        return providerContainer;
      }

      test(
        'returns true and deletes container when unregister succeeds',
        () async {
          TestWidgetsFlutterBinding.ensureInitialized();
          var repoState = buildFinalizedContainerState();
          final container =
              repoState.containerList.first as TokenContainerFinalized;
          final mockApi = MockTokenContainerApi();
          when(
            mockApi.unregister(any),
          ).thenAnswer((_) async => UnregisterContainerResult(success: true));
          final providerContainer = await setupContainer(
            stateGetter: () => repoState,
            stateSetter: (s) => repoState = s,
            mockContainerApi: mockApi,
          );

          final result = await providerContainer
              .read(tokenContainerProvider.notifier)
              .unregisterDelete(container);

          expect(result, isTrue);
          final state = await providerContainer.read(
            tokenContainerProvider.future,
          );
          expect(state.containerList, isEmpty);
        },
      );

      test(
        'returns false and keeps container when unregister returns success: false',
        () async {
          TestWidgetsFlutterBinding.ensureInitialized();
          var repoState = buildFinalizedContainerState();
          final container =
              repoState.containerList.first as TokenContainerFinalized;
          final mockApi = MockTokenContainerApi();
          when(
            mockApi.unregister(any),
          ).thenAnswer((_) async => UnregisterContainerResult(success: false));
          final providerContainer = await setupContainer(
            stateGetter: () => repoState,
            stateSetter: (s) => repoState = s,
            mockContainerApi: mockApi,
          );

          final result = await providerContainer
              .read(tokenContainerProvider.notifier)
              .unregisterDelete(container);

          expect(result, isFalse);
          final state = await providerContainer.read(
            tokenContainerProvider.future,
          );
          expect(state.containerList.length, equals(1));
        },
      );

      test(
        'returns true and deletes locally when server returns containerNotFound (601)',
        () async {
          TestWidgetsFlutterBinding.ensureInitialized();
          var repoState = buildFinalizedContainerState();
          final container =
              repoState.containerList.first as TokenContainerFinalized;
          final mockApi = MockTokenContainerApi();
          when(mockApi.unregister(any)).thenThrow(
            PiServerResultError(
              code: PiServerResultErrorCodes.resourceNotFound,
              message: 'Not found',
            ),
          );
          final providerContainer = await setupContainer(
            stateGetter: () => repoState,
            stateSetter: (s) => repoState = s,
            mockContainerApi: mockApi,
          );

          final result = await providerContainer
              .read(tokenContainerProvider.notifier)
              .unregisterDelete(container);

          expect(result, isTrue);
          final state = await providerContainer.read(
            tokenContainerProvider.future,
          );
          expect(state.containerList, isEmpty);
        },
      );

      test(
        'returns true and deletes locally when server returns containerNotRegistered (3001)',
        () async {
          TestWidgetsFlutterBinding.ensureInitialized();
          var repoState = buildFinalizedContainerState();
          final container =
              repoState.containerList.first as TokenContainerFinalized;
          final mockApi = MockTokenContainerApi();
          when(mockApi.unregister(any)).thenThrow(
            PiServerResultError(
              code: PiServerResultErrorCodes.containerNotRegistered,
              message: 'Not registered',
            ),
          );
          final providerContainer = await setupContainer(
            stateGetter: () => repoState,
            stateSetter: (s) => repoState = s,
            mockContainerApi: mockApi,
          );

          final result = await providerContainer
              .read(tokenContainerProvider.notifier)
              .unregisterDelete(container);

          expect(result, isTrue);
          final state = await providerContainer.read(
            tokenContainerProvider.future,
          );
          expect(state.containerList, isEmpty);
        },
      );

      test(
        'returns true and deletes locally when server returns containerInvalidChallenge (3002)',
        () async {
          TestWidgetsFlutterBinding.ensureInitialized();
          var repoState = buildFinalizedContainerState();
          final container =
              repoState.containerList.first as TokenContainerFinalized;
          final mockApi = MockTokenContainerApi();
          when(mockApi.unregister(any)).thenThrow(
            PiServerResultError(
              code: PiServerResultErrorCodes.containerInvalidChallenge,
              message: 'Signature error',
            ),
          );
          final providerContainer = await setupContainer(
            stateGetter: () => repoState,
            stateSetter: (s) => repoState = s,
            mockContainerApi: mockApi,
          );

          final result = await providerContainer
              .read(tokenContainerProvider.notifier)
              .unregisterDelete(container);

          expect(result, isTrue);
          final state = await providerContainer.read(
            tokenContainerProvider.future,
          );
          expect(state.containerList, isEmpty);
        },
      );

      test(
        'returns false when server returns unhandled PiServerResultError code',
        () async {
          TestWidgetsFlutterBinding.ensureInitialized();
          var repoState = buildFinalizedContainerState();
          final container =
              repoState.containerList.first as TokenContainerFinalized;
          final mockApi = MockTokenContainerApi();
          when(mockApi.unregister(any)).thenThrow(
            PiServerResultError(code: 999, message: 'Some other server error'),
          );
          final providerContainer = await setupContainer(
            stateGetter: () => repoState,
            stateSetter: (s) => repoState = s,
            mockContainerApi: mockApi,
          );

          final result = await providerContainer
              .read(tokenContainerProvider.notifier)
              .unregisterDelete(container);

          expect(result, isFalse);
          final state = await providerContainer.read(
            tokenContainerProvider.future,
          );
          expect(state.containerList.length, equals(1));
        },
      );

      test('returns false when server throws ResponseError', () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        var repoState = buildFinalizedContainerState();
        final container =
            repoState.containerList.first as TokenContainerFinalized;
        final mockApi = MockTokenContainerApi();
        when(mockApi.unregister(any)).thenThrow(
          ResponseError(http.Response('<title>404 Not Found</title>', 404)),
        );
        final providerContainer = await setupContainer(
          stateGetter: () => repoState,
          stateSetter: (s) => repoState = s,
          mockContainerApi: mockApi,
        );

        final result = await providerContainer
            .read(tokenContainerProvider.notifier)
            .unregisterDelete(container);

        expect(result, isFalse);
        final state = await providerContainer.read(
          tokenContainerProvider.future,
        );
        expect(state.containerList.length, equals(1));
      });
    });

    test(
      'build resets syncing containers to failed state on startup',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        final syncingContainer = TokenContainerFinalized(
          issuer: 'privacyIDEA',
          nonce: 'nonce',
          timestamp: DateTime.now(),
          serverUrl: Uri.parse('https://example.com'),
          serial: 'SYNC01',
          ecKeyAlgorithm: EcKeyAlgorithm.secp384r1,
          hashAlgorithm: Algorithms.SHA256,
          sslVerify: false,
          publicClientKey: 'publicClientKey',
          privateClientKey: 'privateClientKey',
          syncState: SyncState.syncing,
          policies: ContainerPolicies(
            rolloverAllowed: false,
            initialTokenAssignment: false,
            disabledTokenDeletion: false,
            disabledUnregister: false,
          ),
        );
        var repoState = TokenContainerState(containerList: [syncingContainer]);
        final mockContainerRepo = setupMockContainerRepo(
          () => repoState,
          (s) => repoState = s,
        );
        final mockContainerApi = MockTokenContainerApi();
        final provider = tokenContainerProviderOf(
          repo: mockContainerRepo,
          containerApi: mockContainerApi,
          eccUtils: EccUtils(),
        );
        final providerContainer = ProviderContainer();
        final state = await providerContainer.read(provider.future);

        expect(state.containerList.first, isA<TokenContainerFinalized>());
        expect(
          (state.containerList.first as TokenContainerFinalized).syncState,
          equals(SyncState.failed),
        );
      },
    );

    test(
      'handleProcessorResults does not replace container when disabledUnregister is true',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        // buildFinalizedContainerState() returns a container with serial "CONTAINER01" and disabledUnregister: true
        var repoState = buildFinalizedContainerState();
        final originalNonce =
            (repoState.containerList.first as TokenContainerFinalized).nonce;
        final mockContainerRepo = setupMockContainerRepo(
          () => repoState,
          (s) => repoState = s,
        );
        final mockContainerApi = MockTokenContainerApi();
        final mockTokenContainerProvider = TokenContainerNotifier(
          repoOverride: mockContainerRepo,
          containerApiOverride: mockContainerApi,
          eccUtilsOverride: EccUtils(),
        );
        final mockTokenRepo = MockTokenRepository();
        when(mockTokenRepo.loadTokens()).thenAnswer((_) => Future.value([]));
        when(
          mockTokenRepo.saveOrReplaceTokens(any),
        ).thenAnswer((_) => Future.value([]));
        final mockTokenNotifier = TokenNotifier(repoOverride: mockTokenRepo);
        final providerContainer = ProviderContainer(
          overrides: [
            tokenContainerProvider.overrideWith(
              () => mockTokenContainerProvider,
            ),
            tokenProvider.overrideWith(() => mockTokenNotifier),
          ],
        );
        await providerContainer.read(tokenContainerProvider.future);

        final timeStamp = DateTime.now();
        final Uri uri = Uri.parse(
          'pia://container/CONTAINER01?'
          'issuer=privacyIDEA&'
          'ttl=10&'
          'nonce=newNonce123&'
          'time=$timeStamp&'
          'url=http://example.com/&'
          'serial=CONTAINER01&'
          'key_algorithm=secp384r1&'
          'hash_algorithm=SHA256&'
          'ssl_verify=True&'
          'passphrase=',
        );
        final processorResults = await TokenContainerProcessor().processUri(
          uri,
        );
        expect(processorResults, isNotNull);

        await providerContainer
            .read(tokenContainerProvider.notifier)
            .handleProcessorResult(
              processorResults!.first,
              args: {
                // doReplace not set (null) → would show dialog, but disabledUnregister
                // prevents container from being in replaceableExisting, so dialog is never shown
                TokenContainerProcessor.ARG_INIT_SYNC: false,
                TokenContainerProcessor.ARG_URL_IS_OK: true,
              },
            );

        final state = await providerContainer.read(
          tokenContainerProvider.future,
        );
        expect(state.containerList.length, equals(1));
        final existing = state.containerList.first as TokenContainerFinalized;
        expect(existing.nonce, equals(originalNonce));
      },
    );

    group('finalize', () {
      const publicClientKey =
          "-----BEGIN PUBLIC KEY-----\n"
          "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAE8Xs0q2PPvkIlKTcQkMxMDnv/4tH3dDqg\n"
          "lK42aHN11oT+wJDn11cGJ5b5uuu2owfePgNDzlTwhK3Bvx2x5NBm/JWztUOaWI29\n"
          "zdwE1yJStBySahE2CIGfKc1RfcASp5/4\n"
          "-----END PUBLIC KEY-----";
      const privateClientKey =
          "-----BEGIN EC PRIVATE KEY-----\n"
          "MIGkAgEBBDCleRofxXJwTtc0HUeE/Af8P4depFM0KY7oT4hMQdt3geK5uDWEOZn4\n"
          "DaCMTGrsSP2gBwYFK4EEACKhZANiAATxezSrY8++QiUpNxCQzEwOe//i0fd0OqCU\n"
          "rjZoc3XWhP7AkOfXVwYnlvm667ajB94+A0POVPCErcG/HbHk0Gb8lbO1Q5pYjb3N\n"
          "3ATXIlK0HJJqETYIgZ8pzVF9wBKnn/g=\n"
          "-----END EC PRIVATE KEY-----";

      TokenContainerUnfinalized buildContainerWithKeyPair({
        FinalizationState finalizationState =
            FinalizationState.sendingPublicKeyFailed,
      }) => TokenContainerUnfinalized(
        issuer: 'privacyIDEA',
        ttl: Duration(minutes: 10),
        nonce: 'b33d3a11c8d1b45f19640035e27944ccf0b2383d',
        timestamp: DateTime.now(),
        serverUrl: Uri.parse('http://example.com'),
        serial: 'SMPH00067A2F',
        ecKeyAlgorithm: EcKeyAlgorithm.secp384r1,
        hashAlgorithm: Algorithms.SHA256,
        sslVerify: false,
        publicClientKey: publicClientKey,
        privateClientKey: privateClientKey,
        finalizationState: finalizationState,
      );

      test(
        'reuses existing key pair instead of generating a new one',
        () async {
          final providerContainer = ProviderContainer();
          var repoState = TokenContainerState(
            containerList: [buildContainerWithKeyPair()],
          );
          final mockRepo = setupMockContainerRepo(
            () => repoState,
            (s) => repoState = s,
          );
          final mockApi = MockTokenContainerApi();

          String? capturedPublicKey;
          when(mockApi.finalizeContainer(any, any)).thenAnswer((inv) async {
            final c = inv.positionalArguments[0] as TokenContainerUnfinalized;
            capturedPublicKey = c.publicClientKey;
            return containerFinalizationResponseExample;
          });

          final provider = tokenContainerProviderOf(
            repo: mockRepo,
            containerApi: mockApi,
            eccUtils: EccUtils(),
          );
          final state = await providerContainer.read(provider.future);
          final container =
              state.containerList.first as TokenContainerUnfinalized;

          await providerContainer
              .read(provider.notifier)
              .finalize(
                container,
                isManually: true,
                urlIsOk: true,
                addDeviceInfos: false,
              );

          expect(capturedPublicKey, equals(publicClientKey));
        },
      );

      test(
        'returns null and sets state to failed when PiServerResultError is thrown',
        () async {
          final providerContainer = ProviderContainer();
          var repoState = TokenContainerState(
            containerList: [buildContainerWithKeyPair()],
          );
          final mockRepo = setupMockContainerRepo(
            () => repoState,
            (s) => repoState = s,
          );
          final mockApi = MockTokenContainerApi();
          when(mockApi.finalizeContainer(any, any)).thenThrow(
            PiServerResultError(
              code: 3002,
              message: 'ERR3002: Could not verify signature!',
            ),
          );

          final provider = tokenContainerProviderOf(
            repo: mockRepo,
            containerApi: mockApi,
            eccUtils: EccUtils(),
          );
          final state = await providerContainer.read(provider.future);
          final container =
              state.containerList.first as TokenContainerUnfinalized;

          final result = await providerContainer
              .read(provider.notifier)
              .finalize(
                container,
                isManually: false,
                urlIsOk: true,
                addDeviceInfos: false,
              );

          expect(result, isNull);
          final finalState = await providerContainer.read(provider.future);
          final finalContainer =
              finalState.containerList.first as TokenContainerUnfinalized;
          expect(
            finalContainer.finalizationState,
            equals(FinalizationState.sendingPublicKeyFailed),
          );
        },
      );
    });
  });

  _testTokenContainerNotifierErrors();
}

// Error handling of the TokenContainerNotifier: sync failures, offline
// behaviour, finalization failures, initSynced and tokens that move between
// containers.
//
// All collaborators are hand-written fakes (no generated mocks), so the real
// TokenContainerNotifier, TokenNotifier and SettingsNotifier run unchanged.
//
// Tests that need the app navigator, the global ref (status messages) or the
// delete dialog run as widget tests inside [TestsAppWrapper] and drive the
// notifier through `tester.runAsync`. All other tests are plain unit tests.
//
// Run the tests that document a lib bug with
// `flutter test --dart-define=RUN_BUG_TESTS=true <file>`.

const _runBugTests = bool.fromEnvironment('RUN_BUG_TESTS');

/// Skip reason of a test that documents a confirmed lib bug. The test is only
/// executed with `--dart-define=RUN_BUG_TESTS=true`.
Object? _skipBug(String reason) => _runBugTests ? null : 'BUG: $reason';

const _originalPolicies = ContainerPolicies(
  rolloverAllowed: false,
  initialTokenAssignment: false,
  disabledTokenDeletion: true,
  disabledUnregister: true,
);

const _syncedPolicies = ContainerPolicies(
  rolloverAllowed: true,
  initialTokenAssignment: true,
  disabledTokenDeletion: false,
  disabledUnregister: false,
);

const _finalizationResponse = ContainerFinalizationResponse(
  policies: _syncedPolicies,
);

/////////////////////////////////// DATA ///////////////////////////////////

TokenContainerFinalized _container(
  String serial, {
  SyncState syncState = SyncState.notStarted,
  bool initSynced = false,
  ContainerPolicies policies = _originalPolicies,
}) => TokenContainerFinalized(
  issuer: 'privacyIDEA',
  nonce: 'nonce-$serial',
  timestamp: DateTime.utc(2024, 11, 14, 9, 30),
  serverUrl: Uri.parse('https://pi.example.com'),
  serial: serial,
  ecKeyAlgorithm: EcKeyAlgorithm.secp384r1,
  hashAlgorithm: Algorithms.SHA256,
  sslVerify: true,
  publicClientKey: 'publicClientKey',
  privateClientKey: 'privateClientKey',
  syncState: syncState,
  initSynced: initSynced,
  policies: policies,
);

TokenContainerUnfinalized _unfinalized(String serial) =>
    TokenContainerUnfinalized(
      issuer: 'privacyIDEA',
      ttl: const Duration(minutes: 10),
      nonce: 'nonce-$serial',
      timestamp: DateTime.now(),
      serverUrl: Uri.parse('https://pi.example.com'),
      serial: serial,
      ecKeyAlgorithm: EcKeyAlgorithm.secp256r1,
      hashAlgorithm: Algorithms.SHA256,
      sslVerify: true,
    );

HOTPToken _hotp(
  String id,
  String serial, {
  String? containerSerial,
  int counter = 0,
  int? folderId,
}) => HOTPToken(
  id: id,
  serial: serial,
  containerSerial: containerSerial,
  algorithm: Algorithms.SHA256,
  digits: 6,
  secret: 'JBSWY3DPEHPK3PXP',
  counter: counter,
  folderId: folderId,
);

ContainerSyncUpdates _updates(
  String containerSerial, {
  List<Token> newTokens = const [],
  List<Token> updatedTokens = const [],
  List<Token> deletedTokens = const [],
  ContainerPolicies policies = _syncedPolicies,
}) => ContainerSyncUpdates(
  containerSerial: containerSerial,
  newTokens: newTokens,
  updatedTokens: updatedTokens,
  deletedTokens: deletedTokens,
  initAssignmentChecked: const [],
  newPolicies: policies,
);

PiServerResultError _piError(int code, [String message = 'server says no']) =>
    PiServerResultError(code: code, message: message);

/// Serials of the containers in the failed containers result of
/// `syncContainers`, independent of whether the result is keyed by error code
/// or serial.
List<String> _failedSerials(dynamic failed) {
  final Iterable values = failed is Map ? failed.values : failed as Iterable;
  return [
    for (final value in values)
      if (value is Iterable)
        for (final c in value) (c as TokenContainer).serial
      else
        (value as TokenContainer).serial,
  ];
}

/////////////////////////////////// FAKES //////////////////////////////////

class _FakeContainerRepo implements TokenContainerRepository {
  _FakeContainerRepo(List<TokenContainer> initial)
    : state = TokenContainerState(containerList: List.of(initial));

  TokenContainerState state;

  TokenContainerState _upsert(List<TokenContainer> containers) {
    final list = List<TokenContainer>.of(state.containerList);
    for (final container in containers) {
      final i = list.indexWhere((e) => e.serial == container.serial);
      if (i == -1) {
        list.add(container);
      } else {
        list[i] = container;
      }
    }
    return state = TokenContainerState(containerList: list);
  }

  @override
  Future<TokenContainerState> loadContainerState() async => state;

  @override
  Future<TokenContainerState> saveContainerState(
    TokenContainerState containerState,
  ) async => state = containerState;

  @override
  Future<TokenContainerState> saveContainerList(
    List<TokenContainer> containerList,
  ) async => _upsert(containerList);

  @override
  Future<TokenContainerState> saveContainer(TokenContainer container) async =>
      _upsert([container]);

  @override
  Future<TokenContainerState> deleteContainer(String serial) async =>
      state = TokenContainerState(
        containerList: state.containerList
            .where((e) => e.serial != serial)
            .toList(),
      );

  @override
  Future<TokenContainerState> deleteAllContainer() async =>
      state = const TokenContainerState(containerList: []);

  @override
  Future<TokenContainer?> loadContainer(String serial) async =>
      state.containerOf(serial);
}

class _FakeTokenRepo implements TokenRepository {
  _FakeTokenRepo(List<Token> initial)
    : tokens = {for (final t in initial) t.id: t};

  final Map<String, Token> tokens;
  final List<String> deletedIds = [];

  @override
  Future<Token?> loadToken(String id) async => tokens[id];

  @override
  Future<List<Token>> loadTokens() async => tokens.values.toList();

  @override
  Future<bool> saveOrReplaceToken(Token token) async {
    tokens[token.id] = token;
    return true;
  }

  @override
  Future<List<T>> saveOrReplaceTokens<T extends Token>(List<T> tokens) async {
    for (final token in tokens) {
      this.tokens[token.id] = token;
    }
    return <T>[];
  }

  @override
  Future<bool> deleteToken(Token token) async {
    deletedIds.add(token.id);
    tokens.remove(token.id);
    return true;
  }

  @override
  Future<List<T>> deleteTokens<T extends Token>(List<T> tokens) async {
    for (final token in tokens) {
      deletedIds.add(token.id);
      this.tokens.remove(token.id);
    }
    return <T>[];
  }
}

class _FakeSettingsRepo implements SettingsRepository {
  @override
  Future<SettingsState> loadSettings() async => SettingsState();

  @override
  Future<bool> saveSettings(SettingsState settings) async => true;
}

typedef _SyncHandler =
    Future<ContainerSyncUpdates?> Function(
      TokenContainerFinalized container,
      TokenState tokenState,
      bool? isInitSync,
    );

class _FakeContainerApi implements TokenContainerApi {
  /// Sync behaviour per container serial.
  final Map<String, _SyncHandler> onSync = {};
  final List<({String serial, bool? isInitSync})> syncCalls = [];

  Future<ContainerFinalizationResponse> Function(
    TokenContainerUnfinalized container,
  )?
  onFinalize;
  int finalizeCalls = 0;

  @override
  Future<ContainerSyncUpdates?> sync(
    TokenContainerFinalized container,
    TokenState tokenState, {
    bool? isInitSync,
  }) async {
    syncCalls.add((serial: container.serial, isInitSync: isInitSync));
    final handler = onSync[container.serial];
    if (handler == null) {
      throw StateError('No sync handler for ${container.serial}');
    }
    return handler(container, tokenState, isInitSync);
  }

  @override
  Future<ContainerFinalizationResponse> finalizeContainer(
    TokenContainerUnfinalized container,
    EccUtils eccUtils,
  ) async {
    finalizeCalls++;
    final handler = onFinalize;
    if (handler == null) return _finalizationResponse;
    return handler(container);
  }

  @override
  Future<TransferQrData> getRolloverQrData(TokenContainerFinalized container) =>
      throw UnimplementedError();

  @override
  Future<UnregisterContainerResult> unregister(
    TokenContainerFinalized container,
  ) => throw UnimplementedError();
}

/// Answers every post with the given response and remembers the requested urls.
class _FakeIoClient extends Fake implements PrivacyideaIOClient {
  _FakeIoClient(this.response);

  final Response response;
  final List<Uri> posts = [];

  @override
  Future<Response> doPost({
    required Uri url,
    required Map<String, String?> body,
    bool sslVerify = true,
    Set<int> expectedErrorStatusCodes = const {},
  }) async {
    posts.add(url);
    return response;
  }
}

/////////////////////////////// LOG CAPTURE ////////////////////////////////

class _AllowAllFilter extends printer.LogFilter {
  @override
  bool shouldLog(printer.LogEvent event) => true;
}

class _MessagePrinter extends printer.LogPrinter {
  @override
  List<String> log(printer.LogEvent event) => [event.message.toString()];
}

class _WarningCapture extends printer.LogOutput {
  final List<String> warnings = [];

  @override
  void output(printer.OutputEvent event) {
    if (event.level == printer.Level.warning) warnings.addAll(event.lines);
  }
}

/// Redirects the warnings of the app [Logger] into the returned capture until
/// the end of the test.
_WarningCapture _captureWarnings() {
  final original = Logger.print;
  final capture = _WarningCapture();
  Logger.print = printer.Logger(
    filter: _AllowAllFilter(),
    printer: _MessagePrinter(),
    output: capture,
  );
  addTearDown(() => Logger.print = original);
  return capture;
}

/////////////////////////////// TEST HARNESS ///////////////////////////////

class _Fixture {
  _Fixture({
    List<TokenContainer> containers = const [],
    List<Token> tokens = const [],
    TokenContainerApi? api,
  }) : containerRepo = _FakeContainerRepo(containers),
       tokenRepo = _FakeTokenRepo(tokens),
       api = api ?? _FakeContainerApi();

  final _FakeContainerRepo containerRepo;
  final _FakeTokenRepo tokenRepo;
  final _FakeSettingsRepo settingsRepo = _FakeSettingsRepo();
  final TokenContainerApi api;

  _FakeContainerApi get fake => api as _FakeContainerApi;

  List<Override> get overrides => [
    tokenContainerProvider.overrideWith(
      () => TokenContainerNotifier(
        repoOverride: containerRepo,
        containerApiOverride: api,
        eccUtilsOverride: const EccUtils(),
      ),
    ),
    tokenProvider.overrideWith(() => TokenNotifier(repoOverride: tokenRepo)),
    settingsProvider.overrideWith(
      () => SettingsNotifier(repoOverride: settingsRepo),
    ),
  ];
}

class _Env {
  _Env(this.container, this.fixture, {this.tester});

  final ProviderContainer container;
  final _Fixture fixture;

  /// Set for widget tests: all async work then runs through `runAsync`.
  final WidgetTester? tester;

  Future<T> run<T>(Future<T> Function() body) async {
    final t = tester;
    if (t == null) return body();
    return (await t.runAsync(body)) as T;
  }

  TokenContainerNotifier get notifier =>
      container.read(tokenContainerProvider.notifier);

  Future<TokenContainerState> containers() =>
      run(() => container.read(tokenContainerProvider.future));

  Future<TokenState> tokens() =>
      run(() => container.read(tokenProvider.future));

  Future<TokenContainerFinalized> finalized(String serial) async =>
      (await containers()).containerOf(serial) as TokenContainerFinalized;

  Future<Map<int, TokenContainerFinalized>> sync({
    bool isManually = false,
    bool? isInitSync,
    List<TokenContainerFinalized>? only,
  }) => run(() async {
    final tokenState = await container.read(tokenProvider.future);
    return notifier.syncContainers(
      tokenState: tokenState,
      isManually: isManually,
      isInitSync: isInitSync,
      containersToSync: only,
    );
  });

  Future<TokenContainerFinalized?> finalize(
    TokenContainer c, {
    required bool isManually,
  }) => run(
    () => notifier.finalize(
      c,
      isManually: isManually,
      urlIsOk: true,
      addDeviceInfos: false,
    ),
  );

  StatusMessage? get status => container.read(statusProvider).current;
}

Future<_Env> _plainEnv(_Fixture fixture) async {
  final container = ProviderContainer(overrides: fixture.overrides);
  addTearDown(container.dispose);
  final env = _Env(container, fixture);
  await env.containers();
  return env;
}

Future<_Env> _widgetEnv(WidgetTester tester, _Fixture fixture) async {
  await tester.pumpWidget(
    TestsAppWrapper(overrides: fixture.overrides, child: const SizedBox()),
  );
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(Scaffold)),
  );
  final env = _Env(container, fixture, tester: tester);
  await env.containers();
  return env;
}

/// Lets a dialog that was opened by the notifier appear.
Future<void> _pumpDialogs(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void _testTokenContainerNotifierErrors() {
  group('syncContainers: failedContainers', () {
    test(
      'reports both containers when two containers fail with the same error code',
      () async {
        final fx = _Fixture(containers: [_container('A'), _container('B')]);
        for (final serial in ['A', 'B']) {
          fx.fake.onSync[serial] = (_, _, _) async => throw _piError(
            PiServerResultErrorCodes.containerInvalidChallenge,
          );
        }
        final env = await _plainEnv(fx);

        final failed = await env.sync();

        expect(_failedSerials(failed), unorderedEquals(['A', 'B']));
      },
      skip: _skipBug(
        'syncContainers collects failedContainers in a Map keyed by error code, so the second container with the same code overwrites the first (token_container_notifier.dart:226)',
      ),
    );

    test(
      'reports both containers when they fail with different error codes',
      () async {
        final fx = _Fixture(containers: [_container('A'), _container('B')]);
        fx.fake.onSync['A'] = (_, _, _) async =>
            throw _piError(PiServerResultErrorCodes.containerInvalidChallenge);
        fx.fake.onSync['B'] = (_, _, _) async =>
            throw _piError(PiServerResultErrorCodes.server);
        final env = await _plainEnv(fx);

        final failed = await env.sync();

        expect(_failedSerials(failed), unorderedEquals(['A', 'B']));
        expect(
          failed.keys,
          unorderedEquals([
            PiServerResultErrorCodes.containerInvalidChallenge,
            PiServerResultErrorCodes.server,
          ]),
        );
      },
    );

    test(
      'a single failing container does not mark the other as failed',
      () async {
        final fx = _Fixture(containers: [_container('A'), _container('B')]);
        fx.fake.onSync['A'] = (_, _, _) async =>
            throw _piError(PiServerResultErrorCodes.containerInvalidChallenge);
        fx.fake.onSync['B'] = (_, _, _) async => _updates('B');
        final env = await _plainEnv(fx);

        final failed = await env.sync();

        expect(_failedSerials(failed), ['A']);
        expect((await env.finalized('A')).syncState, SyncState.failed);
        expect((await env.finalized('B')).syncState, SyncState.completed);
      },
    );
  });

  group('syncContainers: server reports the container as missing', () {
    for (final code in [
      PiServerResultErrorCodes.resourceNotFound,
      PiServerResultErrorCodes.containerNotRegistered,
    ]) {
      group('error code $code', () {
        testWidgets(
          'isManually false: clears disabledUnregister, marks sync as failed, '
          'logs no warning and shows neither dialog nor status message',
          (tester) async {
            final capture = _captureWarnings();
            final fx = _Fixture(containers: [_container('A')]);
            fx.fake.onSync['A'] = (_, _, _) async => throw _piError(code);
            final env = await _widgetEnv(tester, fx);
            capture.warnings.clear();

            final failed = await env.sync();
            await _pumpDialogs(tester);

            final a = await env.finalized('A');
            expect(a.policies.disabledUnregister, isFalse);
            // Only disabledUnregister is touched, the other policies stay.
            expect(
              a.policies,
              _originalPolicies.copyWith(disabledUnregister: false),
            );
            expect(a.syncState, SyncState.failed);
            expect(a.initSynced, isFalse);
            expect(
              capture.warnings,
              isEmpty,
              reason: 'A container that is gone on the server is no warning',
            );
            expect(find.byType(DeleteContainerDialog), findsNothing);
            expect(env.status, isNull);
            expect(_failedSerials(failed), ['A']);
            expect(failed.keys, [code]);
          },
        );

        testWidgets(
          'isManually true: clears disabledUnregister and offers to delete '
          'the container instead of showing an error message',
          (tester) async {
            final fx = _Fixture(containers: [_container('A')]);
            fx.fake.onSync['A'] = (_, _, _) async => throw _piError(code);
            final env = await _widgetEnv(tester, fx);

            final failed = await env.sync(isManually: true);
            await _pumpDialogs(tester);

            final a = await env.finalized('A');
            expect(a.policies.disabledUnregister, isFalse);
            expect(a.syncState, SyncState.failed);
            expect(find.byType(DeleteContainerDialog), findsOneWidget);
            expect(find.text('Container A not found'), findsOneWidget);
            expect(env.status, isNull);
            expect(_failedSerials(failed), ['A']);
          },
        );
      });
    }

    testWidgets('does not touch other containers that sync successfully', (
      tester,
    ) async {
      final fx = _Fixture(containers: [_container('A'), _container('B')]);
      fx.fake.onSync['A'] = (_, _, _) async =>
          throw _piError(PiServerResultErrorCodes.resourceNotFound);
      fx.fake.onSync['B'] = (_, _, _) async => _updates('B');
      final env = await _widgetEnv(tester, fx);

      await env.sync();

      final a = await env.finalized('A');
      final b = await env.finalized('B');
      expect(a.syncState, SyncState.failed);
      expect(a.policies.disabledUnregister, isFalse);
      expect(b.syncState, SyncState.completed);
      expect(b.initSynced, isTrue);
      expect(b.policies, _syncedPolicies);
    });

    testWidgets(
      'the real api maps HTTP 404 on the challenge to resourceNotFound',
      (tester) async {
        final io = _FakeIoClient(Response('', 404));
        final fx = _Fixture(
          containers: [_container('A')],
          api: PiContainerApi(ioClient: io),
        );
        final env = await _widgetEnv(tester, fx);

        final failed = await env.sync();
        await _pumpDialogs(tester);

        final a = await env.finalized('A');
        expect(io.posts.map((u) => u.path), ['/container/challenge']);
        expect(failed.keys, [PiServerResultErrorCodes.resourceNotFound]);
        expect(a.syncState, SyncState.failed);
        expect(a.policies.disabledUnregister, isFalse);
        expect(find.byType(DeleteContainerDialog), findsNothing);
      },
    );
  });

  group('syncContainers: other errors', () {
    testWidgets(
      'isManually false: marks sync as failed, keeps policies, logs a warning, '
      'shows neither dialog nor status message',
      (tester) async {
        final capture = _captureWarnings();
        final fx = _Fixture(containers: [_container('A')]);
        fx.fake.onSync['A'] = (_, _, _) async =>
            throw _piError(PiServerResultErrorCodes.server, 'boom');
        final env = await _widgetEnv(tester, fx);
        capture.warnings.clear();

        final failed = await env.sync();
        await _pumpDialogs(tester);

        final a = await env.finalized('A');
        expect(a.syncState, SyncState.failed);
        expect(a.policies, _originalPolicies);
        expect(find.byType(DeleteContainerDialog), findsNothing);
        expect(env.status, isNull);
        expect(failed.keys, [PiServerResultErrorCodes.server]);
        expect(
          capture.warnings.where(
            (w) => w.contains('Failed to sync container A'),
          ),
          isNotEmpty,
        );
      },
    );

    testWidgets(
      'isManually true: shows the failure as status message, no delete dialog',
      (tester) async {
        final fx = _Fixture(containers: [_container('A')]);
        fx.fake.onSync['A'] = (_, _, _) async =>
            throw _piError(PiServerResultErrorCodes.server, 'boom');
        final env = await _widgetEnv(tester, fx);

        await env.sync(isManually: true);
        await _pumpDialogs(tester);

        final a = await env.finalized('A');
        expect(a.syncState, SyncState.failed);
        expect(a.policies, _originalPolicies);
        expect(find.byType(DeleteContainerDialog), findsNothing);
        final status = env.status;
        expect(status, isNotNull);
        expect(status!.type, StatusMessageType.error);
        expect(
          status.message(AppLocalizationsEn()),
          'Failed to sync container A',
        );
        expect(status.details!(AppLocalizationsEn()), 'boom');
      },
    );
  });

  group('syncContainers: offline', () {
    test(
      'a SocketException fails only that container, tokens and policies stay, '
      'other containers are still synced',
      () async {
        final tokenA = _hotp('idA', 'SERIAL-A', containerSerial: 'A');
        final fx = _Fixture(
          containers: [_container('A'), _container('B')],
          tokens: [tokenA],
        );
        fx.fake.onSync['A'] = (_, _, _) async =>
            throw const SocketException('Connection refused');
        fx.fake.onSync['B'] = (_, _, _) async => _updates(
          'B',
          newTokens: [_hotp('idNew', 'SERIAL-NEW', containerSerial: 'B')],
        );
        final env = await _plainEnv(fx);

        await env.sync();

        final a = await env.finalized('A');
        final b = await env.finalized('B');
        expect(a.syncState, SyncState.failed);
        expect(a.initSynced, isFalse);
        expect(a.policies, _originalPolicies);
        expect(b.syncState, SyncState.completed);
        expect(b.initSynced, isTrue);
        expect(b.policies, _syncedPolicies);

        final tokens = (await env.tokens()).tokens;
        expect(
          tokens.map((t) => t.serial),
          unorderedEquals(['SERIAL-A', 'SERIAL-NEW']),
        );
        expect(
          tokens.firstWhere((t) => t.serial == 'SERIAL-A').containerSerial,
          'A',
        );
        expect(fx.tokenRepo.deletedIds, isEmpty);
      },
    );

    test('the real api answers a connection failure with ResponseError: '
        'sync fails, tokens and policies stay', () async {
      final io = _FakeIoClient(
        ResponseBuilder.fromMessage('Connection refused'),
      );
      final tokenA = _hotp('idA', 'SERIAL-A', containerSerial: 'A', counter: 7);
      final fx = _Fixture(
        containers: [_container('A')],
        tokens: [tokenA],
        api: PiContainerApi(ioClient: io),
      );
      final env = await _plainEnv(fx);

      final failed = await env.sync();

      final a = await env.finalized('A');
      expect(io.posts.map((u) => u.path), ['/container/challenge']);
      expect(a.syncState, SyncState.failed);
      expect(a.initSynced, isFalse);
      expect(a.policies, _originalPolicies);
      // A connection failure has no server error code, so nothing is keyed.
      expect(failed, isEmpty);
      final tokens = (await env.tokens()).tokens;
      expect(tokens, hasLength(1));
      expect((tokens.single as HOTPToken).counter, 7);
      expect(fx.tokenRepo.deletedIds, isEmpty);
    });

    testWidgets('isManually false: an offline failure is silent', (
      tester,
    ) async {
      final fx = _Fixture(containers: [_container('A')]);
      fx.fake.onSync['A'] = (_, _, _) async =>
          throw const SocketException('Network is unreachable');
      final env = await _widgetEnv(tester, fx);

      await env.sync();
      await _pumpDialogs(tester);

      expect((await env.finalized('A')).syncState, SyncState.failed);
      expect(env.status, isNull);
      expect(find.byType(DeleteContainerDialog), findsNothing);
    });

    testWidgets(
      'isManually true: an offline failure is shown as status message',
      (tester) async {
        final fx = _Fixture(containers: [_container('A')]);
        fx.fake.onSync['A'] = (_, _, _) async =>
            throw const SocketException('Network is unreachable');
        final env = await _widgetEnv(tester, fx);

        await env.sync(isManually: true);

        final a = await env.finalized('A');
        expect(a.syncState, SyncState.failed);
        expect(a.policies, _originalPolicies);
        final status = env.status;
        expect(status, isNotNull);
        expect(
          status!.message(AppLocalizationsEn()),
          'Failed to sync container A',
        );
        expect(
          status.details!(AppLocalizationsEn()),
          contains('Network is unreachable'),
        );
      },
    );
  });

  group('finalize: container without client key pair', () {
    // The keys vanish while the finalization request is in flight, so that
    // _applyFinalizationResponse gets a container it can not finalize.
    Future<_Env> setup(WidgetTester? tester, _Fixture fx) async {
      late _Env env;
      fx.fake.onFinalize = (c) async {
        await env.notifier.updateContainer(
          c,
          (TokenContainerUnfinalized u) =>
              u.copyWith(publicClientKey: null, privateClientKey: null),
        );
        return _finalizationResponse;
      };
      env = tester == null ? await _plainEnv(fx) : await _widgetEnv(tester, fx);
      await env.run(() => env.notifier.addContainer(_unfinalized('NEW')));
      return env;
    }

    testWidgets(
      'isManually false: returns null, marks the finalization as failed, '
      'stays unfinalized and shows no status message',
      (tester) async {
        final fx = _Fixture();
        final env = await setup(tester, fx);
        final unfinalized = (await env.containers()).containerOf('NEW')!;

        final result = await env.finalize(unfinalized, isManually: false);

        expect(result, isNull);
        expect(fx.fake.finalizeCalls, 1);
        final state = await env.containers();
        expect(
          state.containerList.whereType<TokenContainerFinalized>(),
          isEmpty,
        );
        final stored = state.containerOf('NEW')! as TokenContainerUnfinalized;
        expect(stored.finalizationState.isFailed, isTrue);
        expect(
          stored.finalizationState,
          FinalizationState.parsingResponseFailed,
        );
        expect(stored.publicClientKey, isNull);
        expect(env.status, isNull);
      },
    );

    testWidgets(
      'isManually true: additionally shows the failure as status message',
      (tester) async {
        final fx = _Fixture();
        final env = await setup(tester, fx);
        final unfinalized = (await env.containers()).containerOf('NEW')!;

        final result = await env.finalize(unfinalized, isManually: true);

        expect(result, isNull);
        final stored =
            (await env.containers()).containerOf('NEW')!
                as TokenContainerUnfinalized;
        expect(stored.finalizationState.isFailed, isTrue);
        final status = env.status;
        expect(status, isNotNull);
        expect(status!.type, StatusMessageType.error);
        expect(
          status.details!(AppLocalizationsEn()),
          contains('missing client key pair'),
        );
      },
    );

    test('a retry after the failure finalizes the container', () async {
      final fx = _Fixture();
      final env = await setup(null, fx);
      final unfinalized = (await env.containers()).containerOf('NEW')!;
      expect(await env.finalize(unfinalized, isManually: false), isNull);

      // The keys no longer vanish.
      fx.fake.onFinalize = null;
      final failedState =
          (await env.containers()).containerOf('NEW')!
              as TokenContainerUnfinalized;
      final result = await env.finalize(failedState, isManually: false);

      expect(result, isNotNull);
      expect(result!.policies, _syncedPolicies);
      final stored = (await env.containers()).containerOf('NEW');
      expect(stored, isA<TokenContainerFinalized>());
      expect(
        (stored! as TokenContainerFinalized).finalizationState,
        FinalizationState.completed,
      );
    });
  });

  group('initSynced', () {
    test('user cancels the initial token assignment (sync returns null): '
        'sync failed, initSynced stays false', () async {
      final fx = _Fixture(containers: [_container('A')]);
      fx.fake.onSync['A'] = (_, _, _) async => null;
      final env = await _plainEnv(fx);

      final failed = await env.sync(isInitSync: true);

      final a = await env.finalized('A');
      expect(fx.fake.syncCalls, [(serial: 'A', isInitSync: true)]);
      expect(a.syncState, SyncState.failed);
      expect(a.initSynced, isFalse);
      expect(a.policies, _originalPolicies);
      expect(failed, isEmpty);
    });

    test('a server error keeps initSynced false', () async {
      final fx = _Fixture(containers: [_container('A')]);
      fx.fake.onSync['A'] = (_, _, _) async =>
          throw _piError(PiServerResultErrorCodes.server);
      final env = await _plainEnv(fx);

      await env.sync(isInitSync: true);

      final a = await env.finalized('A');
      expect(a.syncState, SyncState.failed);
      expect(a.initSynced, isFalse);
    });

    test('an unexpected error keeps initSynced false', () async {
      final fx = _Fixture(containers: [_container('A')]);
      fx.fake.onSync['A'] = (_, _, _) async => throw StateError('unexpected');
      final env = await _plainEnv(fx);

      await env.sync(isInitSync: true);

      final a = await env.finalized('A');
      expect(a.syncState, SyncState.failed);
      expect(a.initSynced, isFalse);
    });

    test('a successful sync sets initSynced', () async {
      final fx = _Fixture(containers: [_container('A')]);
      fx.fake.onSync['A'] = (_, _, _) async => _updates('A');
      final env = await _plainEnv(fx);

      await env.sync(isInitSync: true);

      final a = await env.finalized('A');
      expect(a.syncState, SyncState.completed);
      expect(a.initSynced, isTrue);
    });

    test('a failing sync does not reset an already set initSynced', () async {
      final fx = _Fixture(containers: [_container('A', initSynced: true)]);
      fx.fake.onSync['A'] = (_, _, _) async =>
          throw const SocketException('offline');
      final env = await _plainEnv(fx);

      await env.sync();

      final a = await env.finalized('A');
      expect(a.syncState, SyncState.failed);
      expect(a.initSynced, isTrue);
    });

    test(
      'after a cancelled initial sync the next sync can complete it',
      () async {
        final fx = _Fixture(containers: [_container('A')]);
        var cancel = true;
        fx.fake.onSync['A'] = (_, _, _) async => cancel ? null : _updates('A');
        final env = await _plainEnv(fx);

        await env.sync(isInitSync: true);
        expect((await env.finalized('A')).initSynced, isFalse);

        cancel = false;
        await env.sync(isInitSync: true);

        final a = await env.finalized('A');
        expect(fx.fake.syncCalls, hasLength(2));
        expect(a.syncState, SyncState.completed);
        expect(a.initSynced, isTrue);
      },
    );
  });

  group('tokens that move between containers', () {
    for (final order in [
      ['A', 'B'],
      ['B', 'A'],
    ]) {
      test(
        'is not deleted when container A deletes it and container B updates it '
        '(containers in order ${order.join(', ')})',
        () async {
          final tokenX = _hotp('idX', 'SERIAL-X', containerSerial: 'A');
          final fx = _Fixture(
            containers: [for (final s in order) _container(s)],
            tokens: [tokenX],
          );
          fx.fake.onSync['A'] = (_, _, _) async =>
              _updates('A', deletedTokens: [tokenX]);
          fx.fake.onSync['B'] = (_, _, _) async => _updates(
            'B',
            updatedTokens: [
              _hotp('idX', 'SERIAL-X', containerSerial: 'B', counter: 3),
            ],
          );
          final env = await _plainEnv(fx);

          await env.sync();

          final tokens = (await env.tokens()).tokens;
          expect(tokens, hasLength(1));
          final x = tokens.single as HOTPToken;
          expect(x.serial, 'SERIAL-X');
          expect(x.containerSerial, 'B');
          expect(x.counter, 3);
          expect(fx.tokenRepo.deletedIds, isEmpty);
          expect(fx.tokenRepo.tokens.keys, ['idX']);
        },
      );
    }

    test(
      'still exists exactly once when container B reports it as new token',
      () async {
        final tokenX = _hotp('idX', 'SERIAL-X', containerSerial: 'A');
        final fx = _Fixture(
          containers: [_container('A'), _container('B')],
          tokens: [tokenX],
        );
        fx.fake.onSync['A'] = (_, _, _) async =>
            _updates('A', deletedTokens: [tokenX]);
        fx.fake.onSync['B'] = (_, _, _) async => _updates(
          'B',
          newTokens: [_hotp('idXNew', 'SERIAL-X', containerSerial: 'B')],
        );
        final env = await _plainEnv(fx);

        await env.sync();

        final tokens = (await env.tokens()).tokens;
        expect(tokens.map((t) => t.serial), ['SERIAL-X']);
        expect(tokens.single.containerSerial, 'B');
        expect(fx.tokenRepo.tokens.values.map((t) => t.serial), ['SERIAL-X']);
      },
    );

    test('is deleted when only container A reports it as deleted', () async {
      final tokenX = _hotp('idX', 'SERIAL-X', containerSerial: 'A');
      final tokenY = _hotp('idY', 'SERIAL-Y', containerSerial: 'B');
      final fx = _Fixture(
        containers: [_container('A'), _container('B')],
        tokens: [tokenX, tokenY],
      );
      fx.fake.onSync['A'] = (_, _, _) async =>
          _updates('A', deletedTokens: [tokenX]);
      fx.fake.onSync['B'] = (_, _, _) async =>
          _updates('B', updatedTokens: [tokenY]);
      final env = await _plainEnv(fx);

      await env.sync();

      final tokens = (await env.tokens()).tokens;
      expect(tokens.map((t) => t.serial), ['SERIAL-Y']);
      expect(fx.tokenRepo.deletedIds, ['idX']);
    });

    test(
      'is not deleted when the container that deletes it fails to sync',
      () async {
        final tokenX = _hotp('idX', 'SERIAL-X', containerSerial: 'A');
        final fx = _Fixture(containers: [_container('A')], tokens: [tokenX]);
        fx.fake.onSync['A'] = (_, _, _) async =>
            throw const SocketException('offline');
        final env = await _plainEnv(fx);

        await env.sync();

        expect((await env.tokens()).tokens.map((t) => t.serial), ['SERIAL-X']);
        expect(fx.tokenRepo.deletedIds, isEmpty);
      },
    );
  });
}
