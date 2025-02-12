import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';

void main() {
  _testProcessorResult();
}

void _testProcessorResult() {
  final l = AppLocalizationsEn();
  group('Processor Result', () {
    group('constructors', () {
      test('success', () {
        const result = ProcessorResultSuccess('data');
        expect(result.resultData, 'data');
      });
      test('error', () {
        final result = ProcessorResultFailed((_) => 'error');
        expect(result, isA<ProcessorResultFailed>());
        expect(result.message(l), 'error');
      });
    });
    group('factories', () {
      test('success', () {
        final ProcessorResult<String> result = ProcessorResult.success('data');
        expect(result, isA<ProcessorResultSuccess>());
        expect((result as ProcessorResultSuccess).resultData, 'data');
      });
      test('error', () {
        final ProcessorResult<String> result = ProcessorResult.failed((_) => 'error');
        expect(result, isA<ProcessorResultFailed>());
        expect((result as ProcessorResultFailed).message(l), 'error');
      });
    });

    group('is', () {
      test('success', () {
        final ProcessorResult<String> result = ProcessorResultSuccess('data');
        expect(result.isSuccess, isTrue);
        expect(result.isFailed, isFalse);
      });
      test('error', () {
        final ProcessorResult<String> result = ProcessorResultFailed((_) => 'error');
        expect(result.isSuccess, isFalse);
        expect(result.isFailed, isTrue);
      });
    });

    group('as', () {
      test('success', () {
        const ProcessorResult<String> result = ProcessorResultSuccess('data');
        expect(result.asSuccess?.resultData, 'data');
        expect(result.asFailed, isNull);
      });
      test('error', () {
        final ProcessorResult<String> result = ProcessorResultFailed((_) => 'error');
        expect(result.asFailed?.message(l), 'error');
        expect(result.asSuccess, isNull);
      });
    });
  });
}
