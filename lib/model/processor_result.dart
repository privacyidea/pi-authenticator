class ProcessorResult<T> {
  final T? data;
  final bool success;
  final String? error;

  const ProcessorResult({
    this.data,
    required this.success,
    this.error,
  });

  @override
  String toString() {
    return 'ProcessorResult(data: $data, success: $success, error: $error)';
  }

  ProcessorResult<T> copyWith({
    T? data,
    bool? success,
    String? error,
  }) {
    return ProcessorResult<T>(
      data: data ?? this.data,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }
}
