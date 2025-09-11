import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/repo/secure_storage.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;
  late MockFlutterSecureStorage mockLegacyStorage;
  late FirebaseUtils firebaseUtils;

  // Constants for keys, derived from FirebaseUtils implementation
  const legacyPrefix = FirebaseUtils.FIREBASE_TOKEN_KEY_PREFIX_LEGACY;
  const currentLegacyKey = FirebaseUtils.CURRENT_APP_TOKEN_KEY_LEGACY;
  const newLegacyKey = FirebaseUtils.NEW_APP_TOKEN_KEY_LEGACY;
  const fullCurrentLegacyKey = '${legacyPrefix}_$currentLegacyKey';
  const fullNewLegacyKey = '${legacyPrefix}_$newLegacyKey';

  const newPrefix = FirebaseUtils.FIREBASE_TOKEN_KEY_PREFIX;
  const currentNewKey = FirebaseUtils.CURRENT_APP_TOKEN_KEY;
  const newNewKey = FirebaseUtils.NEW_APP_TOKEN_KEY;
  const fullCurrentNewKey = '${newPrefix}_$currentNewKey';
  const fullNewNewKey = '${newPrefix}_$newNewKey';

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockLegacyStorage = MockFlutterSecureStorage();
    final storage = SecureStorage(storagePrefix: FirebaseUtils.FIREBASE_TOKEN_KEY_PREFIX, storage: mockStorage);
    final legacyStorage = SecureStorage(storagePrefix: FirebaseUtils.FIREBASE_TOKEN_KEY_PREFIX_LEGACY, storage: mockLegacyStorage);
    firebaseUtils = FirebaseUtils(storage: storage, legacyStorage: legacyStorage);
  });

  group('FirebaseUtils SecureStorage', () {
    group('getCurrentFirebaseToken', () {
      test('returns token from new storage if available', () async {
        when(mockStorage.read(key: fullCurrentNewKey)).thenAnswer((_) async => 'new_token');

        final token = await firebaseUtils.getCurrentFirebaseToken();

        expect(token, 'new_token');
        verify(mockStorage.read(key: fullCurrentNewKey)).called(1);
        verifyNever(mockLegacyStorage.read(key: anyNamed('key')));
      });

      test('migrates token from legacy storage if new one is not available', () async {
        when(mockStorage.read(key: fullCurrentNewKey)).thenAnswer((_) async => null);
        when(mockLegacyStorage.read(key: fullCurrentLegacyKey)).thenAnswer((_) async => 'legacy_token');
        when(mockStorage.write(key: fullCurrentNewKey, value: 'legacy_token')).thenAnswer((_) async {});
        when(mockLegacyStorage.delete(key: fullCurrentLegacyKey)).thenAnswer((_) async {});

        final token = await firebaseUtils.getCurrentFirebaseToken();

        expect(token, 'legacy_token');
        verify(mockLegacyStorage.read(key: fullCurrentLegacyKey)).called(1);
        verify(mockStorage.write(key: fullCurrentNewKey, value: 'legacy_token')).called(1);
        verify(mockLegacyStorage.delete(key: fullCurrentLegacyKey)).called(1);
      });

      test('returns null if no token is available', () async {
        when(mockStorage.read(key: fullCurrentNewKey)).thenAnswer((_) async => null);
        when(mockLegacyStorage.read(key: fullCurrentLegacyKey)).thenAnswer((_) async => null);

        final token = await firebaseUtils.getCurrentFirebaseToken();

        expect(token, isNull);
      });
    });

    group('getNewFirebaseToken', () {
      test('migrates token from legacy storage', () async {
        when(mockStorage.read(key: fullNewNewKey)).thenAnswer((_) async => null);
        when(mockLegacyStorage.read(key: fullNewLegacyKey)).thenAnswer((_) async => 'legacy_new_token');
        when(mockStorage.write(key: fullNewNewKey, value: 'legacy_new_token')).thenAnswer((_) async {});
        when(mockLegacyStorage.delete(key: fullNewLegacyKey)).thenAnswer((_) async {});

        final token = await firebaseUtils.getNewFirebaseToken();

        expect(token, 'legacy_new_token');
        verify(mockLegacyStorage.read(key: fullNewLegacyKey)).called(1);
        verify(mockStorage.write(key: fullNewNewKey, value: 'legacy_new_token')).called(1);
        verify(mockLegacyStorage.delete(key: fullNewLegacyKey)).called(1);
      });
    });

    test('setCurrentFirebaseToken writes to new storage', () async {
      when(mockStorage.write(key: fullCurrentNewKey, value: 'test_token')).thenAnswer((_) async {});

      await firebaseUtils.setCurrentFirebaseToken('test_token');

      verify(mockStorage.write(key: fullCurrentNewKey, value: 'test_token')).called(1);
    });

    test('setNewFirebaseToken writes to new storage', () async {
      when(mockStorage.write(key: fullNewNewKey, value: 'test_token')).thenAnswer((_) async {});

      await firebaseUtils.setNewFirebaseToken('test_token');

      verify(mockStorage.write(key: fullNewNewKey, value: 'test_token')).called(1);
    });
  });
}
