class AppState {
  bool isLoading;
  bool isEditing;

  AppState({
    this.isLoading = false,
    this.isEditing = false,
  });

  AppState copyWith({
    bool? isLoading,
    bool? isEditing,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}
