import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/app_feature.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/app_feature_extension.dart';

void main() {
  group('AppFeature extension', () {
    test('isDisabled returns true when feature is in disabled set', () {
      final disabled = {AppFeature.patchNotes};
      expect(AppFeature.patchNotes.isDisabled(disabled), isTrue);
      expect(AppFeature.introductions.isDisabled(disabled), isFalse);
    });

    test('isEnabled returns true when feature is not in disabled set', () {
      final disabled = {AppFeature.patchNotes};
      expect(AppFeature.patchNotes.isEnabled(disabled), isFalse);
      expect(AppFeature.introductions.isEnabled(disabled), isTrue);
    });

    test('empty disabled set means all features enabled', () {
      final disabled = <AppFeature>{};
      for (final feature in AppFeature.values) {
        expect(feature.isEnabled(disabled), isTrue);
        expect(feature.isDisabled(disabled), isFalse);
      }
    });

    test('all features disabled', () {
      final disabled = AppFeature.values.toSet();
      for (final feature in AppFeature.values) {
        expect(feature.isDisabled(disabled), isTrue);
        expect(feature.isEnabled(disabled), isFalse);
      }
    });
  });
}
