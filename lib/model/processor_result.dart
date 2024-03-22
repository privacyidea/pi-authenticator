class ProcessorResult<T> {
  final T? resultData;
  final bool success;
  final String? error;

  const ProcessorResult({
    this.resultData,
    required this.success,
    this.error,
  });

  @override
  String toString() {
    return 'ProcessorResult(data: $resultData, success: $success, error: $error)';
  }

  ProcessorResult<T> copyWith({
    T? data,
    bool? success,
    String? error,
  }) {
    return ProcessorResult<T>(
      resultData: data ?? this.resultData,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }
}
