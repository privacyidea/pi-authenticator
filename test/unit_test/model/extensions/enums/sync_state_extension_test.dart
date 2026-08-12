import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/sync_state.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/sync_state_extension.dart';

void main() {
  group('SyncState extension', () {
    test('isIdle is true for all states except syncing', () {
      expect(SyncState.notStarted.isIdle, isTrue);
      expect(SyncState.syncing.isIdle, isFalse);
      expect(SyncState.completed.isIdle, isTrue);
      expect(SyncState.failed.isIdle, isTrue);
    });

    test('localizedName returns non-empty string for all states', () {
      final localization = AppLocalizationsEn();
      for (final state in SyncState.values) {
        expect(
          state.localizedName(localization).isNotEmpty,
          isTrue,
          reason: '$state',
        );
      }
    });
  });
}
