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
        const result = ProcessorResultError('error');
        expect(result, isA<ProcessorResultError>());
        expect(result.errorMessage, 'error');
      });
    });
    group('factories', () {
      test('success', () {
        final result = ProcessorResult.success('data');
        expect(result, isA<ProcessorResultSuccess>());
        expect((result as ProcessorResultSuccess).resultData, 'data');
      });
      test('error', () {
        final result = ProcessorResult.error('error');
        expect(result, isA<ProcessorResultError>());
        expect((result as ProcessorResultError).errorMessage, 'error');
      });
    });
  });
}
