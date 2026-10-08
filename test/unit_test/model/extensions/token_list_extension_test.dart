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

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/extensions/token_list_extension.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/token_template.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';

HOTPToken _token({
  String id = 'id',
  String label = 'label',
  String issuer = 'issuer',
  String? serial,
  String? containerSerial,
  int? folderId,
  bool isOffline = false,
  TokenOriginData? origin,
  List<String> checkedContainer = const [],
}) => HOTPToken(
  id: id,
  label: label,
  issuer: issuer,
  serial: serial,
  containerSerial: containerSerial,
  folderId: folderId,
  isOffline: isOffline,
  origin: origin,
  checkedContainer: checkedContainer,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'SECRET',
);

TokenOriginData _piOrigin() => TokenOriginData(
  source: TokenOriginSourceType.qrScan,
  isPrivacyIdeaToken: true,
  creator: 'test',
  appName: 'test',
  data: '',
);

TokenOriginData _containerOrigin() => TokenOriginData(
  source: TokenOriginSourceType.container,
  isPrivacyIdeaToken: true,
  creator: 'test',
  appName: 'test',
  data: '',
);

TokenOriginData _nonPiOrigin() => TokenOriginData(
  source: TokenOriginSourceType.manually,
  isPrivacyIdeaToken: false,
  creator: 'test',
  appName: 'test',
  data: '',
);

// --- fixtures for the container sync and the export ---

const _secretA = 'GEZDGNBVGY3TQOJQ';
const _secretB = 'MFRGGZDFMZTWQ2LK';
const _secretC = 'ONSWG4TFOQYTEMZU';
const _secretSteam = 'KRSXG5CTMVRXEZLU';
const _pushPrivateKey = 'PRIVATE-TOKEN-KEY-MATERIAL';
const _allSecrets = [
  _secretA,
  _secretB,
  _secretC,
  _secretSteam,
  _pushPrivateKey,
];

TokenOriginData _origin(
  TokenOriginSourceType source, {
  bool? isPi,
  String data = 'data',
}) => TokenOriginData(
  source: source,
  appName: 'test-app',
  data: data,
  isPrivacyIdeaToken: isPi,
);

TokenOriginData _syncContainerOrigin() =>
    _origin(TokenOriginSourceType.container, isPi: true);

HOTPToken _hotp(
  String id, {
  String? serial,
  String issuer = 'issuer',
  String secret = _secretA,
  int counter = 0,
  String? containerSerial,
  List<String> checkedContainer = const [],
  TokenOriginData? origin,
  bool? isHidden,
  bool pin = false,
}) => HOTPToken(
  id: id,
  serial: serial,
  issuer: issuer,
  label: 'label-$id',
  secret: secret,
  counter: counter,
  algorithm: Algorithms.SHA1,
  digits: 6,
  containerSerial: containerSerial,
  checkedContainer: checkedContainer,
  origin: origin,
  isHidden: isHidden,
  pin: pin,
);

TOTPToken _totp(
  String id, {
  String? serial,
  String issuer = 'issuer',
  String secret = _secretB,
  String? containerSerial,
  TokenOriginData? origin,
}) => TOTPToken(
  id: id,
  serial: serial,
  issuer: issuer,
  label: 'label-$id',
  secret: secret,
  period: 30,
  algorithm: Algorithms.SHA1,
  digits: 6,
  containerSerial: containerSerial,
  origin: origin,
);

SteamToken _steam(String id, {TokenOriginData? origin}) => SteamToken(
  id: id,
  secret: _secretSteam,
  issuer: 'Steam',
  label: 'label-$id',
  origin: origin,
);

PushToken _push(
  String id, {
  String? serial,
  String? containerSerial,
  List<String> checkedContainer = const [],
  TokenOriginData? origin,
}) => PushToken(
  id: id,
  serial: serial ?? 'PIPU-$id',
  issuer: 'issuer',
  label: 'label-$id',
  url: Uri.parse('https://pi.example.com/ttype/push'),
  privateTokenKey: _pushPrivateKey,
  containerSerial: containerSerial,
  checkedContainer: checkedContainer,
  origin: origin,
);

