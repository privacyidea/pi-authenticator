import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/extensions/sortable_list.dart';
import 'package:privacyidea_authenticator/model/mixins/sortable_mixin.dart';

void main() {
  _testSortableList();
}

class _SortableTestClass with SortableMixin {
  @override
  int? sortIndex;
  String name;
  _SortableTestClass({this.sortIndex, required this.name});

  @override
  SortableMixin copyWith({int? sortIndex, String? name}) => _SortableTestClass(
        sortIndex: sortIndex ?? this.sortIndex,
        name: name ?? this.name,
      );
  @override
  operator ==(Object other) => other is _SortableTestClass && other.name == name;
  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => "_SortableTestClass(sortIndex: $sortIndex, name: '$name')";
}

void _testSortableList() {
  group('Sortable List', () {
    group('sorted', () {
      // Arrange
      test('1-5', () {
        final list = <SortableMixin>[
          _SortableTestClass(sortIndex: 3, name: '3'),
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: 5, name: '5'),
          _SortableTestClass(sortIndex: 2, name: '2'),
          _SortableTestClass(sortIndex: 4, name: '4'),
        ];
        // Act
        final result = list.sorted;
        // Assert
        expect(result, [
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: 2, name: '2'),
          _SortableTestClass(sortIndex: 3, name: '3'),
          _SortableTestClass(sortIndex: 4, name: '4'),
          _SortableTestClass(sortIndex: 5, name: '5'),
        ]);
      });
      test('with gaps', () {
        final list = <SortableMixin>[
          _SortableTestClass(sortIndex: 3, name: '3'),
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: 12, name: '12'),
          _SortableTestClass(sortIndex: 5, name: '5'),
          _SortableTestClass(sortIndex: null, name: 'null'),
          _SortableTestClass(sortIndex: 2, name: '2'),
          _SortableTestClass(sortIndex: 4, name: '4'),
          _SortableTestClass(sortIndex: 8, name: '8'),
        ];
        // Act
        final result = list.sorted;
        // Assert
        expect(result, [
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: 2, name: '2'),
          _SortableTestClass(sortIndex: 3, name: '3'),
          _SortableTestClass(sortIndex: 4, name: '4'),
          _SortableTestClass(sortIndex: 5, name: '5'),
          _SortableTestClass(sortIndex: 8, name: '8'),
          _SortableTestClass(sortIndex: 12, name: '12'),
          _SortableTestClass(sortIndex: null, name: 'null'),
        ]);
      });
      test('1-5 and multible nulls', () {
        final list = <SortableMixin>[
          _SortableTestClass(sortIndex: null, name: 'null'),
          _SortableTestClass(sortIndex: 3, name: '3'),
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: 5, name: '5'),
          _SortableTestClass(sortIndex: null, name: 'null'),
          _SortableTestClass(sortIndex: 2, name: '2'),
          _SortableTestClass(sortIndex: 4, name: '4'),
        ];
        // Act
        final result = list.sorted;
        // Assert
        expect(result, [
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: 2, name: '2'),
          _SortableTestClass(sortIndex: 3, name: '3'),
          _SortableTestClass(sortIndex: 4, name: '4'),
          _SortableTestClass(sortIndex: 5, name: '5'),
          _SortableTestClass(sortIndex: null, name: 'null'),
          _SortableTestClass(sortIndex: null, name: 'null'),
        ]);
      });
    });

    group('fill Null Indices', () {
      test('1-5', () {
        final result = <SortableMixin>[
          _SortableTestClass(sortIndex: 3, name: '3'),
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: null, name: 'null'),
          _SortableTestClass(sortIndex: 2, name: '2'),
          _SortableTestClass(sortIndex: 4, name: '4'),
        ].fillNullIndices();
        expect(result, [
          _SortableTestClass(sortIndex: 3, name: '3'),
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: 5, name: 'null'),
          _SortableTestClass(sortIndex: 2, name: '2'),
          _SortableTestClass(sortIndex: 4, name: '4'),
        ]);
      });
      test('with gaps', () {
        final result = <SortableMixin>[
          _SortableTestClass(sortIndex: 3, name: '3'),
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: 12, name: '12'),
          _SortableTestClass(sortIndex: 5, name: '5'),
          _SortableTestClass(sortIndex: null, name: 'null'),
          _SortableTestClass(sortIndex: 2, name: '2'),
          _SortableTestClass(sortIndex: 4, name: '4'),
          _SortableTestClass(sortIndex: 8, name: '8'),
        ].fillNullIndices();
        expect(result, [
          _SortableTestClass(sortIndex: 3, name: '3'),
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: 12, name: '12'),
          _SortableTestClass(sortIndex: 5, name: '5'),
          _SortableTestClass(sortIndex: 13, name: 'null'),
          _SortableTestClass(sortIndex: 2, name: '2'),
          _SortableTestClass(sortIndex: 4, name: '4'),
          _SortableTestClass(sortIndex: 8, name: '8'),
        ]);
      });
    });
    group('move between', () {
      test('1-5', () {
        final movedItem = _SortableTestClass(sortIndex: 2, name: '2');
        final moveBefore = _SortableTestClass(sortIndex: 3, name: '3');
        final list = <SortableMixin>[
          moveBefore,
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: 5, name: '5'),
          movedItem,
          _SortableTestClass(sortIndex: 4, name: '4'),
        ];
        // Act
        final result = list.moveBetween(moveAfter: null, movedItem: movedItem, moveBefore: list[1]);
        // Assert
        expect(result, [
          _SortableTestClass(sortIndex: 0, name: '2'),
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: 2, name: '3'),
          _SortableTestClass(sortIndex: 3, name: '4'),
          _SortableTestClass(sortIndex: 4, name: '5'),
        ]);
      });
      test('with gaps', () {
        final moveAfter = _SortableTestClass(sortIndex: 3, name: '3');
        final movedItem = _SortableTestClass(sortIndex: 12, name: '12');
        final moveBefore = _SortableTestClass(sortIndex: 5, name: '5');
        final list = <SortableMixin>[
          moveAfter,
          _SortableTestClass(sortIndex: 1, name: '1'),
          movedItem,
          moveBefore,
          _SortableTestClass(sortIndex: null, name: 'null'),
          _SortableTestClass(sortIndex: 2, name: '2'),
          _SortableTestClass(sortIndex: 4, name: '4'),
          _SortableTestClass(sortIndex: 8, name: '8'),
        ];
        // Act
        final result = list.moveBetween(moveAfter: moveAfter, movedItem: movedItem, moveBefore: moveBefore);
        // Assert
        expect(result, [
          _SortableTestClass(sortIndex: 0, name: '1'),
          _SortableTestClass(sortIndex: 1, name: '2'),
          _SortableTestClass(sortIndex: 2, name: '3'),
          _SortableTestClass(sortIndex: 3, name: '4'),
          _SortableTestClass(sortIndex: 4, name: '12'),
          _SortableTestClass(sortIndex: 5, name: '5'),
          _SortableTestClass(sortIndex: 6, name: '8'),
          _SortableTestClass(sortIndex: 7, name: 'null'),
        ]);
      });
    });
/*
List<T> moveBetween({T? moveAfter, required T movedItem, T? moveBefore}) {
List<T> moveAllBetween({T? moveAfter, required List<T> movedItems, T? moveBefore}) {
List<T> withCurrentSortIndexSet() {
*/
  });
}
