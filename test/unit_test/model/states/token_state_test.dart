import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';

// ignore: must_be_immutable
class _TokenMock extends Mock implements Token {
  @override
  final String label;
  @override
  final String id;
  _TokenMock({required this.id, this.label = 'label'});
}

const _secretA = 'GEZDGNBVGY3TQOJQ';
const _secretB = 'MFRGGZDFMZTWQ2LK';
const _secretC = 'ONSWG4TFOQYTEMZU';
const _pushPrivateKey = 'PRIVATE-TOKEN-KEY-MATERIAL';

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

TokenOriginData _containerOrigin() =>
    _origin(TokenOriginSourceType.container, isPi: true);

HOTPToken _hotp(
  String id, {
  String? serial,
  String issuer = 'issuer',
  String secret = _secretA,
  int counter = 0,
  String? containerSerial,
  TokenOriginData? origin,
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
  origin: origin,
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

PushToken _push(
  String id, {
  String? serial,
  String? containerSerial,
  TokenOriginData? origin,
}) => PushToken(
  id: id,
  serial: serial ?? 'PIPU-$id',
  issuer: 'issuer',
  label: 'label-$id',
  url: Uri.parse('https://pi.example.com/ttype/push'),
  privateTokenKey: _pushPrivateKey,
  containerSerial: containerSerial,
  origin: origin,
);

List<String> _ids(Iterable<Token> tokens) => tokens.map((e) => e.id).toList();

void main() {
  _testTokenState();
  _testContainerTokens();
  _testGetSameTokensAndCurrentOf();
}

void _testTokenState() {
  group('TokenState', () {
    test('constructor', () {
      final state = TokenState(tokens: [_TokenMock(id: 'id')]);
      expect(state.tokens.first, isA<_TokenMock>());
    });
    test('withToken', () {
      final state = TokenState(tokens: [_TokenMock(id: 'id')]);
      final newState = state.withToken(_TokenMock(id: 'newid'));
      expect(state.tokens.length, 1);
      expect((state.tokens.first as _TokenMock).id, 'id');
      expect(newState.tokens.length, 2);
      expect((newState.tokens.first as _TokenMock).id, 'id');
      expect((newState.tokens.last as _TokenMock).id, 'newid');
    });
    test('withTokens', () {
      final state = TokenState(tokens: [_TokenMock(id: 'id')]);
      final newState = state.withTokens([
        _TokenMock(id: 'newid'),
        _TokenMock(id: 'newid2'),
      ]);
      expect(state.tokens.length, 1);
      expect((state.tokens.first as _TokenMock).id, 'id');
      expect(newState.tokens.length, 3);
      expect((newState.tokens[0] as _TokenMock).id, 'id');
      expect((newState.tokens[1] as _TokenMock).id, 'newid');
      expect((newState.tokens[2] as _TokenMock).id, 'newid2');
    });
    test('withoutToken', () {
      final state = TokenState(
        tokens: [
          _TokenMock(id: 'id'),
          _TokenMock(id: 'id2'),
        ],
      );
      final newState = state.withoutToken(_TokenMock(id: 'id'));
      expect(state.tokens.length, 2);
      expect((state.tokens.first as _TokenMock).id, 'id');
      expect((state.tokens.last as _TokenMock).id, 'id2');
      expect(newState.tokens.length, 1);
      expect((newState.tokens.first as _TokenMock).id, 'id2');
    });
    test('withoutTokens', () {
      final state = TokenState(
        tokens: [
          _TokenMock(id: 'id'),
          _TokenMock(id: 'id2'),
          _TokenMock(id: 'id3'),
        ],
      );
      final newState = state.withoutTokens([
        _TokenMock(id: 'id'),
        _TokenMock(id: 'id2'),
      ]);
      expect(state.tokens.length, 3);
      expect((state.tokens[0] as _TokenMock).id, 'id');
      expect((state.tokens[1] as _TokenMock).id, 'id2');
      expect((state.tokens[2] as _TokenMock).id, 'id3');
      expect(newState.tokens.length, 1);
      expect((newState.tokens.first as _TokenMock).id, 'id3');
    });
    group('addOrReplaceToken', () {
      test('existing id', () {
        final state = TokenState(
          tokens: [
            _TokenMock(id: 'id'),
            _TokenMock(id: 'id2'),
          ],
        );
        final newState = state.addOrReplaceToken(
          _TokenMock(id: 'id', label: 'labelUpdated'),
        );
        expect(state.tokens.length, 2);
        expect((state.tokens.first as _TokenMock).id, 'id');
        expect((state.tokens.last as _TokenMock).id, 'id2');
        expect(newState.tokens.length, 2);
        expect((newState.tokens.first as _TokenMock).id, 'id');
        expect((newState.tokens.first as _TokenMock).label, 'labelUpdated');
      });
      test('new id', () {
        final state = TokenState(
          tokens: [
            _TokenMock(id: 'id'),
            _TokenMock(id: 'id2'),
          ],
        );
        final newState = state.addOrReplaceToken(
          _TokenMock(id: 'newId', label: 'labelUpdated'),
        );
        expect(state.tokens.length, 2);
        expect((state.tokens.first as _TokenMock).id, 'id');
        expect((state.tokens.last as _TokenMock).id, 'id2');
        expect(newState.tokens.length, 3);
        expect((newState.tokens.last as _TokenMock).id, 'newId');
        expect((newState.tokens.last as _TokenMock).label, 'labelUpdated');
      });
    });

    test('addOrReplaceTokens', () {
      final state = TokenState(
        tokens: [
          _TokenMock(id: 'id'),
          _TokenMock(id: 'id2'),
        ],
      );
      final newState = state.addOrReplaceTokens([
        _TokenMock(id: 'id', label: 'labelUpdated'),
        _TokenMock(id: 'id3'),
      ]);
      expect(state.tokens.length, 2);
      expect((state.tokens.first as _TokenMock).id, 'id');
      expect((state.tokens.last as _TokenMock).id, 'id2');
      expect(newState.tokens.length, 3);
      expect((newState.tokens[0] as _TokenMock).id, 'id');
      expect((newState.tokens[0] as _TokenMock).label, 'labelUpdated');
      expect((newState.tokens[1] as _TokenMock).id, 'id2');
      expect((newState.tokens[2] as _TokenMock).id, 'id3');
    });
  });
}

void _testContainerTokens() {
  group('TokenState.containerTokens', () {
    test('returns only privacyIDEA tokens of that container with a container origin', () {
      final state = TokenState(
        tokens: [
          _hotp('mine-1', serial: 'S1', containerSerial: 'C1', origin: _containerOrigin()),
          _totp('mine-2', serial: 'S2', containerSerial: 'C1', origin: _containerOrigin()),
          _push('mine-push', containerSerial: 'C1', origin: _containerOrigin()),
          _hotp('other-container', serial: 'S3', containerSerial: 'C2', origin: _containerOrigin()),
          _hotp('not-linked', serial: 'S4'),
          _hotp(
            'wrong-origin',
            serial: 'S5',
            containerSerial: 'C1',
            origin: _origin(TokenOriginSourceType.qrScan, isPi: true),
          ),
          _hotp(
            'non-pi',
            serial: 'S6',
            containerSerial: 'C1',
            origin: _origin(TokenOriginSourceType.container, isPi: false),
          ),
        ],
      );

      expect(_ids(state.containerTokens('C1')), [
        'mine-1',
        'mine-2',
        'mine-push',
      ]);
      expect(_ids(state.containerTokens('C2')), ['other-container']);
      expect(state.containerTokens('C3'), isEmpty);
    });
  });
}

void _testGetSameTokensAndCurrentOf() {
  group('TokenState.getSameTokens and currentOf (import duplicate detection)', () {
    test('getSameTokens maps imported tokens to their counterpart in the state', () {
      final inState1 = _hotp('state-1');
      final inState2 = _totp('state-2', serial: 'S9', issuer: 'PI');
      final state = TokenState(tokens: [inState1, inState2]);

      final imported = <Token>[
        _hotp('import-1', counter: 5), // same secret
        _totp('import-2', serial: 'S9', issuer: 'PI', secret: _secretC), // same serial and issuer
        _hotp('import-3', secret: _secretB), // new
        _totp('import-4', serial: 'S9', issuer: 'Other'), // same serial, other issuer
        _totp('import-5', secret: _secretA), // same secret as import-1 but other type
      ];

      final result = state.getSameTokens(imported);

      expect(result, hasLength(5));
      expect(result[imported[0]], same(inState1));
      expect(result[imported[1]], same(inState2));
      expect(result[imported[2]], isNull);
      expect(result[imported[3]], isNull);
      expect(result[imported[4]], isNull);
    });

    test('getSameTokens returns the first match and an empty map for no imports', () {
      final firstMatch = _hotp('state-1');
      final secondMatch = _hotp('state-2');
      final state = TokenState(tokens: [firstMatch, secondMatch]);
      final imported = _hotp('import');

      expect(state.getSameTokens([imported])[imported], same(firstMatch));
      expect(state.getSameTokens([]), isEmpty);
      expect(const TokenState(tokens: []).getSameTokens([imported])[imported], isNull);
    });

    test('currentOf finds the token of the state that is the same as the given one', () {
      final inState = _hotp('state-1', serial: 'S1');
      final state = TokenState(tokens: [inState, _hotp('state-2', serial: 'S2')]);

      expect(state.currentOf(_hotp('new-id', serial: 'S1')), same(inState));
      expect(state.currentOf(_hotp('new-id', serial: 'S3')), isNull);
    });
  });
}
