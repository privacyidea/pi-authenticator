abstract class ProcessorResult<T> {
  const ProcessorResult();
  factory ProcessorResult.success(T data) => ProcessorResultSuccess(data);
  factory ProcessorResult.failed(String errorMessage) => ProcessorResultFailed(errorMessage);
}

class ProcessorResultSuccess<T> implements ProcessorResult<T> {
  final T resultData;
  const ProcessorResultSuccess(this.resultData);

  @override
  String toString() {
    return 'ProcessorResultSuccess(data: $resultData)';
  }
}

class ProcessorResultFailed<T> implements ProcessorResult<T> {
  final String message;
  const ProcessorResultFailed(this.message);

  @override
  String toString() => '$runtimeType(message: $message)';
}
