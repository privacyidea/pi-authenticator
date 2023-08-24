import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/states/token_state.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:mockito/mockito.dart';

// ignore: must_be_immutable
class _TokenMock extends Mock implements Token {
  @override
  final String label;
  @override
  final String id;
  _TokenMock({required this.id, this.label = 'label'});
}

void main() {
  _testTokenState();
}

void _testTokenState() {
  group('TokenState', () {
    test('constructor', () {
      final state = TokenState(tokens: [_TokenMock(id: 'id')]);
      expect(state.tokens.first, isA<_TokenMock>());
    });
    test('copyWith', () {
      final state = TokenState(tokens: [_TokenMock(id: 'id')]);
      final newState = state.copyWith(tokens: [_TokenMock(id: 'idCopy')]);
      expect((state.tokens.first as _TokenMock).id, 'id');
      expect((newState.tokens.first as _TokenMock).id, 'idCopy');
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
      final newState = state.withTokens([_TokenMock(id: 'newid'), _TokenMock(id: 'newid2')]);
      expect(state.tokens.length, 1);
      expect((state.tokens.first as _TokenMock).id, 'id');
      expect(newState.tokens.length, 3);
      expect((newState.tokens[0] as _TokenMock).id, 'id');
      expect((newState.tokens[1] as _TokenMock).id, 'newid');
      expect((newState.tokens[2] as _TokenMock).id, 'newid2');
    });
    test('withoutToken', () {
      final state = TokenState(tokens: [_TokenMock(id: 'id'), _TokenMock(id: 'id2')]);
      final newState = state.withoutToken(_TokenMock(id: 'id'));
      expect(state.tokens.length, 2);
      expect((state.tokens.first as _TokenMock).id, 'id');
      expect((state.tokens.last as _TokenMock).id, 'id2');
      expect(newState.tokens.length, 1);
      expect((newState.tokens.first as _TokenMock).id, 'id2');
    });
    test('withoutTokens', () {
      final state = TokenState(tokens: [_TokenMock(id: 'id'), _TokenMock(id: 'id2'), _TokenMock(id: 'id3')]);
      final newState = state.withoutTokens([_TokenMock(id: 'id'), _TokenMock(id: 'id2')]);
      expect(state.tokens.length, 3);
      expect((state.tokens[0] as _TokenMock).id, 'id');
      expect((state.tokens[1] as _TokenMock).id, 'id2');
      expect((state.tokens[2] as _TokenMock).id, 'id3');
      expect(newState.tokens.length, 1);
      expect((newState.tokens.first as _TokenMock).id, 'id3');
    });
    group('updateToken', () {
      test('existing id', () {
        final state = TokenState(tokens: [_TokenMock(id: 'id'), _TokenMock(id: 'id2')]);
        final newState = state.updateToken(_TokenMock(id: 'id', label: 'labelUpdated'));
        expect(state.tokens.length, 2);
        expect((state.tokens.first as _TokenMock).id, 'id');
        expect((state.tokens.last as _TokenMock).id, 'id2');
        expect(newState.tokens.length, 2);
        expect((newState.tokens.first as _TokenMock).id, 'id');
        expect((newState.tokens.first as _TokenMock).label, 'labelUpdated');
      });
      test('new id', () {
        final state = TokenState(tokens: [_TokenMock(id: 'id'), _TokenMock(id: 'id2')]);
        final newState = state.updateToken(_TokenMock(id: 'newId', label: 'labelUpdated'));
        expect(state.tokens.length, 2);
        expect((state.tokens.first as _TokenMock).id, 'id');
        expect((state.tokens.last as _TokenMock).id, 'id2');
        expect(newState.tokens.length, 3);
        expect((newState.tokens.last as _TokenMock).id, 'newId');
        expect((newState.tokens.last as _TokenMock).label, 'labelUpdated');
      });
    });

    test('updateTokens', () {
      final state = TokenState(tokens: [_TokenMock(id: 'id'), _TokenMock(id: 'id2')]);
      final newState = state.updateTokens([_TokenMock(id: 'id', label: 'labelUpdated'), _TokenMock(id: 'id3')]);
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
