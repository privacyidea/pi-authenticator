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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/rollout_state.dart';
import 'package:privacyidea_authenticator/model/enums/sync_state.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/utils/app_info_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/hotp_token_widgets/hotp_token_widget_tile.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/container_rollout_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/container_send_device_infos_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/container_show_url_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/enter_passphrase_dialog.dart';

import 'harness/app_harness.dart';
import 'harness/fake_container_server.dart';
import 'harness/reference_otp.dart';

const _doorSecret = [
  0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, //
  0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30,
];
const _gateSecret = [
  0x73, 0x65, 0x63, 0x72, 0x65, 0x74, 0x2d, 0x66, 0x6f, 0x72, //
  0x2d, 0x74, 0x68, 0x65, 0x2d, 0x67, 0x61, 0x74, 0x65, 0x21,
];

FakeContainerToken _door({int counter = 1, String? label}) =>
    FakeContainerToken.hotp(
      serial: 'OATH0001D00R',
      secret: _doorSecret,
      counter: counter,
      label: label,
    );

FakeContainerToken _gate() =>
    FakeContainerToken.totp(serial: 'TOTP0002G4TE', secret: _gateSecret);

Finder _inDialog(Type dialog, Finder finder) =>
    find.descendant(of: find.byType(dialog), matching: finder);

Future<void> _confirmUrl(AppHarness app) async {
  await app.pumpUntilFound(find.byType(ContainerShowContainerUrlDialog));
  await app.tap(_inDialog(ContainerShowContainerUrlDialog, find.text(l10n.ok)));
}

Future<void> _answerDeviceInfos(AppHarness app, {required bool send}) async {
  await app.pumpUntilFound(find.byType(ContainerSendDeviceInfosDialog));
  await app.tap(
    _inDialog(
      ContainerSendDeviceInfosDialog,
      find.text(send ? l10n.yes : l10n.no),
    ),
  );
}

Future<void> _enterPassphrase(AppHarness app, String passphrase) async {
  await app.pumpUntilFound(find.byType(EnterPassphraseDialog));
  await app.tester.enterText(
    _inDialog(EnterPassphraseDialog, find.byType(TextFormField)),
    passphrase,
  );
  await app.tester.pump();
  await app.tap(_inDialog(EnterPassphraseDialog, find.text(l10n.ok)));
}

Future<void> _dismissSyncResult(AppHarness app) async {
  await app.pumpUntilFound(find.byType(ContainerSyncResultDialog));
  await app.tap(_inDialog(ContainerSyncResultDialog, find.text(l10n.ok)));
  await app.pumpUntilGone(find.byType(ContainerSyncResultDialog));
}

Future<void> _register(AppHarness app, FakeContainerServer server) async {
  app.platform.appLinks.open(server.registrationLink());
  await _confirmUrl(app);
  await _answerDeviceInfos(app, send: false);
  await _dismissSyncResult(app);
}

List<TokenContainer> _containers(AppHarness app) =>
    app.container.read(tokenContainerProvider).requireValue.containerList;

Map<String, TokenContainer> _storedContainers(AppHarness app) => {
  for (final entry in app.storage.secure.entries)
    if (entry.key.startsWith('${SECURE_REPO_PREFIX_TOKEN_CONTAINER}_'))
      entry.key.substring(SECURE_REPO_PREFIX_TOKEN_CONTAINER.length + 1):
          TokenContainer.fromJson(jsonDecode(entry.value)),
};

Iterable<String> _paths(AppHarness app) =>
    app.backend.requests.map((r) => '${r.method} ${r.url.path}');

final _otpText = RegExp(r'^\d{3} \d{3}$');

String _shownCode(Finder tile) {
  final texts = find
      .descendant(
        of: tile,
        matching: find.byWidgetPredicate(
          (w) => w is Text && _otpText.hasMatch(w.data ?? ''),
        ),
      )
      .evaluate()
      .map((e) => (e.widget as Text).data!)
      .toSet();
  expect(texts, hasLength(1), reason: 'the tile shows exactly one code');
  return texts.single.replaceAll(' ', '');
}

