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
import 'package:privacyidea_authenticator/model/riverpod_states/token_filter.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';

HOTPToken _hotpToken({
  String label = 'TestLabel',
  String issuer = 'TestIssuer',
  String id = 'id1',
}) => HOTPToken(
  label: label,
  issuer: issuer,
  id: id,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'SECRET',
);

PushToken _pushToken({
  String label = 'PushLabel',
  String issuer = 'PushIssuer',
  String serial = 'PUSH001',
  String id = 'push1',
}) => PushToken(
  label: label,
  issuer: issuer,
  serial: serial,
  id: id,
  sslVerify: true,
  enrollmentCredentials: '',
  url: Uri.parse('https://example.com'),
);

void main() {
  group('TokenFilter', () {
    group('filterTokens', () {
      test('filters by label', () {
        final filter = TokenFilter(searchQuery: 'Alpha');
        final tokens = [
          _hotpToken(label: 'AlphaToken', issuer: 'Org'),
          _hotpToken(label: 'BetaToken', issuer: 'Org', id: 'id2'),
        ];
        final result = filter.filterTokens(tokens);
        expect(result.length, 1);
        expect(result.first.label, 'AlphaToken');
      });

      test('filters by issuer', () {
        final filter = TokenFilter(searchQuery: 'MyIssuer');
        final tokens = [
          _hotpToken(issuer: 'MyIssuer'),
          _hotpToken(issuer: 'Other', id: 'id2'),
        ];
        final result = filter.filterTokens(tokens);
        expect(result.length, 1);
        expect(result.first.issuer, 'MyIssuer');
      });

      test('filters PushToken by serial', () {
        final filter = TokenFilter(searchQuery: 'PUSH001');
        final tokens = [_pushToken(), _hotpToken(id: 'id2')];
        final result = filter.filterTokens(tokens);
        expect(result.length, 1);
      });

      test('is case insensitive', () {
        final filter = TokenFilter(searchQuery: 'test');
        final tokens = [_hotpToken(label: 'TestToken')];
        final result = filter.filterTokens(tokens);
        expect(result.length, 1);
      });

      test('returns empty for no match', () {
        final filter = TokenFilter(searchQuery: 'nonexistent');
        final tokens = [_hotpToken()];
        final result = filter.filterTokens(tokens);
        expect(result, isEmpty);
      });

      test('returns empty for invalid regex', () {
        final filter = TokenFilter(searchQuery: '[invalid');
        final tokens = [_hotpToken()];
        final result = filter.filterTokens(tokens);
        expect(result, isEmpty);
      });

      test('returns all matching tokens', () {
        final filter = TokenFilter(searchQuery: 'Token');
        final tokens = [
          _hotpToken(label: 'TokenA'),
          _hotpToken(label: 'TokenB', id: 'id2'),
          _hotpToken(label: 'Other', id: 'id3'),
        ];
        final result = filter.filterTokens(tokens);
        expect(result.length, 2);
      });

      test('filters by token type', () {
        final filter = TokenFilter(searchQuery: 'HOTP');
        final tokens = [_hotpToken()];
        final result = filter.filterTokens(tokens);
        expect(result.length, 1);
      });
    });

    group('filterSortables', () {
      test('always includes TokenFolders', () {
        final filter = TokenFilter(searchQuery: 'nonexistent');
        final folder = const TokenFolder(label: 'MyFolder', folderId: 1);
        final result = filter.filterSortables([folder, _hotpToken()]);
        expect(result.length, 1);
        expect(result.first, isA<TokenFolder>());
      });

      test('includes matching tokens', () {
        final filter = TokenFilter(searchQuery: 'Test');
        final folder = const TokenFolder(label: 'Folder', folderId: 1);
        final token = _hotpToken(label: 'TestToken');
        final result = filter.filterSortables([folder, token]);
        expect(result.length, 2);
      });

      test('returns empty for invalid regex', () {
        final filter = TokenFilter(searchQuery: '[invalid');
        final result = filter.filterSortables([_hotpToken()]);
        expect(result, isEmpty);
      });
    });
  });
}
