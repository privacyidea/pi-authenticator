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
}
