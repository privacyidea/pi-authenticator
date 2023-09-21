mixin SortableMixin {
  int? get sortIndex;

  SortableMixin copyWith({int? sortIndex});

  int compareTo(SortableMixin other) {
    if (sortIndex == null) {
      if (other.sortIndex == null) return 0;
      return 1;
    }
    if (other.sortIndex == null) return -1;

    return sortIndex!.compareTo(other.sortIndex!);
  }
}