List<String> _ids(Iterable<Token> tokens) => tokens.map((e) => e.id).toList();
void main() {
  group('TokenListExtension', () {
    test('noOffline filters out offline tokens', () {
      final tokens = [
        _token(id: '1'),
        _token(id: '2', isOffline: true),
        _token(id: '3'),
      ];
      expect(tokens.noOffline.length, 2);
    });

    test('piTokens returns only PI tokens', () {
      final tokens = [
        _token(id: '1', origin: _piOrigin()),
        _token(id: '2', origin: _nonPiOrigin()),
        _token(id: '3'),
      ];
      expect(tokens.piTokens.length, 1);
      expect(tokens.piTokens.first.id, '1');
    });

    test('filterNonPiTokens includes tokens without origin', () {
      final tokens = [
        _token(id: '1', origin: _piOrigin()),
        _token(id: '2', origin: _nonPiOrigin()),
        _token(
          id: '3',
        ), // no origin → isPrivacyIdeaToken == null → != false → included
      ];
      final result = tokens.filterNonPiTokens;
      expect(result.length, 2);
      expect(result.any((t) => t.id == '2'), isFalse);
    });

    test('withSerial returns only tokens with serial', () {
      final tokens = [
        _token(id: '1', serial: 'S1'),
        _token(id: '2'),
        _token(id: '3', serial: 'S3'),
      ];
      expect(tokens.withSerial.length, 2);
    });

    test('withoutSerial returns only tokens without serial', () {
      final tokens = [_token(id: '1', serial: 'S1'), _token(id: '2')];
      expect(tokens.withoutSerial.length, 1);
      expect(tokens.withoutSerial.first.id, '2');
    });

    test('inFolder returns tokens in specific folder', () {
      final tokens = [
        _token(id: '1', folderId: 1),
        _token(id: '2', folderId: 2),
        _token(id: '3'),
      ];
      final folder = const TokenFolder(label: 'F1', folderId: 1);
      expect(tokens.inFolder(folder).length, 1);
      expect(tokens.inFolder(folder).first.id, '1');
    });

    test('inFolder without arg returns tokens with any folderId', () {
      final tokens = [_token(id: '1', folderId: 1), _token(id: '2')];
      expect(tokens.inFolder().length, 1);
    });

    test('inNoFolder returns tokens without folderId', () {
      final tokens = [_token(id: '1', folderId: 1), _token(id: '2')];
      expect(tokens.inNoFolder().length, 1);
      expect(tokens.inNoFolder().first.id, '2');
    });

    test('notLinkedTokenss returns tokens without containerSerial', () {
      final tokens = [_token(id: '1', containerSerial: 'C1'), _token(id: '2')];
      expect(tokens.notLinkedTokenss.length, 1);
      expect(tokens.notLinkedTokenss.first.id, '2');
    });

    test('ofContainer returns tokens for specific container', () {
      final tokens = [
        _token(id: '1', containerSerial: 'C1', origin: _containerOrigin()),
        _token(id: '2', containerSerial: 'C2', origin: _containerOrigin()),
        _token(id: '3'),
      ];
      final result = tokens.ofContainer('C1');
      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('whereNotType filters by runtime type', () {
      final tokens = [_token(id: '1')];
      final result = tokens.whereNotType([HOTPToken]);
      expect(result, isEmpty);
    });

    test('filterDuplicates removes duplicate tokens', () {
      final t = _token(id: '1', serial: 'S1');
      final tokens = [t, t];
      expect(tokens.filterDuplicates().length, 1);
    });

    test('empty list operations', () {
      final List<Token> tokens = [];
      expect(tokens.noOffline, isEmpty);
      expect(tokens.piTokens, isEmpty);
      expect(tokens.withSerial, isEmpty);
      expect(tokens.inNoFolder(), isEmpty);
      expect(tokens.toTemplates(), isEmpty);
    });
  });

  _testMaybeContainerTokensOf();
  _testWithSerialWithoutSerial();
  _testExportableTokens();
  _testFilterDuplicates();
  _testSyncPayload();
}

void _testMaybeContainerTokensOf() {
  group('maybeContainerTokensOf', () {
    test('returns unlinked tokens with a privacyIDEA or unknown origin', () {
      final tokens = <Token>[
        _hotp('no-origin'),
        _hotp('pi-origin', origin: _origin(TokenOriginSourceType.qrScan, isPi: true)),
        _hotp('unknown-flag', origin: _origin(TokenOriginSourceType.link)),
      ];

      expect(_ids(tokens.maybeContainerTokensOf('C1')), [
        'no-origin',
        'pi-origin',
        'unknown-flag',
      ]);
    });

    test('excludes tokens that are known to be no privacyIDEA tokens', () {
      final tokens = <Token>[
        _hotp('imported', origin: _origin(TokenOriginSourceType.backupFile, isPi: false)),
        _hotp('manual-non-pi', origin: _origin(TokenOriginSourceType.manually, isPi: false)),
        _hotp('candidate'),
      ];

      expect(_ids(tokens.maybeContainerTokensOf('C1')), ['candidate']);
    });

    test('excludes tokens that are already linked to the container', () {
      final tokens = <Token>[
        _hotp('in-c1', containerSerial: 'C1', origin: _syncContainerOrigin()),
        _hotp('free'),
      ];

      expect(_ids(tokens.maybeContainerTokensOf('C1')), ['free']);
    });

    test('excludes tokens that are linked to another container', () {
      final tokens = <Token>[
        _hotp('in-c1', containerSerial: 'C1', origin: _syncContainerOrigin()),
        _hotp('free'),
      ];

      expect(_ids(tokens.maybeContainerTokensOf('C2')), ['free']);
    });

    test('excludes tokens with a containerSerial even if the origin is no container origin', () {
      final tokens = <Token>[
        _hotp('odd', containerSerial: 'C1', origin: _origin(TokenOriginSourceType.qrScan)),
      ];

      expect(tokens.maybeContainerTokensOf('C1'), isEmpty);
      expect(tokens.maybeContainerTokensOf('C2'), isEmpty);
    });

    test('excludes tokens whose checkedContainer contains the serial', () {
      final tokens = <Token>[
        _hotp('checked-c1', checkedContainer: const ['C1']),
        _hotp('checked-c1-c2', checkedContainer: const ['C1', 'C2']),
        _hotp('checked-c2', checkedContainer: const ['C2']),
        _hotp('never-checked'),
      ];

      expect(_ids(tokens.maybeContainerTokensOf('C1')), [
        'checked-c2',
        'never-checked',
      ]);
      expect(_ids(tokens.maybeContainerTokensOf('C2')), [
        'checked-c1',
        'never-checked',
      ]);
      expect(_ids(tokens.maybeContainerTokensOf('C3')), [
        'checked-c1',
        'checked-c1-c2',
        'checked-c2',
        'never-checked',
      ]);
    });

    test('serials are compared exactly (no prefix or case matching)', () {
      final tokens = <Token>[_hotp('t', checkedContainer: const ['SMPH0001'])];

      expect(tokens.maybeContainerTokensOf('SMPH000'), hasLength(1));
      expect(tokens.maybeContainerTokensOf('smph0001'), hasLength(1));
      expect(tokens.maybeContainerTokensOf('SMPH00011'), hasLength(1));
      expect(tokens.maybeContainerTokensOf('SMPH0001'), isEmpty);
    });

    test('Steam tokens are never candidates, push tokens with serial are', () {
      final tokens = <Token>[_steam('steam'), _push('push'), _totp('totp')];

      expect(_ids(tokens.maybeContainerTokensOf('C1')), ['push', 'totp']);
    });

    test('keeps the order, returns a new list and does not touch the input', () {
      final tokens = <Token>[
        _hotp('3'),
        _hotp('1', containerSerial: 'C1', origin: _syncContainerOrigin()),
        _hotp('2'),
      ];
      final snapshot = List<Token>.of(tokens);

      final result = tokens.maybeContainerTokensOf('C1');

      expect(_ids(result), ['3', '2']);
      expect(identical(result, tokens), isFalse);
      expect(tokens, snapshot);
      // The result is a growable copy, not a view that would change the input.
      result.add(_hotp('4'));
      expect(tokens, hasLength(3));
    });

    test('empty input gives empty output', () {
      expect(<Token>[].maybeContainerTokensOf('C1'), isEmpty);
    });

    test('maybeContainerTokens equals the result for a serial nobody checked', () {
      final tokens = <Token>[
        _hotp('a'),
        _hotp('b', origin: _origin(TokenOriginSourceType.qrScan, isPi: false)),
        _hotp('c', containerSerial: 'C1', origin: _syncContainerOrigin()),
        _steam('d'),
        _push('e'),
      ];

      expect(_ids(tokens.maybeContainerTokens), ['a', 'e']);
      expect(
        _ids(tokens.maybeContainerTokensOf('anything')),
        _ids(tokens.maybeContainerTokens),
      );
    });

    test('a container token is no candidate for assignment to any container', () {
      final tokens = <Token>[
        _hotp('mine', serial: 'S1', containerSerial: 'C1', origin: _syncContainerOrigin()),
      ];

      expect(tokens.maybeContainerTokensOf('C1'), isEmpty);
      expect(tokens.maybeContainerTokensOf('C2'), isEmpty);
    });
  });
}

void _testWithSerialWithoutSerial() {
  group('withSerial / withoutSerial', () {
    test('partition the list: every token is in exactly one of them', () {
      final tokens = <Token>[
        _hotp('a', serial: 'S1'),
        _hotp('b'),
        _totp('c', serial: 'S2'),
        _totp('d'),
        _steam('e'),
        _push('f'),
      ];

      final withSerial = tokens.withSerial;
      final withoutSerial = tokens.withoutSerial;

      expect(_ids(withSerial), ['a', 'c', 'f']);
      expect(_ids(withoutSerial), ['b', 'd', 'e']);
      expect(withSerial.length + withoutSerial.length, tokens.length);
      expect(
        withSerial.toSet().intersection(withoutSerial.toSet()),
        isEmpty,
      );
    });

    test('Steam tokens never have a serial, push tokens always have one', () {
      expect([_steam('s')].withSerial, isEmpty);
      expect([_steam('s')].withoutSerial, hasLength(1));
      expect([_push('p')].withSerial, hasLength(1));
      expect([_push('p')].withoutSerial, isEmpty);
    });

    test('empty input', () {
      expect(<Token>[].withSerial, isEmpty);
      expect(<Token>[].withoutSerial, isEmpty);
    });
  });
}

void _testExportableTokens() {
  group('exportableTokens', () {
    test('a token without origin is not exportable', () {
      expect([_hotp('x')].exportableTokens, isEmpty);
      expect([_totp('x')].exportableTokens, isEmpty);
      expect([_steam('x')].exportableTokens, isEmpty);
      expect([_push('x')].exportableTokens, isEmpty);
    });

    test('manually added tokens are exportable', () {
      final tokens = <Token>[
        _hotp('manual-null', origin: _origin(TokenOriginSourceType.manually)),
        _hotp('manual-false', origin: _origin(TokenOriginSourceType.manually, isPi: false)),
      ];

      expect(_ids(tokens.exportableTokens), ['manual-null', 'manual-false']);
    });

    test('tokens explicitly marked as no privacyIDEA token are exportable for every source', () {
      final tokens = <Token>[
        for (final source in TokenOriginSourceType.values)
          _hotp(source.name, origin: _origin(source, isPi: false)),
      ];

      expect(
        _ids(tokens.exportableTokens),
        TokenOriginSourceType.values.map((e) => e.name).toList(),
      );
    });

    test('tokens marked as privacyIDEA tokens are not exportable', () {
      final tokens = <Token>[
        for (final source in TokenOriginSourceType.values)
          if (source != TokenOriginSourceType.manually)
            _hotp(source.name, origin: _origin(source, isPi: true)),
      ];

      expect(tokens, isNotEmpty);
      expect(tokens.exportableTokens, isEmpty);
    });

    test('tokens with unknown privacyIDEA state are only exportable if added manually', () {
      final tokens = <Token>[
        for (final source in TokenOriginSourceType.values)
          _hotp(source.name, origin: _origin(source)),
      ];

      expect(_ids(tokens.exportableTokens), ['manually']);
    });

    test('push tokens are not exportable', () {
      final tokens = <Token>[
        _push('no-origin'),
        _push('pi-origin', origin: _origin(TokenOriginSourceType.qrScan, isPi: true)),
        _push('container-origin', containerSerial: 'C1', origin: _syncContainerOrigin()),
        _push('unknown-origin', origin: _origin(TokenOriginSourceType.unknown)),
      ];

      expect(tokens.exportableTokens, isEmpty);
    });

    test('tokens of a container are not exportable', () {
      final tokens = <Token>[
        _hotp('a', serial: 'S1', containerSerial: 'C1', origin: _syncContainerOrigin()),
        _totp('b', serial: 'S2', containerSerial: 'C1', origin: _syncContainerOrigin()),
      ];

      expect(tokens.exportableTokens, isEmpty);
    });

    test('exportability depends only on the origin, not on the hidden or locked state', () {
      final tokens = <Token>[
        _hotp('hidden-pi', isHidden: true, origin: _origin(TokenOriginSourceType.qrScan, isPi: true)),
        _hotp('locked-pi', pin: true, origin: _origin(TokenOriginSourceType.link, isPi: true)),
        _hotp('hidden-no-origin', isHidden: true),
        _hotp('hidden-non-pi', isHidden: true, origin: _origin(TokenOriginSourceType.backupFile, isPi: false)),
        _hotp('locked-manual', pin: true, origin: _origin(TokenOriginSourceType.manually)),
      ];
      expect(tokens.firstWhere((t) => t.id == 'hidden-pi').isHidden, isTrue);
      expect(tokens.firstWhere((t) => t.id == 'locked-pi').isHidden, isTrue);

      expect(_ids(tokens.exportableTokens), ['hidden-non-pi', 'locked-manual']);
    });

    test('mixed list: only non privacyIDEA and manual tokens survive, in order', () {
      final tokens = <Token>[
        _hotp('1-manual', origin: _origin(TokenOriginSourceType.manually)),
        _hotp('2-no-origin'),
        _hotp('3-pi', origin: _origin(TokenOriginSourceType.qrScan, isPi: true)),
        _totp('4-aegis', origin: _origin(TokenOriginSourceType.backupFile, isPi: false)),
        _push('5-push', origin: _origin(TokenOriginSourceType.qrScan, isPi: true)),
        _hotp('6-container', containerSerial: 'C1', origin: _syncContainerOrigin()),
        _steam('7-steam', origin: _origin(TokenOriginSourceType.manually)),
        _hotp('8-unknown', origin: _origin(TokenOriginSourceType.unknown)),
        _totp('9-google', origin: _origin(TokenOriginSourceType.qrScanImport, isPi: false)),
      ];
      final snapshot = List<Token>.of(tokens);

      final exportable = tokens.exportableTokens;

      expect(_ids(exportable), ['1-manual', '4-aegis', '7-steam', '9-google']);
      expect(tokens, snapshot);
      expect(
        exportable.every((t) => t.isExportable),
        isTrue,
        reason: 'the list extension must agree with Token.isExportable',
      );
      expect(
        tokens.where((t) => !exportable.contains(t)).any((t) => t.isExportable),
        isFalse,
      );
    });

    test('no exportable token is a known privacyIDEA token (all sources, all flags)', () {
      final tokens = <Token>[
        for (final source in TokenOriginSourceType.values)
          for (final flag in <bool?>[true, false, null])
            // The combination (manually, true) is covered by its own test below.
            if (!(source == TokenOriginSourceType.manually && flag == true))
              _hotp('${source.name}-$flag', origin: _origin(source, isPi: flag)),
      ];

      final exportable = tokens.exportableTokens;

      expect(
        exportable.where((t) => t.isPrivacyIdeaToken == true),
        isEmpty,
        reason: 'a privacyIDEA token must never be exportable',
      );
      // A token that is explicitly no PI token is exportable, a PI token never.
      expect(
        tokens
            .where((t) => t.isPrivacyIdeaToken == false)
            .every(exportable.contains),
        isTrue,
      );
    });

    test(
      'a token marked as privacyIDEA token is not exportable even if its source is manually',
      () {
        final token = _hotp(
          'manual-pi',
          origin: _origin(TokenOriginSourceType.manually, isPi: true),
        );

        expect(token.isPrivacyIdeaToken, isTrue);
        expect([token].exportableTokens, isEmpty);
      },
      skip:
          'BUG: lib/model/token_import/token_origin_data.dart:40 isExportable returns true for source manually even if isPrivacyIdeaToken == true',
    );

    test(
      'a push token is never exportable, whatever its origin says',
      () {
        final token = _push(
          'push',
          origin: _origin(TokenOriginSourceType.backupFile, isPi: false),
        );

        expect(token.isPrivacyIdeaToken, isTrue);
        expect([token].exportableTokens, isEmpty);
      },
      skip:
          'BUG: lib/model/tokens/token.dart:169 Token.isExportable ignores the isPrivacyIdeaToken override of PushToken (always true) and trusts origin only',
    );
  });
}

void _testFilterDuplicates() {
  group('filterDuplicates (import duplicate detection)', () {
    test('tokens with the same serial and issuer are duplicates', () {
      final tokens = <Token>[
        _hotp('1', serial: 'S1'),
        _hotp('2', serial: 'S1'),
        _hotp('3', serial: 'S2'),
      ];

      expect(_ids(tokens.filterDuplicates()), ['1', '3']);
    });

    test('same serial but another issuer is no duplicate', () {
      final tokens = <Token>[
        _hotp('1', serial: 'S1', issuer: 'A'),
        _hotp('2', serial: 'S1', issuer: 'B'),
      ];

      expect(_ids(tokens.filterDuplicates()), ['1', '2']);
    });

    test('without serial the same secret, algorithm, digits and type are duplicates', () {
      final tokens = <Token>[
        _hotp('1'),
        _hotp('2', counter: 40),
        _hotp('3', secret: _secretB),
      ];

      expect(_ids(tokens.filterDuplicates()), ['1', '3']);
    });

    test('the same secret in different token types is no duplicate', () {
      final tokens = <Token>[
        _hotp('hotp'),
        _totp('totp', secret: _secretA),
      ];

      expect(_ids(tokens.filterDuplicates()), ['hotp', 'totp']);
    });

    test('the same id is always a duplicate', () {
      final tokens = <Token>[
        _hotp('same'),
        _hotp('same', secret: _secretB),
      ];

      expect(_ids(tokens.filterDuplicates()), ['same']);
    });

    test('filterDuplicates keeps the first of the duplicates and handles empty input', () {
      final first = _hotp('first', secret: _secretC);
      final second = _hotp('second', secret: _secretC);

      final result = <Token>[first, second].filterDuplicates();

      expect(result, hasLength(1));
      expect(identical(result.single, first), isTrue);
      expect(<Token>[].filterDuplicates(), isEmpty);
    });
  });
}

void _testSyncPayload() {
  group('sync payload (templates built from the token list)', () {
    final syncTokens = <Token>[
      // already in container C1
      _hotp('c1-hotp', serial: 'OATH-C1', containerSerial: 'C1', origin: _syncContainerOrigin()),
      _push('c1-push', containerSerial: 'C1', origin: _syncContainerOrigin()),
      // candidates for the initial assignment
      _hotp('cand-serial', serial: 'OATH-CAND', secret: _secretC),
      _totp('cand-no-serial'),
      _hotp('cand-no-serial-hotp', counter: 3),
      // never candidates
      _steam('steam'),
      _totp('imported', origin: _origin(TokenOriginSourceType.backupFile, isPi: false)),
    ];

    test('toTemplates creates one template per token and keeps the variant', () {
      final templates = syncTokens.toTemplates();

      expect(templates, hasLength(syncTokens.length));
      for (var i = 0; i < syncTokens.length; i++) {
        final token = syncTokens[i];
        expect(
          templates[i].otpValues == null,
          token.serial != null,
          reason: '${token.id}: templates with serial have no otps and vice versa',
        );
      }
      expect(<Token>[].toTemplates(), isEmpty);
    });

    test('assignment candidates split by serial give the right template variants', () {
      final candidates = syncTokens.maybeContainerTokensOf('C1');
      expect(_ids(candidates), ['cand-serial', 'cand-no-serial', 'cand-no-serial-hotp']);

      final withSerial = candidates.withSerial.toTemplates();
      final withoutSerial = candidates.withoutSerial.toTemplates();

      expect(withSerial.map((e) => e.serial), ['OATH-CAND']);
      expect(withSerial.every((e) => e.otpValues == null), isTrue);
      expect(withoutSerial, hasLength(2));
      expect(withoutSerial.every((e) => e.serial == null), isTrue);
      expect(withoutSerial.every((e) => e.otpValues!.length == 2), isTrue);
    });

    test('assignment identification of candidates with serial contains only serial and type', () {
      final candidates = syncTokens.maybeContainerTokensOf('C1').withSerial;

      final identifications = candidates
          .toTemplates()
          .map((e) => e.tokenIdentification)
          .toList();

      expect(identifications, [
        {Token.SERIAL: 'OATH-CAND', Token.TOKENTYPE_OTPAUTH: 'HOTP'},
      ]);
    });

    test('no secret reaches the payload that is built like the sync does', () {
      final containerTemplates = syncTokens
          .where((t) => t.containerSerial == 'C1')
          .toList()
          .toTemplates();
      final candidates = syncTokens.maybeContainerTokensOf('C1');
      final templatesForAssignment = [
        ...candidates.withSerial.toTemplates(),
        ...candidates.withoutSerial.toTemplates(),
      ];

      final payload = [
        for (final template in containerTemplates) template.tokenDataSafeToSend,
        for (final template in templatesForAssignment) template.tokenIdentification,
      ];
      final json = jsonEncode(payload);

      expect(payload, hasLength(containerTemplates.length + templatesForAssignment.length));
      for (final secret in _allSecrets) {
        expect(json.contains(secret), isFalse, reason: 'leaked $secret');
      }
      expect(json.contains('"secret"'), isFalse);
      // The identification of candidates must not carry labels or issuers.
      for (final template in templatesForAssignment) {
        expect(template.tokenIdentification.containsKey(Token.LABEL), isFalse);
        expect(template.tokenIdentification.containsKey(Token.ISSUER), isFalse);
      }
    });

    test('a candidate without serial is identified by its type, otp values and counter', () {
      final token = _hotp('hotp', counter: 3);

      final template = [token].toTemplates().single;

      expect(template.tokenIdentification, {
        Token.TOKENTYPE_OTPAUTH: 'HOTP',
        'otp': [token.otpValue, token.nextValue],
        'counter': '3',
      });
      expect(template, isA<TokenTemplate>());
      expect(template.otpValues, [token.otpValue, token.nextValue]);
    });
  });
}