Finder _tileOf(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byType(HOTPTokenWidgetTile),
);

void main() {
  appTest('a container link registers the container against the server and the '
      'first sync delivers its tokens, which survive a restart', (app) async {
    final server = FakeContainerServer(
      app.backend,
      policies: const FakeContainerPolicies(
        rolloverAllowed: true,
        disabledUnregister: true,
      ),
      tokens: [_door(), _gate()],
    );
    await app.start();

    app.platform.appLinks.open(server.registrationLink());
    await app.pumpUntilFound(find.byType(ContainerShowContainerUrlDialog));
    expect(
      find.textContaining(FakeContainerServer.baseUrl.toString()),
      findsOneWidget,
    );
    expect(
      app.backend.requests,
      isEmpty,
      reason: 'nothing is sent before the user confirmed the server url',
    );
    await app.tap(
      _inDialog(ContainerShowContainerUrlDialog, find.text(l10n.ok)),
    );
    await _answerDeviceInfos(app, send: true);

    await app.pumpUntilFound(find.byType(ContainerSyncResultDialog));
    expect(
      find.text(l10n.containerSyncDialogTitle(server.serial)),
      findsOneWidget,
    );
    expect(find.text(' 1x HOTP'), findsOneWidget);
    expect(find.text(' 1x TOTP'), findsOneWidget);
    await _dismissSyncResult(app);

    expect(_paths(app), [
      'POST /container/register/finalize',
      'POST /container/challenge',
      'POST /container/synchronize',
    ]);
    expect(app.backend.unhandled, isEmpty);
    expect(
      app.backend.requests.every((r) => r.sslVerify),
      true,
      reason: 'the link asked for ssl verification',
    );

    final container = _containers(app).single as TokenContainerFinalized;
    expect(container.serial, server.serial);
    expect(container.serverUrl, FakeContainerServer.baseUrl);
    expect(container.syncState, SyncState.completed);
    expect(container.initSynced, true);
    expect(container.policies.rolloverAllowed, true);
    expect(container.policies.disabledUnregister, true);
    expect(container.policies.initialTokenAssignment, false);

    final finalization = server.finalizations.single;
    expect(finalization.accepted, true);
    expect(
      finalization.request.data.keys,
      unorderedEquals([
        'container_serial',
        'public_client_key',
        'signature',
        'device_brand',
        'device_model',
      ]),
    );
    expect(finalization.request.data['device_brand'], AppInfoUtils.deviceBrand);
    expect(finalization.request.data['device_model'], AppInfoUtils.deviceModel);
    expect(
      finalization.signedMessage,
      endsWith(
        '|${server.registrationUrl}|${AppInfoUtils.deviceBrand}'
        '|${AppInfoUtils.deviceModel}',
      ),
    );
    expect(server.registered, true);
    expect(
      server.clientPublicKeyPem,
      container.publicClientKey,
      reason: 'the server registered the key the app keeps',
    );

    final challenge = server.challengeRequests.single;
    expect(challenge.data, {
      'container_serial': server.serial,
      'scope': '${server.syncUrl}',
    });

    final sync = server.syncs.single;
    expect(sync.accepted, true);
    expect(sync.clientTokens, isEmpty);
    expect(sync.request.data.keys, {
      'container_serial',
      'public_enc_key_client',
      'container_dict_client',
      'signature',
    });
    expect(jsonDecode(sync.request.data['container_dict_client']!), {
      'container_serial': server.serial,
      'type': 'smartphone',
      'tokens': <Object>[],
    });
    expect(sync.added, hasLength(2));
    expect(sync.updated, isEmpty);

    final stored = _storedContainers(app).values.single;
    expect(stored, isA<TokenContainerFinalized>());
    expect(stored.serial, server.serial);
    expect((stored as TokenContainerFinalized).syncState, SyncState.completed);
    expect(stored.publicClientKey, container.publicClientKey);
    expect(stored.privateClientKey, container.privateClientKey);

    final tokens = {for (final t in app.tokenState.tokens) t.serial!: t};
    expect(tokens.keys, unorderedEquals([_door().serial, _gate().serial]));
    for (final token in tokens.values) {
      expect(token.containerSerial, server.serial);
      expect(token.origin?.source, TokenOriginSourceType.container);
      expect(token.isPrivacyIdeaToken, true);
      expect(token.issuer, 'privacyIDEA');
    }
    final door = tokens[_door().serial]! as HOTPToken;
    expect(door.secret, _door().secretBase32);
    expect(door.counter, 1);
    expect(
      {
        for (final t in app.storage.storedTokens.values)
          t['serial']: t['containerSerial'],
      },
      {_door().serial: server.serial, _gate().serial: server.serial},
    );
    expect(find.text(_door().serial), findsOneWidget);
    expect(find.text(_gate().serial), findsOneWidget);
    expect(_shownCode(_tileOf(_door().serial)), referenceHotp(_doorSecret, 1));

    app.backend.clearRecords();
    await app.restart();
    await app.pumpUntil(
      () => server.syncs.length == 2,
      reason: 'the sync at app start',
    );
    await app.settle();

    expect(_paths(app), [
      'POST /container/challenge',
      'POST /container/synchronize',
    ]);
    final restartSync = server.syncs.last;
    expect(restartSync.accepted, true);
    expect(
      restartSync.clientSerials,
      unorderedEquals([_door().serial, _gate().serial]),
    );
    expect(restartSync.added, isEmpty);
    expect(_containers(app).single, isA<TokenContainerFinalized>());
    expect(app.tokenState.tokens, hasLength(2));
    expect(find.text(_door().serial), findsOneWidget);
    expect(find.text(_gate().serial), findsOneWidget);
    expect(find.byType(ContainerSyncResultDialog), findsNothing);
    app.expectNoErrorLogs();
  });

  appTest(
    'a later sync adds, updates and removes the tokens the server changed, '
    'without sending a secret',
    (app) async {
      final server = FakeContainerServer(
        app.backend,
        tokens: [_door(), _gate()],
      );
      await app.start();
      await _register(app, server);
      expect(app.tokenState.tokens, hasLength(2));

      final newTotp = FakeContainerToken.totp(
        serial: 'TOTP0003N3W0',
        secret: _gateSecret,
      );
      server.removeToken(_gate().serial);
      server.replaceToken(_door(counter: 7));
      server.replaceToken(newTotp);
      app.backend.clearRecords();
      await app.pullToRefresh();
      await _dismissSyncResult(app);

      expect(_paths(app), [
        'POST /container/challenge',
        'POST /container/synchronize',
      ]);
      final sync = server.syncs.last;
      expect(sync.accepted, true);
      expect(
        sync.clientSerials,
        unorderedEquals([_door().serial, _gate().serial]),
      );
      final sentDictionary = sync.request.data['container_dict_client']!;
      expect(sentDictionary, isNot(contains(_door().secretBase32)));
      expect(sentDictionary, isNot(contains(_gate().secretBase32)));
      for (final token in sync.clientTokens) {
        expect(token.containsKey('secret'), false);
        expect(token['serial'], isNotNull);
      }
      expect(sync.added, [newTotp.enrollUrl]);
      expect(sync.updated.single['serial'], _door().serial);

      expect(
        app.tokenState.tokens.map((t) => t.serial),
        unorderedEquals([_door().serial, newTotp.serial]),
      );
      final door =
          app.tokenState.tokens.firstWhere((t) => t.serial == _door().serial)
              as HOTPToken;
      expect(door.counter, 7);
      expect(door.containerSerial, server.serial);
      expect(
        _shownCode(_tileOf(_door().serial)),
        referenceHotp(_doorSecret, 7),
      );
      expect(find.text(_gate().serial), findsNothing);
      expect(find.text(newTotp.serial), findsOneWidget);
      expect(
        app.storage.storedTokens.values.map((t) => t['serial']),
        unorderedEquals([_door().serial, newTotp.serial]),
      );
      expect(
        app.storage.storedTokens.values.every(
          (t) => t['containerSerial'] == server.serial,
        ),
        true,
      );
      expect(
        (_containers(app).single as TokenContainerFinalized).syncState,
        SyncState.completed,
      );

      await app.restart();
      await app.pumpUntil(() => server.syncs.length == 3);
      await app.settle();
      expect(server.syncs.last.accepted, true);
      expect(server.syncs.last.added, isEmpty);
      expect(app.tokenState.tokens, hasLength(2));
      expect(find.text(newTotp.serial), findsOneWidget);
      app.expectNoErrorLogs();
    },
  );

  appTest(
    'the initial sync offers an unlinked token with a serial by its serial '
    'only, and later syncs do not offer it again',
    (app) async {
      final local = HOTPToken(
        id: 'local-1',
        serial: 'OATH0042L0CA',
        label: 'Old token',
        issuer: 'privacyIDEA',
        algorithm: Algorithms.SHA1,
        digits: 6,
        counter: 3,
        secret: base32(utf8.encode('local-token-secret!')),
      );
      app.storage.putToken(local);
      final server = FakeContainerServer(
        app.backend,
        policies: const FakeContainerPolicies(initialTokenAssignment: true),
        tokens: [_door()],
      );
      await app.start();
      await _register(app, server);

      final initial = server.syncs.single;
      expect(initial.accepted, true);
      expect(initial.clientTokens, [
        {'serial': local.serial, 'tokentype': 'HOTP'},
      ]);
      expect(
        initial.request.data['container_dict_client'],
        isNot(contains(local.secret)),
      );
      final unlinked = app.tokenState.tokens.firstWhere(
        (t) => t.serial == local.serial,
      );
      expect(unlinked.containerSerial, isNull);
      expect(unlinked.checkedContainer, [server.serial]);
      expect(
        app.tokenState.tokens.map((t) => t.serial),
        unorderedEquals([local.serial, _door().serial]),
      );

      await app.pullToRefresh();
      await app.pumpUntil(() => server.syncs.length == 2);
      await app.settle();

      expect(server.syncs.last.accepted, true);
      expect(server.syncs.last.clientSerials, [_door().serial]);
      expect(app.tokenState.tokens, hasLength(2));
      app.expectNoErrorLogs();
    },
  );

  appTest(
    'a passphrase protected container registers with the passphrase the user '
    'types, which is signed but not sent',
    (app) async {
      final server = FakeContainerServer(
        app.backend,
        passphrasePrompt: 'Enter your corporate passphrase',
        passphrase: 'correct horse',
        tokens: [_door()],
      );
      await app.start();

      app.platform.appLinks.open(server.registrationLink());
      await _confirmUrl(app);
      await _answerDeviceInfos(app, send: false);
      await app.pumpUntilFound(find.byType(EnterPassphraseDialog));
      expect(find.text('Enter your corporate passphrase'), findsOneWidget);
      await _enterPassphrase(app, 'correct horse');
      await _dismissSyncResult(app);

      final finalization = server.finalizations.single;
      expect(finalization.accepted, true);
      expect(finalization.signedMessage, endsWith('|correct horse'));
      expect(finalization.request.data.containsKey('passphrase'), false);
      expect(_containers(app).single, isA<TokenContainerFinalized>());
      expect(app.tokenState.tokens.single.serial, _door().serial);
      app.expectNoErrorLogs();
    },
  );

  appTest('a registration the server refuses leaves the container unfinalized, '
      'tells the user and syncs nothing', (app) async {
    final server = FakeContainerServer(
      app.backend,
      passphrasePrompt: 'Enter your corporate passphrase',
      passphrase: 'correct horse',
      tokens: [_door()],
    );
    await app.start();

    app.platform.appLinks.open(server.registrationLink());
    await _confirmUrl(app);
    await _answerDeviceInfos(app, send: false);
    await _enterPassphrase(app, 'wrong horse');
    await app.pumpUntil(
      () => app.statusMessages.isNotEmpty,
      reason: 'the message about the refused registration',
    );
    await app.settle();

    expect(_paths(app), ['POST /container/register/finalize']);
    expect(server.finalizations.single.accepted, false);
    expect(server.registered, false);
    expect(server.syncs, isEmpty);

    final container = _containers(app).single;
    expect(container, isA<TokenContainerUnfinalized>());
    expect(
      container.finalizationState,
      FinalizationState.sendingPublicKeyFailed,
    );
    final stored = _storedContainers(app).values.single;
    expect(stored, isA<TokenContainerUnfinalized>());
    expect(stored.finalizationState, FinalizationState.sendingPublicKeyFailed);
    expect(app.tokenState.tokens, isEmpty);
    expect(app.storage.storedTokens, isEmpty);
    expect(app.statusMessages.single, contains('Could not verify signature!'));
    expect(find.byType(ContainerSyncResultDialog), findsNothing);
  });

  appTest(
    'the message about a refused registration names the step that failed',
    skip:
        'BUG: finalize() builds the message from the container as it was '
        'before sending the key, so it reports the key generation as failed',
    (app) async {
      final server = FakeContainerServer(
        app.backend,
        passphrasePrompt: 'Enter your corporate passphrase',
        passphrase: 'correct horse',
      );
      await app.start();

      app.platform.appLinks.open(server.registrationLink());
      await _confirmUrl(app);
      await _answerDeviceInfos(app, send: false);
      await _enterPassphrase(app, 'wrong horse');
      await app.pumpUntil(() => app.statusMessages.isNotEmpty);

      expect(
        app.statusMessages.single,
        contains(l10n.rolloutStateSendingPublicKeyFailed),
      );
    },
  );

  appTest('a registration link that expired is refused without contacting the '
      'server', (app) async {
    final server = FakeContainerServer(app.backend, tokens: [_door()]);
    await app.start();

    app.platform.appLinks.open(
      server.registrationLink(
        issuedAt: DateTime.now().subtract(const Duration(minutes: 11)),
      ),
    );
    await app.pumpUntil(
      () => app.statusMessages.isNotEmpty,
      reason: 'the message about the expired link',
    );
    await app.settle();

    expect(
      app.statusMessages.single,
      l10n.containerRolloutExpired(server.serial),
    );
    expect(app.backend.requests, isEmpty);
    expect(_containers(app), isEmpty);
    expect(_storedContainers(app), isEmpty);
    expect(find.byType(ContainerShowContainerUrlDialog), findsNothing);
    app.expectNoErrorLogs();
  });

  appTest(
    'a registration link whose time is a whole number of milliseconds still '
    'registers',
    skip:
        'BUG: the registration signature covers the timestamp printed again '
        'by DateTime.toIso8601String (.500Z), not the one from the link '
        '(.500000), so one link in a thousand is refused',
    (app) async {
      final server = FakeContainerServer(app.backend, tokens: [_door()]);
      await app.start();

      final now = DateTime.now().toUtc();
      app.platform.appLinks.open(
        server.registrationLink(
          issuedAt: DateTime.utc(
            now.year,
            now.month,
            now.day,
            now.hour,
            now.minute,
            now.second,
            500,
          ),
        ),
      );
      await _confirmUrl(app);
      await _answerDeviceInfos(app, send: false);
      await _dismissSyncResult(app);

      expect(server.finalizations.single.accepted, true);
      expect(_containers(app).single, isA<TokenContainerFinalized>());
    },
  );

  appTest(
    'a sync that sends a token with a non ASCII name is signed the way the '
    'server verifies it',
    skip:
        'BUG: EccUtils signs message.codeUnits, which is not the UTF-8 the '
        'server verifies, so a label like this makes every later sync fail',
    (app) async {
      final server = FakeContainerServer(
        app.backend,
        tokens: [_door(label: 'Büro Schlüssel')],
      );
      await app.start();
      await _register(app, server);
      expect(find.text('Büro Schlüssel'), findsOneWidget);

      app.backend.clearRecords();
      await app.pullToRefresh();
      await app.pumpUntil(() => server.syncs.length == 2);
      await app.settle();

      expect(server.syncs.last.accepted, true);
      expect(
        (_containers(app).single as TokenContainerFinalized).syncState,
        SyncState.completed,
      );
    },
  );
}
