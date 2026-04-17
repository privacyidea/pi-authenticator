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
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/extensions/token_list_extension.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';

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
}
