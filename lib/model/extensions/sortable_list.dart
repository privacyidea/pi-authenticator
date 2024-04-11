import '../mixins/sortable_mixin.dart';

extension SortableList<T extends SortableMixin> on List<T> {
  List<T> get sorted {
    var list = List<T>.from(this);
    list.sort((a, b) => a.compareTo(b));
    print('-----------------------------------');
    list.forEach((element) {
      print('sorted: ${element.runtimeType} Sortindex: ${element.sortIndex}');
    });
    print('-----------------------------------');
    return list;
  }

  List<T> fillNullIndices() {
    var list = List<T>.from(this);
    var highestIndex = fold(0, (previousValue, element) {
      if (element.sortIndex == null) return previousValue;
      if (previousValue > element.sortIndex!) return previousValue;
      return element.sortIndex!;
    });
    for (var i = 0; i < list.length; i++) {
      if (list[i].sortIndex == null) {
        highestIndex++;
        list[i] = list[i].copyWith(sortIndex: highestIndex) as T;
      }
    }
    print('-----------------------------------');
    list.forEach((element) {
      print('fillNullIndices: ${element.runtimeType} Sortindex: ${element.sortIndex}');
    });
    print('-----------------------------------');
    return list;
  }

  /// Moves the [movedItem] to the position after [moveAfter] or before [moveBefore].
  /// If both [moveAfter] and [moveBefore] are null, the [movedItem] will be moved to the end of the list.
  /// If both is set, [moveBefore] will be prioritized.
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
    print('-----------------------------------');
    list.forEach((element) {
      print('moveBetween: ${element.runtimeType} Sortindex: ${element.sortIndex}');
    });
    print('-----------------------------------');
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
