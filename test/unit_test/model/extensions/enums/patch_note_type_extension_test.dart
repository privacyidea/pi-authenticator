import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/patch_note_type.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/patch_note_type_extension.dart';

void main() {
  group('PatchNoteType extension', () {
    test('localizedName returns non-empty string for all types', () {
      final loc = AppLocalizationsEn();
      for (final type in PatchNoteType.values) {
        expect(type.localizedName(loc).isNotEmpty, isTrue, reason: '$type');
      }
    });

    test('all types produce distinct localized names', () {
      final loc = AppLocalizationsEn();
      final names = PatchNoteType.values
          .map((t) => t.localizedName(loc))
          .toSet();
      expect(names.length, PatchNoteType.values.length);
    });
  });
}
