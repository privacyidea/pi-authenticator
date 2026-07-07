import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/api/interfaces/container_api.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_value.dart';
import 'package:privacyidea_authenticator/model/container_policies.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/enums/rollout_state.dart';
import 'package:privacyidea_authenticator/model/enums/sync_state.dart';
import 'package:privacyidea_authenticator/model/exception_errors/error_codes.dart';
import 'package:privacyidea_authenticator/model/exception_errors/pi_server_result_error.dart';
import 'package:privacyidea_authenticator/model/exception_errors/response_error.dart';
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
      await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
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
      await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
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
        await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
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
        await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
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
}
