/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/interfaces/repo/push_request_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

import '../../tests_app_wrapper.mocks.dart';
import '../model/fake_push_server.dart';

void main() {
  group('PushProvider.pollForChallenge', () {
    late MockPrivacyideaIOClient mockIOClient;
    late MockRsaUtils mockRsaUtils;
    late PushToken token;

    setUp(() {
      PushProvider.instance = null;
      mockIOClient = MockPrivacyideaIOClient();
      mockRsaUtils = MockRsaUtils();
      token = PushToken(
        serial: 'PIPU0001',
        id: 'id',
        isRolledOut: true,
        url: Uri.parse('https://example.com/ttype/push'),
      );

      when(
        mockRsaUtils.trySignWithToken(any, any),
      ).thenAnswer((_) async => 'signature');
      when(
        mockIOClient.doGet(
          url: anyNamed('url'),
          parameters: anyNamed('parameters'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer(
        (_) async => Response('{"result": {"status": true, "value": []}}', 200),
      );
    });

    Map<String, String?> capturedParameters() =>
        verify(
              mockIOClient.doGet(
                url: anyNamed('url'),
                parameters: captureAnyNamed('parameters'),
                sslVerify: anyNamed('sslVerify'),
              ),
            ).captured.last
            as Map<String, String?>;

    test(
      'sends the parameters the server rebuilds the signature from',
      () async {
        await PushProvider(
          ioClient: mockIOClient,
          rsaUtils: mockRsaUtils,
        ).pollForChallenge(token);

        final parameters = capturedParameters();
        expect(parameters['serial'], token.serial);
        expect(parameters['timestamp'], isNotNull);
        expect(parameters['signature'], 'signature');
      },
    );

    // privacyidea#5618 phase 2: "Refresh the stored set from the already-signed
    // poll / fbtoken-update channel so it stays current after app upgrades - no
    // new endpoint."
    test('reports the app capabilities along with the poll', () async {
      await PushProvider(
        ioClient: mockIOClient,
        rsaUtils: mockRsaUtils,
      ).pollForChallenge(token);

      expect(capturedParameters()['capabilities'], '["decline_reason"]');
    });

    test('does not sign the reported capabilities', () async {
      await PushProvider(
        ioClient: mockIOClient,
        rsaUtils: mockRsaUtils,
      ).pollForChallenge(token);

      // A server that does not know the parameter rebuilds
      // '{serial}|{timestamp}' and has to arrive at the same signature.
      final signed =
          verify(mockRsaUtils.trySignWithToken(any, captureAny)).captured.last
              as String;
      expect(signed, '${token.serial}|${capturedParameters()['timestamp']}');
      expect(signed, isNot(contains('decline_reason')));
    });
  });

  _testPushProviderIncoming();
}

/// A push request repository that keeps its state in memory.
class _MemoryPushRequestRepository implements PushRequestRepository {
  PushRequestState state = PushRequestState.empty();
  int saveCount = 0;

  @override
  Future<PushRequestState> loadState() async => state;

  @override
  Future<void> saveState(PushRequestState pushRequestState) async {
    saveCount++;
    state = pushRequestState;
  }

  @override
  Future<void> clearState() async => state = PushRequestState.empty();

  @override
  Future<PushRequestState> addRequest(
    PushRequest pushRequest, {
    PushRequestState? state,
  }) => throw UnimplementedError();

  @override
  Future<PushRequestState> removeRequest(
    PushRequest pushRequest, {
    PushRequestState? state,
  }) => throw UnimplementedError();
}

/// A challenge of the code to phone type, which [FakePushServer] cannot build.
/// The sign string is `{nonce}|{url}|{serial}|{question}|{title}|{sslverify}|{display_code}`.
Map<String, dynamic> _codeToPhoneChallenge(
  FakePushServer server, {
  String nonce = 'code-to-phone-nonce',
  String displayCode = '123456',
}) {
  const question = 'Enter the code';
  const title = 'Login';
  final signed =
      '$nonce|${FakePushServer.url}|${server.serial}|$question|$title|1|$displayCode';
  return {
    'title': title,
    'question': question,
    'url': FakePushServer.url,
    'nonce': nonce,
    'sslverify': '1',
    'serial': server.serial,
    'display_code': displayCode,
    'signature': server.rsaUtils.createBase32Signature(
      server.keyPair.privateKey,
      utf8.encode(signed),
    ),
  };
}

/// Incoming push requests of the [PushProvider]: what reaches the subscribers
/// (and what is stored) when a challenge arrives by polling, by a foreground
/// firebase message or by a background firebase message.
///
/// The challenges are built by [FakePushServer], so the signatures are real.
/// The io client is mocked, the token and push request storage is real
/// (in-memory secure storage) where the code under test reaches it through
/// static repositories.
void _testPushProviderIncoming() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PushProvider incoming push requests', () {
    late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> serverKeys;
    late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> foreignKeys;
    late FakePushServer server;
    late PushToken token;

    late MockPrivacyideaIOClient ioClient;
    late MockTokenRepository tokenRepo;
    late MockFirebaseUtils firebaseUtils;
    late ProviderContainer container;
    late PushProvider provider;
    late List<PushRequest> delivered;
    late Map<String, String> secureStore;

    // Generating the key pairs is by far the slowest part, so it happens once.
    setUpAll(() {
      serverKeys = generateShortRsaKeyPair();
      foreignKeys = generateShortRsaKeyPair();
      server = FakePushServer.advertising(keyPair: serverKeys);
      token = enrollAgainst(server).copyWith(isRolledOut: true);
    });

    void useTokensInRepo(List<PushToken> tokens) {
      when(tokenRepo.loadTokens()).thenAnswer((_) async => tokens);
      for (final t in tokens) {
        secureStore['${SECURE_REPO_PREFIX_TOKEN}_${t.id}'] = jsonEncode(
          t.toJson(),
        );
      }
    }

    void answerPollWith(List<Object?> challenges) {
      when(
        ioClient.doGet(
          url: anyNamed('url'),
          parameters: anyNamed('parameters'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'result': {'status': true, 'value': challenges},
          }),
          200,
        ),
      );
    }

    void answerPollWithResponse(Response response) {
      when(
        ioClient.doGet(
          url: anyNamed('url'),
          parameters: anyNamed('parameters'),
          sslVerify: anyNamed('sslVerify'),
        ),
      ).thenAnswer((_) async => response);
    }

    /// Polls for [token] and lets the not awaited handling of the received
    /// challenges finish.
    Future<void> poll({PushToken? polledToken, bool isManually = true}) async {
      await provider.pollForChallenge(
        polledToken ?? token,
        isManually: isManually,
      );
      await pumpEventQueue();
    }

    RemoteMessage messageOf(Map<String, dynamic> data) => RemoteMessage(
      data: data,
      // A message that carries a notification is shown by the system, so the
      // background handler does not try to show one through the plugin.
      notification: const RemoteNotification(title: 'Login'),
    );

    Future<
      ({
        Future<void> Function(RemoteMessage) foreground,
        Future<void> Function(RemoteMessage) background,
      })
    >
    captureFirebaseHandlers() async {
      await provider.initFirebase();
      final captured = verify(
        firebaseUtils.setupHandler(
          foregroundHandler: captureAnyNamed('foregroundHandler'),
          backgroundHandler: captureAnyNamed('backgroundHandler'),
          updateFirebaseToken: anyNamed('updateFirebaseToken'),
        ),
      ).captured;
      return (
        foreground: captured[0] as Future<void> Function(RemoteMessage),
        background: captured[1] as Future<void> Function(RemoteMessage),
      );
    }

    StatusMessage? currentStatus() => container.read(statusProvider).current;

    /// Registers a test whose body runs in real async inside a widget tree whose
    /// ref is the [globalRef], the way the app reads providers outside of
    /// widgets. [skip] marks a confirmed bug of the code under test.
    void incomingTest(
      String description,
      Future<void> Function() body, {
      String? skip,
    }) {
      void register(String name) => testWidgets(name, (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: Consumer(
              builder: (context, ref, _) {
                globalRef = ref;
                return const SizedBox();
              },
            ),
          ),
        );
        await tester.runAsync(body);
      });
      if (skip == null) {
        register(description);
      } else {
        group(description, () => register('expected behaviour'), skip: skip);
      }
    }

    setUp(() {
      PushProvider.instance = null;
      ioClient = MockPrivacyideaIOClient();
      tokenRepo = MockTokenRepository();
      firebaseUtils = MockFirebaseUtils();
      delivered = [];
      secureStore = {};
      FlutterSecureStorage.setMockInitialValues(secureStore);

      final settingsRepo = MockSettingsRepository();
      when(settingsRepo.loadSettings()).thenAnswer((_) async => SettingsState());
      container = ProviderContainer(
        overrides: [
          tokenProvider.overrideWith(
            () => TokenNotifier(repoOverride: tokenRepo),
          ),
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: settingsRepo),
          ),
        ],
      );

      provider = PushProvider(
        ioClient: ioClient,
        rsaUtils: const RsaUtils(),
        firebaseUtils: firebaseUtils,
      )..subscribe(delivered.add);
      useTokensInRepo([token]);
      answerPollWith([]);
    });

    tearDown(() {
      globalRef = null;
      container.dispose();
      PushProvider.instance = null;
    });

    group('polling delivers valid challenges', () {
      incomingTest(
        'a valid challenge reaches every subscriber exactly once',
        () async {
          final second = <PushRequest>[];
          provider.subscribe(second.add);
          final challenge = server.createChallenge();
          answerPollWith([challenge]);

          await poll();

          expect(delivered.map((r) => r.nonce), [challenge['nonce']]);
          expect(second.map((r) => r.nonce), [challenge['nonce']]);
        },
      );

      incomingTest(
        'the delivered request carries the data of the challenge',
        () async {
          final challenge = server.createChallenge(
            title: 'Bank login',
            question: 'Is this you?',
            sslVerify: false,
          );
          answerPollWith([challenge]);

          await poll();

          final request = delivered.single;
          expect(request.title, 'Bank login');
          expect(request.question, 'Is this you?');
          expect(request.serial, token.serial);
          expect(request.uri, Uri.parse(FakePushServer.url));
          expect(request.sslVerify, isFalse);
          expect(request.accepted, isNull);
          // The capabilities the server advertised survive verification.
          expect(
            request.capabilitiesOf(token).supports('decline_reason'),
            isTrue,
          );
        },
      );

      incomingTest(
        'an unsubscribed subscriber is not notified any more',
        () async {
          final second = <PushRequest>[];
          provider.subscribe(second.add);
          provider.unsubscribe(second.add);
          answerPollWith([server.createChallenge()]);

          await poll();

          expect(delivered, hasLength(1));
          expect(second, isEmpty);
        },
      );

      incomingTest(
        'no subscriber is called for an empty poll response',
        () async {
          answerPollWith([]);

          await poll();

          expect(delivered, isEmpty);
        },
      );

      incomingTest(
        'challenges of mixed types arrive with their own type',
        () async {
          final defaultChallenge = server.createChallenge();
          final choiceChallenge = server.createChallenge(
            requirePresence: ['1', '2', '3'],
          );
          final codeChallenge = _codeToPhoneChallenge(server);
          answerPollWith([defaultChallenge, choiceChallenge, codeChallenge]);

          await poll();

          final typeByNonce = {for (final r in delivered) r.nonce: r.runtimeType};
          expect(typeByNonce, {
            defaultChallenge['nonce']: PushDefaultRequest,
            choiceChallenge['nonce']: PushChoiceRequest,
            codeChallenge['nonce']: PushCodeToPhoneRequest,
          });
          final choice = delivered.whereType<PushChoiceRequest>().single;
          expect(choice.possibleAnswers, ['1', '2', '3']);
          final code = delivered.whereType<PushCodeToPhoneRequest>().single;
          expect(code.displayCode, '123456');
        },
      );

      incomingTest(
        'a mixed list delivers the valid ones and drops the forged one',
        () async {
          final valid1 = server.createChallenge();
          final forged = FakePushServer.advertising(
            keyPair: foreignKeys,
          ).createChallenge();
          final valid2 = server.createChallenge(requirePresence: ['a', 'b']);
          answerPollWith([valid1, forged, valid2]);

          await poll();

          expect(delivered.map((r) => r.nonce).toSet(), {
            valid1['nonce'],
            valid2['nonce'],
          });
        },
      );
    });

    group('polling rejects challenges that cannot be trusted', () {
      Map<String, dynamic> changed(String key, Object? value) => {
        ...server.createChallenge(),
        key: value,
      };

      // The challenges are built lazily, the server exists only once the tests
      // run.
      final rejected = <String, Map<String, dynamic> Function()>{
        'a challenge signed by another server key': () =>
            FakePushServer.advertising(keyPair: foreignKeys).createChallenge(),
        'a challenge whose question was changed': () =>
            changed('question', 'Send me all your money?'),
        'a challenge whose title was changed': () =>
            changed('title', 'Something else'),
        'a challenge whose sslverify was changed': () =>
            changed('sslverify', '0'),
        'a challenge for another url': () =>
            changed('url', 'https://evil.example.com/ttype/push'),
        'a challenge whose signature is no base32': () =>
            changed('signature', '!!!not base32!!!'),
        'a challenge with an empty signature': () => changed('signature', ''),
        'a challenge with a far too long signature': () =>
            changed('signature', 'A' * 2000),
        'a challenge whose advertised capabilities are signed for another nonce':
            () => server.createChallenge(capabilitiesNonce: 'another-nonce'),
        'a challenge whose advertised capabilities were extended': () => {
          ...server.createChallenge(),
          'capabilities': jsonEncode({
            'decline_reason': true,
            'something_new': true,
          }),
        },
      };

      for (final entry in rejected.entries) {
        incomingTest('rejects ${entry.key}', () async {
          answerPollWith([entry.value()]);

          await poll();

          expect(delivered, isEmpty);
        });
      }

      // Not a bug: capabilities are optional. Ones the app cannot read are
      // dropped (the message then behaves like one of a server that advertised
      // nothing) while the main signature still has to verify.
      incomingTest(
        'delivers a challenge whose capabilities lack their signature as one without capabilities',
        () async {
          final challenge = server.createChallenge()
            ..remove('capabilities_signature');
          answerPollWith([challenge]);

          await poll();

          final request = delivered.single;
          expect(request.nonce, challenge['nonce']);
          expect(request.signedCapabilities, isNull);
          expect(
            request.capabilitiesOf(token).supports('decline_reason'),
            isFalse,
          );
        },
      );

      incomingTest('rejects a challenge for a serial no token has', () async {
        final unknown = FakePushServer.advertising(
          serial: 'UNKNOWN0001',
          keyPair: serverKeys,
        );
        answerPollWith([unknown.createChallenge()]);

        await poll();

        expect(delivered, isEmpty);
      });

      incomingTest(
        'rejects a challenge for a token that is not rolled out',
        () async {
          final notRolledOut = token.copyWith(
            isRolledOut: false,
            rolloutState: PushTokenRollOutState.sendRSAPublicKey,
          );
          useTokensInRepo([notRolledOut]);
          answerPollWith([server.createChallenge()]);

          // The token that is polled is rolled out, the one the app stores is not.
          await poll();

          expect(delivered, isEmpty);
        },
      );

      incomingTest(
        'rejects a challenge that belongs to another token than the polled one',
        () async {
          // Another token the app has, rolled out against another server.
          final otherServer = FakePushServer.advertising(
            serial: 'PIPU0002',
            keyPair: foreignKeys,
          );
          final otherToken = enrollAgainst(
            otherServer,
          ).copyWith(isRolledOut: true);
          useTokensInRepo([token, otherToken]);
          // The server of [token] answers with a challenge for [otherToken]'s
          // serial. It cannot sign for it, so it must not get through.
          final challengeForOther = FakePushServer.advertising(
            serial: 'PIPU0002',
            keyPair: serverKeys,
          ).createChallenge();
          answerPollWith([challengeForOther]);

          await poll();

          expect(delivered, isEmpty);
        },
      );
    });

    group('one malformed challenge among valid ones', () {
      // SUSPECTED BUG, confirmed: _getAndValidateDataFromResponse validates the
      // whole list up front and rethrows on the first malformed entry, so the
      // caller drops every challenge of the response, valid ones included.
      // privacyIDEA answers a poll with all open challenges of the token, so one
      // challenge the app cannot parse hides every other open login until the
      // malformed one is gone on the server.
      incomingTest(
        'delivers the valid challenges when one misses a required field',
        () async {
          final valid1 = server.createChallenge();
          final malformed = {...server.createChallenge()}..remove('nonce');
          final valid2 = server.createChallenge();
          answerPollWith([valid1, malformed, valid2]);

          await poll();

          expect(delivered.map((r) => r.nonce).toSet(), {
            valid1['nonce'],
            valid2['nonce'],
          });
        },
        skip:
            'BUG: push_provider.dart:159-181 one malformed challenge discards all valid ones of the poll response',
      );

      incomingTest(
        'delivers the valid challenges when one entry is not even an object',
        () async {
          final valid = server.createChallenge();
          answerPollWith([valid, 'garbage', 42]);

          await poll();

          expect(delivered.map((r) => r.nonce), [valid['nonce']]);
        },
        skip:
            'BUG: push_provider.dart:159-181 one malformed challenge discards all valid ones of the poll response',
      );

      incomingTest(
        'delivers the valid challenges when one has a field of the wrong type',
        () async {
          final valid = server.createChallenge();
          final wrongType = {...server.createChallenge(), 'sslverify': 1};
          answerPollWith([wrongType, valid]);

          await poll();

          expect(delivered.map((r) => r.nonce), [valid['nonce']]);
        },
        skip:
            'BUG: push_provider.dart:159-181 one malformed challenge discards all valid ones of the poll response',
      );

      // Characterization of what happens today, so a fix shows up as a change.
      incomingTest(
        'today a malformed challenge drops the whole response',
        () async {
          final valid = server.createChallenge();
          final malformed = {...server.createChallenge()}..remove('nonce');
          answerPollWith([valid, malformed]);

          await poll();

          expect(delivered, isEmpty);
        },
      );

      incomingTest(
        'a manual poll tells the user about the unreadable response',
        () async {
          answerPollWith([
            {...server.createChallenge()}..remove('nonce'),
          ]);

          await poll();

          final l = AppLocalizationsEn();
          expect(
            currentStatus()?.message(l),
            l.errorWhenPullingChallenges(token.serial),
          );
          expect(currentStatus()?.details?.call(l), l.pushRequestParseError);
        },
      );

      incomingTest(
        'an automatic poll stays silent about the unreadable response',
        () async {
          answerPollWith([
            {...server.createChallenge()}..remove('nonce'),
          ]);

          await poll(isManually: false);

          expect(currentStatus(), isNull);
        },
      );
    });

    group('polling failures deliver nothing', () {
      incomingTest('a response that is no json', () async {
        answerPollWithResponse(Response('<html>oops</html>', 200));

        await poll();

        expect(delivered, isEmpty);
      });

      incomingTest('a response without result value', () async {
        answerPollWithResponse(
          Response(
            jsonEncode({
              'result': {'status': true},
            }),
            200,
          ),
        );

        await poll();

        expect(delivered, isEmpty);
      });

      incomingTest(
        'a 403 with a server message shows the message when manual',
        () async {
          answerPollWithResponse(
            Response(
              jsonEncode({
                'result': {
                  'status': false,
                  'error': {'code': 403, 'message': 'Not allowed'},
                },
              }),
              403,
            ),
          );

          await poll();

          final l = AppLocalizationsEn();
          expect(delivered, isEmpty);
          expect(currentStatus()?.message(l), l.pollingFailedFor(token.serial));
          expect(currentStatus()?.details?.call(l), 'Not allowed');
        },
      );

      incomingTest(
        'a 500 without message shows the status code when manual',
        () async {
          answerPollWithResponse(Response('', 500));

          await poll();

          final l = AppLocalizationsEn();
          expect(delivered, isEmpty);
          expect(currentStatus()?.details?.call(l), l.statusCode(500));
        },
      );

      incomingTest(
        'an error status stays silent when polling automatically',
        () async {
          answerPollWithResponse(Response('', 500));

          await poll(isManually: false);

          expect(delivered, isEmpty);
          expect(currentStatus(), isNull);
        },
      );

      incomingTest(
        'an exception of the io client delivers nothing and tells a manual poll',
        () async {
          when(
            ioClient.doGet(
              url: anyNamed('url'),
              parameters: anyNamed('parameters'),
              sslVerify: anyNamed('sslVerify'),
            ),
          ).thenThrow(StateError('network is gone'));

          await poll();

          final l = AppLocalizationsEn();
          expect(delivered, isEmpty);
          expect(
            currentStatus()?.message(l),
            l.errorWhenPullingChallenges(token.serial),
          );
          expect(currentStatus()?.details?.call(l), l.couldNotConnectToServer);
        },
      );
    });

    group('with the push request notifier subscribed', () {
      late _MemoryPushRequestRepository repo;

      Future<PushRequestState> stateOfNotifier() async {
        final prProvider = pushRequestProviderOf(
          rsaUtils: const RsaUtils(),
          ioClient: ioClient,
          pushProvider: provider,
          pushRepo: repo,
        );
        return container.read(prProvider.future);
      }

      PushRequestNotifierProvider notifierProvider() => pushRequestProviderOf(
        rsaUtils: const RsaUtils(),
        ioClient: ioClient,
        pushProvider: provider,
        pushRepo: repo,
      );

      setUp(() {
        repo = _MemoryPushRequestRepository();
      });

      incomingTest(
        'a valid challenge is stored once even if it is polled twice',
        () async {
          await stateOfNotifier();
          final challenge = server.createChallenge();
          answerPollWith([challenge]);

          await poll();
          final afterFirst = container.read(notifierProvider()).value!;
          final savesAfterFirst = repo.saveCount;
          await poll();
          final afterSecond = container.read(notifierProvider()).value!;

          expect(afterFirst.pushRequests.map((r) => r.nonce), [
            challenge['nonce'],
          ]);
          expect(afterSecond.pushRequests.map((r) => r.nonce), [
            challenge['nonce'],
          ]);
          expect(repo.saveCount, savesAfterFirst);
          expect(repo.state.pushRequests, hasLength(1));
        },
      );

      incomingTest(
        'the same challenge twice in one response is stored once',
        () async {
          await stateOfNotifier();
          final challenge = server.createChallenge();
          answerPollWith([challenge, challenge]);

          await poll();

          expect(repo.state.pushRequests.map((r) => r.nonce), [
            challenge['nonce'],
          ]);
        },
      );

      incomingTest('a rejected challenge stores nothing', () async {
        await stateOfNotifier();
        final notRolledOut = token.copyWith(
          isRolledOut: false,
          rolloutState: PushTokenRollOutState.sendRSAPublicKey,
        );
        useTokensInRepo([notRolledOut]);
        answerPollWith([
          server.createChallenge(),
          FakePushServer.advertising(keyPair: foreignKeys).createChallenge(),
        ]);

        await poll();

        expect(repo.state.pushRequests, isEmpty);
        expect(repo.saveCount, 0);
      });

      incomingTest(
        'a forged challenge next to a valid one stores only the valid one',
        () async {
          await stateOfNotifier();
          final valid = server.createChallenge();
          answerPollWith([
            FakePushServer.advertising(keyPair: foreignKeys).createChallenge(),
            valid,
          ]);

          await poll();

          expect(repo.state.pushRequests.map((r) => r.nonce), [valid['nonce']]);
        },
      );
    });

    group('foreground firebase message', () {
      incomingTest('a valid message is delivered once', () async {
        final handlers = await captureFirebaseHandlers();
        final challenge = server.createChallenge();

        await handlers.foreground(messageOf(challenge));
        await pumpEventQueue();

        expect(delivered.map((r) => r.nonce), [challenge['nonce']]);
      });

      incomingTest(
        'a message for a token that is not rolled out is rejected',
        () async {
          useTokensInRepo([token.copyWith(isRolledOut: false)]);
          final handlers = await captureFirebaseHandlers();

          await handlers.foreground(messageOf(server.createChallenge()));
          await pumpEventQueue();

          expect(delivered, isEmpty);
        },
      );

      incomingTest('a message for an unknown serial is rejected', () async {
        final handlers = await captureFirebaseHandlers();
        final unknown = FakePushServer.advertising(
          serial: 'UNKNOWN0001',
          keyPair: serverKeys,
        );

        await handlers.foreground(messageOf(unknown.createChallenge()));
        await pumpEventQueue();

        expect(delivered, isEmpty);
      });

      incomingTest('a message with an invalid signature is rejected', () async {
        final handlers = await captureFirebaseHandlers();
        final forged = FakePushServer.advertising(
          keyPair: foreignKeys,
        ).createChallenge();

        await handlers.foreground(messageOf(forged));
        await pumpEventQueue();

        expect(delivered, isEmpty);
      });

      group('with a mocked connectivity', () {
        const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');

        setUp(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (call) async => ['wifi']);
        });

        tearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);
        });

        incomingTest(
          'data that is not a push request makes the app poll instead',
          () async {
            final handlers = await captureFirebaseHandlers();
            final challenge = server.createChallenge();
            answerPollWith([challenge]);

            await handlers.foreground(
              const RemoteMessage(data: {'unrelated': 'message'}),
            );
            await pumpEventQueue();

            verify(
              ioClient.doGet(
                url: anyNamed('url'),
                parameters: anyNamed('parameters'),
                sslVerify: anyNamed('sslVerify'),
              ),
            ).called(1);
            expect(delivered.map((r) => r.nonce), [challenge['nonce']]);
          },
        );
      });

      // The handler catches errors of the handling to log them. It returns the
      // future of the handling without awaiting it inside the try block, so the
      // catch block never sees an asynchronous error and it reaches the caller
      // (firebase) as an unhandled error instead.
      incomingTest(
        'an error while handling the message is logged and does not reach the caller',
        () async {
          when(tokenRepo.loadTokens()).thenThrow(StateError('storage broke'));
          final handlers = await captureFirebaseHandlers();

          await expectLater(
            handlers.foreground(messageOf(server.createChallenge())),
            completes,
          );
        },
        skip:
            'BUG: push_provider.dart:199 returns the future inside try without await, so the catch at :200 never handles async errors',
      );
    });

    group('background firebase message', () {
      PushRequestState? storedState() {
        final json = secureStore['${SECURE_REPO_PREFIX_PUSH_REQUEST}_state'];
        if (json == null) return null;
        return PushRequestState.fromJson(jsonDecode(json));
      }

      incomingTest('a valid message is stored', () async {
        final handlers = await captureFirebaseHandlers();
        final challenge = server.createChallenge();

        await handlers.background(messageOf(challenge));

        expect(storedState()!.pushRequests.map((r) => r.nonce), [
          challenge['nonce'],
        ]);
      });

      incomingTest(
        'the stored request keeps what the server advertised',
        () async {
          final handlers = await captureFirebaseHandlers();

          await handlers.background(messageOf(server.createChallenge()));

          final stored = storedState()!.pushRequests.single;
          expect(stored.capabilitiesOf(token).supports('decline_reason'), isTrue);
        },
      );

      incomingTest('the same message twice is stored once', () async {
        final handlers = await captureFirebaseHandlers();
        final message = messageOf(server.createChallenge());

        await handlers.background(message);
        await handlers.background(message);

        expect(storedState()!.pushRequests, hasLength(1));
      });

      incomingTest(
        'a message for a token that is not rolled out is rejected',
        () async {
          secureStore.clear();
          useTokensInRepo([token.copyWith(isRolledOut: false)]);
          final handlers = await captureFirebaseHandlers();

          await handlers.background(messageOf(server.createChallenge()));

          expect(storedState(), isNull);
        },
      );

      incomingTest('a message for an unknown serial is rejected', () async {
        final handlers = await captureFirebaseHandlers();
        final unknown = FakePushServer.advertising(
          serial: 'UNKNOWN0001',
          keyPair: serverKeys,
        );

        await handlers.background(messageOf(unknown.createChallenge()));

        expect(storedState(), isNull);
      });

      incomingTest('a message with an invalid signature is rejected', () async {
        final handlers = await captureFirebaseHandlers();
        final forged = FakePushServer.advertising(
          keyPair: foreignKeys,
        ).createChallenge();

        await handlers.background(messageOf(forged));

        expect(storedState(), isNull);
      });

      incomingTest('a message with a tampered question is rejected', () async {
        final handlers = await captureFirebaseHandlers();

        await handlers.background(
          messageOf({...server.createChallenge(), 'question': 'Pay everything?'}),
        );

        expect(storedState(), isNull);
      });

      incomingTest(
        'a message that is no push request is ignored without error',
        () async {
          final handlers = await captureFirebaseHandlers();

          await expectLater(
            handlers.background(
              const RemoteMessage(data: {'unrelated': 'message'}),
            ),
            completes,
          );

          expect(storedState(), isNull);
        },
      );
    });
  });
}
