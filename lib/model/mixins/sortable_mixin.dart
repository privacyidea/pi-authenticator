mixin SortableMixin {
  int? get sortIndex;
  int? get dependsOnSortIndex;

  SortableMixin copyWith({int? sortIndex, int? Function() dependsOnSortIndex});

  /// Compares the sortIndex of two SortableMixin objects.
  /// Null values are considered to be the highest index.
  int compareTo(SortableMixin other) {
    if (sortIndex == null) {
      if (other.sortIndex == null) return 0;
      return 1;
    }
    if (other.sortIndex == null) return -1;

    return sortIndex!.compareTo(other.sortIndex!);
  }
}

extension SortableList<T extends SortableMixin> on List<T> {
  List<T> get sorted {
    var list = List<T>.from(this);
    var highestIndex = 0;
    for (var item in list) {
      if (item.sortIndex != null && item.sortIndex! > highestIndex) {
        highestIndex = item.sortIndex!;
      }
    }

    list.sort((a, b) => a.compareTo(b));
    for (var i = 0; i < list.length; i++) {
      if (list[i].sortIndex == null) {
        highestIndex++;
        list[i] = list[i].copyWith(sortIndex: highestIndex) as T;
      } else {
        highestIndex = list[i].sortIndex!;
      }
    }
    return list;
  }

  List<T> moveBetween({T? moveAfter, required T movedItem, T? moveBefore}) {
    var list = List<T>.from(this).sorted.withCurrentSortIndexSet();
    final success = list.remove(movedItem);
    if (!success) return list;
    final newIndex = moveBefore != null
        ? list.indexOf(moveBefore)
        : moveAfter != null && list.contains(moveAfter)
            ? list.indexOf(moveAfter) + 1
            : list.length;
    list.insert(newIndex, movedItem);
    list = list.withCurrentSortIndexSet();
    return list;
  }

  List<T> moveAllBetween({T? moveAfter, required List<T> movedItems, T? moveBefore}) {
    var list = List<T>.from(this).sorted.withCurrentSortIndexSet();
    List<T> removedItems = [];
    for (final movedItem in movedItems) {
      final success = list.remove(movedItem);
      if (success) removedItems.add(movedItem);
    }
    if (removedItems.isEmpty) return list;
    final newIndex = moveBefore != null
        ? list.indexOf(moveBefore)
        : moveAfter != null && list.contains(moveAfter)
            ? list.indexOf(moveAfter) + 1
            : list.length;
    list.insertAll(newIndex, removedItems);
    list = list.withCurrentSortIndexSet();
    return list;
  }

  List<T> withCurrentSortIndexSet() {
    final list = List<T>.from(this);
    for (var i = 0; i < list.length; i++) {
      if (list[i].sortIndex != i) {
        list[i] = list[i].copyWith(sortIndex: i) as T;
      }
    }
    return list;
  }
}
