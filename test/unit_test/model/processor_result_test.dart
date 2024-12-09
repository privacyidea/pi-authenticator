import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';

void main() {
  _testProcessorResult();
}

void _testProcessorResult() {
  group('Processor Result', () {
    group('constructors', () {
      test('success', () {
        const result = ProcessorResultSuccess('data');
        expect(result.resultData, 'data');
      });
      test('error', () {
        const result = ProcessorResultFailed('error');
        expect(result, isA<ProcessorResultFailed>());
        expect(result.message, 'error');
      });
    });
    group('factories', () {
      test('success', () {
        const ProcessorResult<String> result = ProcessorResult.success('data');
        expect(result, isA<ProcessorResultSuccess>());
        expect((result as ProcessorResultSuccess).resultData, 'data');
      });
      test('error', () {
        const ProcessorResult<String> result = ProcessorResult.failed('error');
        expect(result, isA<ProcessorResultFailed>());
        expect((result as ProcessorResultFailed).message, 'error');
      });
    });

    group('is', () {
      test('success', () {
        const ProcessorResult<String> result = ProcessorResultSuccess('data');
        expect(result.isSuccess, isTrue);
        expect(result.isFailed, isFalse);
      });
      test('error', () {
        const ProcessorResult<String> result = ProcessorResultFailed('error');
        expect(result.isSuccess, isFalse);
        expect(result.isFailed, isTrue);
      });
    });

    group('as', () {
      test('success', () {
        const ProcessorResult<String> result = ProcessorResultSuccess('data');
        expect(result.asSuccess, 'data');
        expect(() => result.asFailed, throwsA(isA<AssertionError>()));
      });
      test('error', () {
        const ProcessorResult<String> result = ProcessorResultFailed('error');
        expect(result.asFailed, 'error');
        expect(() => result.asSuccess, throwsA(isA<AssertionError>()));
      });
    });
  });
}
