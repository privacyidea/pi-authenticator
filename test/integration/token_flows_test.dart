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
import 'package:privacyidea_authenticator/model/enums/day_password_token_view_mode.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/enums/token_types.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/views/add_token_manually_view/add_token_manually_view.dart';
import 'package:privacyidea_authenticator/views/add_token_manually_view/add_token_manually_view_widgets/rows/add_token_button.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/hotp_token_widgets/hotp_token_widget_tile.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/totp_token_widgets/totp_token_widget_tile.dart';

import 'harness/app_harness.dart';
import 'harness/fake_push_endpoint.dart';
import 'harness/reference_otp.dart';

/// The RFC 4226 / RFC 6238 test secret.
final _rfcSecret = utf8.encode('12345678901234567890');

final _otpText = RegExp(r'^\d{3} \d{3}$');

/// The code a token tile currently shows, without the separating blank.
String _shownCode(AppHarness app, Finder tile) {
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

/// Asserts that [tile] shows the RFC 6238 code of now. A period boundary
/// between computing and reading is tolerated by accepting both windows.
void _expectCurrentTotp(AppHarness app, Finder tile) {
  final before = referenceTotp(_rfcSecret, DateTime.now());
  final shown = _shownCode(app, tile);
  final after = referenceTotp(_rfcSecret, DateTime.now());
  expect(shown, anyOf(before, after));
}

TOTPToken _totp(String id, String label) => TOTPToken(
  id: id,
  label: label,
  issuer: 'Example',
  algorithm: Algorithms.SHA1,
  digits: 6,
  period: 30,
  secret: base32(utf8.encode('$id-0123456789')),
);

void main() {
  test('the reference OTP matches the RFC 4226 and RFC 6238 vectors', () {
    expect(referenceHotp(_rfcSecret, 0), '755224');
    expect(referenceHotp(_rfcSecret, 9), '520489');
    expect(
      referenceTotp(
        _rfcSecret,
        DateTime.fromMillisecondsSinceEpoch(59000, isUtc: true),
        digits: 8,
      ),
      '94287082',
    );
    expect(base32(_rfcSecret), 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ');
  });

  appTest('a TOTP token added by hand shows the RFC 6238 code and survives a '
      'restart', (app) async {
    await app.start();

    await app.tap(find.byIcon(Icons.add_moderator));
    await app.pumpUntilFound(find.byType(AddTokenManuallyView));

    await app.tap(find.byType(DropdownButton<TokenTypes>));
    await app.tap(find.text(TokenTypes.TOTP.name).last);
    await app.tester.enterText(
      find.widgetWithText(TextFormField, l10n.name),
      'Mail account',
    );
    await app.tester.enterText(
      find.widgetWithText(TextFormField, l10n.secretKey),
      base32(_rfcSecret),
    );
    await app.tap(find.byType(AddTokenButton));
    await app.pumpUntilGone(find.byType(AddTokenManuallyView));

    final tile = find.ancestor(
      of: find.text('Mail account'),
      matching: find.byType(TOTPTokenWidgetTile),
    );
    await app.pumpUntilFound(tile);
    _expectCurrentTotp(app, tile);

    final stored = app.storage.storedTokens.values.single;
    expect(stored['type'], TokenTypes.TOTP.name);
    expect(stored['label'], 'Mail account');
    expect(stored['secret'], base32(_rfcSecret));
    expect(stored['period'], 30);
    expect(stored['digits'], 6);

    await app.restart();
    await app.pumpUntilFound(tile);
    _expectCurrentTotp(app, tile);
    expect(app.backend.requests, isEmpty);
    app.expectNoErrorLogs();
  });

  appTest(
    'a HOTP token shows the RFC 4226 code, copies it on tap and keeps the '
    'next counter after a restart',
    (app) async {
      app.storage.putToken(
        HOTPToken(
          id: 'hotp-1',
          label: 'Door',
          issuer: 'Example',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: base32(_rfcSecret),
        ),
      );
      await app.start();

      final tile = find.byType(HOTPTokenWidgetTile);
      await app.pumpUntilFound(tile);
      expect(_shownCode(app, tile), referenceHotp(_rfcSecret, 0));

      await app.tap(find.text('755 224'));
      expect(app.platform.clipboardText, '755224');

      await app.tap(find.byIcon(Icons.replay));
      await app.pumpUntil(() => _shownCode(app, tile) == '287082');
      expect(app.storage.storedTokens['hotp-1']!['counter'], 1);

      await app.restart();
      await app.pumpUntilFound(tile);
      expect(_shownCode(app, tile), referenceHotp(_rfcSecret, 1));
      app.expectNoErrorLogs();
    },
  );

  appTest('a corrupt token entry does not keep the other tokens from loading', (
    app,
  ) async {
    app.storage.putToken(_totp('valid-1', 'First valid'));
    app.storage.putRawToken('broken-1', '{"type": "TOTP", "label": ');
    app.storage.putRawToken('broken-2', jsonEncode({'type': 'TOTP'}));
    app.storage.putToken(_totp('valid-2', 'Second valid'));

    await app.start();

    expect(find.text('First valid'), findsOneWidget);
    expect(find.text('Second valid'), findsOneWidget);
    expect(
      app.tokenState.tokens.map((t) => t.id),
      unorderedEquals(['valid-1', 'valid-2']),
    );
    expect(
      app.storage.secure.keys,
      containsAll([
        FakeDeviceStorage.tokenKey('broken-1'),
        FakeDeviceStorage.tokenKey('broken-2'),
      ]),
      reason: 'unreadable entries are skipped, not deleted',
    );
    app.expectNoErrorLogs();
  });

  appTest('tokens of the legacy storage are migrated on start and shown once', (
    app,
  ) async {
    app.storage.putLegacyToken(_totp('legacy-1', 'Legacy token'));
    app.storage.secure[FakeDeviceStorage.legacyKey('unrelated')] = 'not json';
    app.storage.putToken(_totp('current-1', 'Current token'));

    await app.start();

    expect(find.text('Legacy token'), findsOneWidget);
    expect(find.text('Current token'), findsOneWidget);
    expect(
      app.storage.storedTokens.keys,
      unorderedEquals(['legacy-1', 'current-1']),
    );
    expect(
      app.storage.legacyKeys,
      [FakeDeviceStorage.legacyKey('unrelated')],
      reason: 'only token entries leave the legacy storage',
    );

    await app.restart();
    expect(find.text('Legacy token'), findsOneWidget);
    expect(app.tokenState.tokens, hasLength(2));
  });

  appTest('a legacy entry left behind by an interrupted migration does not '
      'overwrite the newer token', (app) async {
    final stale = HOTPToken(
      id: 'hotp-migrated',
      label: 'Door',
      issuer: 'Example',
      algorithm: Algorithms.SHA1,
      digits: 6,
      counter: 5,
      secret: base32(_rfcSecret),
    );
    app.storage.putLegacyToken(stale);
    app.storage.putToken(stale.copyWith(counter: 7, isLocked: true));

    await app.start();

    final token = app.tokenState.tokens.single as HOTPToken;
    expect(token.counter, 7);
    expect(token.isLocked, isTrue);
    expect(app.storage.storedTokens['hotp-migrated']!['counter'], 7);
    expect(app.storage.legacyKeys, isEmpty);
    app.expectNoErrorLogs();
  });

  appTest('tokens of every type stored by versions up to 4.5.3 load with the '
      'defaults of the fields those versions did not know', (app) async {
    final push = FakePushEndpoint(FakePushServer.advertising(), app.backend);
    final tokens = <Token>[
      HOTPToken(
        id: 'old-hotp',
        label: 'Old HOTP',
        issuer: 'Example',
        algorithm: Algorithms.SHA1,
        digits: 6,
        counter: 2,
        secret: base32(_rfcSecret),
      ),
      _totp('old-totp', 'Old TOTP'),
      DayPasswordToken(
        id: 'old-day',
        label: 'Old day password',
        issuer: 'Example',
        algorithm: Algorithms.SHA1,
        digits: 6,
        period: const Duration(days: 1),
        secret: base32(_rfcSecret),
      ),
      SteamToken(
        id: 'old-steam',
        label: 'Old Steam',
        issuer: 'Steam',
        secret: base32(_rfcSecret),
      ),
      push.enrolledToken(id: 'old-push', label: 'Old push'),
    ];
    for (final token in tokens) {
      app.storage.secure[FakeDeviceStorage.legacyKey(token.id)] = jsonEncode(
        token.toJson()
          ..remove('forceBiometricOption')
          ..remove('viewMode'),
      );
    }
    final firebaseConfig = FakeDeviceStorage.legacyKey('firebase-config');
    app.storage.secure[firebaseConfig] = jsonEncode({'projectId': 'example'});

    await app.start();

    expect(
      app.tokenState.tokens.map((t) => t.id),
      unorderedEquals(tokens.map((t) => t.id)),
    );
    for (final token in app.tokenState.tokens) {
      expect(token.forceBiometricOption, ForceBiometricOption.none);
      expect(token.isLocked, isFalse);
    }
    expect(
      app.tokenState.tokens.whereType<DayPasswordToken>().single.viewMode,
      DayPasswordTokenViewMode.VALIDFOR,
    );
    expect(app.storage.legacyKeys, [firebaseConfig]);
    app.expectNoErrorLogs();
  });

  appTest('container entries next to the tokens are neither loaded nor '
      'reported as broken tokens', (app) async {
    app.storage.putToken(_totp('only-token', 'Only token'));
    app.storage.secure['${SECURE_REPO_PREFIX_TOKEN_CONTAINER}_SMPH0001'] =
        jsonEncode({'serial': 'SMPH0001'});

    await app.start();

    expect(app.tokenState.tokens.map((t) => t.id), ['only-token']);
    expect(
      app.logs.warnings.where(
        (w) =>
            w.message.contains('Could not load token') ||
            w.message.contains('of the token storage'),
      ),
      isEmpty,
    );
  });

  appTest('entries of a token type or value this version does not know '
      'survive changes to the other tokens', (app) async {
    final known = HOTPToken(
      id: 'hotp-known',
      label: 'Known',
      issuer: 'Example',
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: base32(_rfcSecret),
    );
    app.storage.putToken(known);
    final unknownType = jsonEncode({
      'type': 'FUTURE',
      'id': 'future-type',
      'label': 'From a newer version',
    });
    final unknownValue = jsonEncode(
      known.copyWith(id: 'future-value').toJson()..['algorithm'] = 'SHA3_512',
    );
    app.storage.putRawToken('future-type', unknownType);
    app.storage.putRawToken('future-value', unknownValue);

    await app.start();
    await app.pumpUntilFound(find.byType(HOTPTokenWidgetTile));
    await app.tap(find.byIcon(Icons.replay));
    await app.pumpUntil(
      () => app.storage.storedTokens['hotp-known']!['counter'] == 1,
      reason: 'the counter to be saved',
    );
    await app.restart();

    expect(app.tokenState.tokens.map((t) => t.id), ['hotp-known']);
    expect(app.storage.secure[FakeDeviceStorage.tokenKey('future-type')], unknownType);
    expect(app.storage.secure[FakeDeviceStorage.tokenKey('future-value')], unknownValue);
    app.expectNoErrorLogs();
  });

  appTest('tokens without or with the same sort index keep their order across '
      'a restart', (app) async {
    const labels = ['Alpha', 'Bravo', 'Charlie', 'Delta'];
    app.storage.putToken(_totp('a', 'Alpha'));
    app.storage.putToken(_totp('b', 'Bravo').copyWith(sortIndex: 1));
    app.storage.putToken(_totp('c', 'Charlie').copyWith(sortIndex: 1));
    app.storage.putToken(_totp('d', 'Delta'));
    List<String> shownOrder() {
      final shown = labels.where((l) => find.text(l).evaluate().isNotEmpty);
      return shown.toList()..sort(
        (a, b) => app.tester
            .getTopLeft(find.text(a))
            .dy
            .compareTo(app.tester.getTopLeft(find.text(b)).dy),
      );
    }

    await app.start();
    await app.settle();
    final first = shownOrder();
    await app.restart();
    await app.settle();

    expect(first, hasLength(labels.length));
    expect(shownOrder(), first);
    app.expectNoErrorLogs();
  });
}
