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

    group('tokenToKeep', () {
      // The stored token the user already placed: in a folder, in a spot of
      // the list and locked.
      final placedOld = oldToken.copyWith(
        sortIndex: 3,
        folderId: () => 7,
        isLocked: true,
      );

      test('is the new token when nothing is stored yet', () {
        expect(TokenImportEntry(newToken: newToken).tokenToKeep, same(newToken));
      });

      test('is nothing while no side of a conflict is chosen', () {
        expect(
          TokenImportEntry(newToken: newToken, oldToken: placedOld).tokenToKeep,
          isNull,
        );
      });

      test('is the stored token unchanged when it is chosen', () {
        final entry = TokenImportEntry(
          newToken: newToken,
          oldToken: placedOld,
        ).copySelect(placedOld);
        expect(entry.tokenToKeep, same(placedOld));
      });

      test('takes the data of a chosen new token but keeps where the old one was', () {
        final kept = TokenImportEntry(
          newToken: newToken,
          oldToken: placedOld,
        ).copySelect(newToken).tokenToKeep! as HOTPToken;

        expect(kept.secret, newToken.secret);
        expect(kept.label, newToken.label);
        expect(kept.id, placedOld.id);
        expect(kept.sortIndex, 3);
        expect(kept.folderId, 7);
        expect(kept.isLocked, isTrue, reason: 'a lock must not get lost');
      });

      test('hides the code of a chosen new token that the kept lock locks', () {
        // A backup stores the token as it was shown at export time.
        final shownNew = newToken.copyWith(isHidden: false);
        final kept = TokenImportEntry(
          newToken: shownNew,
          oldToken: placedOld,
        ).copySelect(shownNew).tokenToKeep!;

        expect(kept.isLocked, isTrue);
        expect(
          kept.isHidden,
          isTrue,
          reason: 'a locked token shows its code only after authentication',
        );
      });
    });
  });
}
