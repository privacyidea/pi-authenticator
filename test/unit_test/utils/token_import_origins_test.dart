import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/token_import_type.dart';
import 'package:privacyidea_authenticator/utils/token_import_origins.dart';

import '../../tests_app_wrapper.dart';

final _l = AppLocalizationsEn();

String _backupFileHint() => TokenImportOrigins
    .privacyIDEAAuthenticator
    .importSources
    .singleWhere((source) => source.type == TokenImportType.backupFile)
    .importHint(_l);

void main() {
  group('privacyIDEA backup file import hint', () {
    setUpAll(setupMocks);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('on iOS points to the app folder in the Files app', () {
      // The export writes the file to the app's Documents folder on iOS.
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(_backupFileHint(), _l.importHintPrivacyIdeaFileIos('privacyIDEA'));
    });

    test('on Android points to the Downloads folder', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(_backupFileHint(), _l.importHintPrivacyIdeaFile);
    });
  });
}
