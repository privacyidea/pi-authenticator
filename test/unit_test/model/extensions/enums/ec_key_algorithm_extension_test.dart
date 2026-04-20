import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/ec_key_algorithm_extension.dart';

void main() {
  group('EcKeyAlgorithm extension', () {
    test('curveName roundtrip via byCurveName', () {
      for (final alg in EcKeyAlgorithm.values) {
        final curveName = alg.curveName;
        final restored = EcKeyAlgorithm.values.byCurveName(curveName);
        expect(restored, alg, reason: '$alg -> $curveName');
      }
    });

    test('byCurveName throws for unknown domain name', () {
      expect(
        () => EcKeyAlgorithm.values.byCurveName('unknown_curve'),
        throwsArgumentError,
      );
    });

    test('curveName returns non-empty string for all algorithms', () {
      for (final alg in EcKeyAlgorithm.values) {
        expect(alg.curveName.isNotEmpty, isTrue, reason: '$alg');
      }
    });

    test('validator transforms string to EcKeyAlgorithm', () {
      final result = EcKeyAlgorithmX.validator.transform('prime256v1', "test");
      expect(result, EcKeyAlgorithm.prime256v1);
    });

    test('validator transforms EcKeyAlgorithm to itself', () {
      final result = EcKeyAlgorithmX.validator.transform(
        EcKeyAlgorithm.secp256r1,
        "test",
      );
      expect(result, EcKeyAlgorithm.secp256r1);
    });

    test('validator throws for unknown string', () {
      expect(
        () => EcKeyAlgorithmX.validator.transform('not_a_curve', "test"),
        throwsArgumentError,
      );
    });
  });
}
