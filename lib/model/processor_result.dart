abstract class ProcessorResult<T> {
  const ProcessorResult();
  factory ProcessorResult.success(T data) => ProcessorResultSuccess(data);
  factory ProcessorResult.failed(String errorMessage) => ProcessorResultFailed(errorMessage);
  bool get isSuccess => this is ProcessorResultSuccess<T>;
  ProcessorResultSuccess<T>? get asSuccess => this is ProcessorResultSuccess<T> ? this as ProcessorResultSuccess<T> : null;
  ProcessorResultFailed<T>? get asFailed => this is ProcessorResultFailed<T> ? this as ProcessorResultFailed<T> : null;
}

class ProcessorResultSuccess<T> extends ProcessorResult<T> {
  final T resultData;
  const ProcessorResultSuccess(this.resultData);

  @override
  String toString() {
    return 'ProcessorResultSuccess(data: $resultData)';
  }
}

class ProcessorResultFailed<T> extends ProcessorResult<T> {
  final String message;
  const ProcessorResultFailed(this.message);

  @override
  String toString() => '$runtimeType(message: $message)';
}
