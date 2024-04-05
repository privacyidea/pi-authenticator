import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/app_feature.dart';

void main() {
  _testAppFeatureX();
}

void _testAppFeatureX() {
  group('App Feature Extension', () {
    test('name', () {
      expect((AppFeature.patchNotes.name), equals('patchNotes'));
    });
    test('fromName', () {
      expect(AppFeature.values.byName('patchNotes'), equals(AppFeature.patchNotes));
    });
  });
}
