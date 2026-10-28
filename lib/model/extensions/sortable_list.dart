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
  /// A [moveBefore] or [moveAfter] that is not in the list is ignored.
  List<T> moveBetween({T? moveAfter, required T movedItem, T? moveBefore}) =>
      moveAllBetween(moveAfter: moveAfter, movedItems: [movedItem], moveBefore: moveBefore);

  List<T> moveAllBetween({T? moveAfter, required List<T> movedItems, T? moveBefore}) {
    // Look everything up before the sort indices are renumbered: TokenFolder.==
    // compares sortIndex, so a folder whose stored index has a gap no longer
    // equals the caller's copy once withCurrentSortIndexSet changed it.
    final list = List<T>.from(this).sorted;
    final removedItems = <T>[];
    for (final movedItem in movedItems) {
      final index = list.indexOf(movedItem);
      // Keep the list's current version, not the possibly older dragged copy.
      if (index != -1) removedItems.add(list.removeAt(index));
    }
    if (removedItems.isEmpty) return list.withCurrentSortIndexSet();
    final beforeIndex = moveBefore != null ? list.indexOf(moveBefore) : -1;
    final afterIndex = moveAfter != null ? list.indexOf(moveAfter) : -1;
    final newIndex = beforeIndex != -1
        ? beforeIndex
        : afterIndex != -1
            ? afterIndex + 1
            : list.length;
    list.insertAll(newIndex, removedItems);
    return list.withCurrentSortIndexSet();
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
