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
        final result = ProcessorResult.success('data');
        expect(result, isA<ProcessorResultSuccess>());
        expect((result as ProcessorResultSuccess).resultData, 'data');
      });
      test('error', () {
        final result = ProcessorResult.failed('error');
        expect(result, isA<ProcessorResultFailed>());
        expect((result as ProcessorResultFailed).message, 'error');
      });
    });
  });
}
