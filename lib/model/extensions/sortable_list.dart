/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import '../mixins/sortable_mixin.dart';

extension SortableList<T extends SortableMixin> on List<T> {
  List<T> get sorted {
    var list = List<T>.from(this);
    list.sort((a, b) => a.compareTo(b));
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
