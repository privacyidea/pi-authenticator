import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/encryption/encryption_params.dart';

void main() {
  group('EncryptionParams', () {
    test('constructor sets all fields', () {
      const params = EncryptionParams(
        algorithm: 'AES',
        mode: 'GCM',
        initVector: 'abc123',
        tag: 'tag456',
      );
      expect(params.algorithm, 'AES');
      expect(params.mode, 'GCM');
      expect(params.initVector, 'abc123');
      expect(params.tag, 'tag456');
    });

    test('fromUriMap parses correctly', () {
      final map = {
        EncryptionParams.SYNC_ENC_PARAMS_ALGORITHM: 'AES',
        EncryptionParams.SYNC_ENC_PARAMS_IV: 'iv123',
        EncryptionParams.SYNC_ENC_PARAMS_MODE: 'GCM',
        EncryptionParams.SYNC_ENC_PARAMS_TAG: 'tag789',
      };
      final params = EncryptionParams.fromUriMap(map);
      expect(params.algorithm, 'AES');
      expect(params.initVector, 'iv123');
      expect(params.mode, 'GCM');
      expect(params.tag, 'tag789');
    });

    test('toUriMap produces correct keys', () {
      const params = EncryptionParams(
        algorithm: 'AES',
        mode: 'CBC',
        initVector: 'iv',
        tag: 'tag',
      );
      final map = params.toUriMap();
      expect(map[EncryptionParams.SYNC_ENC_PARAMS_ALGORITHM], 'AES');
      expect(map[EncryptionParams.SYNC_ENC_PARAMS_IV], 'iv');
      expect(map[EncryptionParams.SYNC_ENC_PARAMS_MODE], 'CBC');
      expect(map[EncryptionParams.SYNC_ENC_PARAMS_TAG], 'tag');
    });

    test('fromUriMap and toUriMap roundtrip', () {
      const original = EncryptionParams(
        algorithm: 'AES',
        mode: 'GCM',
        initVector: 'iv_value',
        tag: 'tag_value',
      );
      final map = original.toUriMap();
      final restored = EncryptionParams.fromUriMap(map);
      expect(restored.algorithm, original.algorithm);
      expect(restored.mode, original.mode);
      expect(restored.initVector, original.initVector);
      expect(restored.tag, original.tag);
    });

    test('static constants match expected keys', () {
      expect(EncryptionParams.SYNC_ENC_PARAMS_ALGORITHM, 'algorithm');
      expect(EncryptionParams.SYNC_ENC_PARAMS_IV, 'init_vector');
      expect(EncryptionParams.SYNC_ENC_PARAMS_MODE, 'mode');
      expect(EncryptionParams.SYNC_ENC_PARAMS_TAG, 'tag');
    });
  });
}
