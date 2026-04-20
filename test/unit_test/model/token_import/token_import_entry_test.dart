import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/token_import/token_import_entry.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';

void main() {
  group('TokenImportEntry', () {
    final newToken = HOTPToken(
      id: 'new_id',
      label: 'New Token',
      issuer: 'Test',
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: 'ABCDEFGH',
    );
    final oldToken = HOTPToken(
      id: 'old_id',
      label: 'Old Token',
      issuer: 'Test',
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: 'IJKLMNOP',
      counter: 5,
    );

    test('selectedToken defaults to newToken when no oldToken', () {
      final entry = TokenImportEntry(newToken: newToken);
      expect(entry.selectedToken, newToken);
      expect(entry.oldToken, isNull);
    });

    test('selectedToken defaults to null when oldToken exists', () {
      final entry = TokenImportEntry(newToken: newToken, oldToken: oldToken);
      expect(entry.selectedToken, isNull);
    });

    test('copySelect selects newToken', () {
      final entry = TokenImportEntry(newToken: newToken, oldToken: oldToken);
      final selected = entry.copySelect(newToken);
      expect(selected.selectedToken, newToken);
    });

    test('copySelect selects oldToken', () {
      final entry = TokenImportEntry(newToken: newToken, oldToken: oldToken);
      final selected = entry.copySelect(oldToken);
      expect(selected.selectedToken, oldToken);
    });

    test('copySelect with null deselects', () {
      final entry = TokenImportEntry(newToken: newToken, oldToken: oldToken);
      final selected = entry.copySelect(newToken);
      final deselected = selected.copySelect(null);
      expect(deselected.selectedToken, isNull);
    });

    test('equality works correctly', () {
      final a = TokenImportEntry(newToken: newToken, oldToken: oldToken);
      final b = TokenImportEntry(newToken: newToken, oldToken: oldToken);
      expect(a, equals(b));
    });
  });
}
