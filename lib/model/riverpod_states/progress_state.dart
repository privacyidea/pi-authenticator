class ProgressState {
  final int max;
  final int value;

  double get progress => value / max;

  ProgressState(
    this.max,
    this.value,
  )   : assert(max >= 0),
        assert(value >= 0);

  ProgressState copyWith({int? max, int? value, bool? inProgress}) => ProgressState(max ?? this.max, value ?? this.value);
}
