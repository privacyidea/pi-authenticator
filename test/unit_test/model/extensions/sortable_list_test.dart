import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/extensions/sortable_list.dart';
import 'package:privacyidea_authenticator/model/mixins/sortable_mixin.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';

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
  operator ==(Object other) =>
      other is _SortableTestClass && other.name == name;
  @override
  int get hashCode => name.hashCode;

  @override
  String toString() =>
      "_SortableTestClass(sortIndex: $sortIndex, name: '$name')";
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
          _SortableTestClass(name: 'null'),
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
          _SortableTestClass(name: 'null'),
        ]);
      });
      test('1-5 and multible nulls', () {
        final list = <SortableMixin>[
          _SortableTestClass(name: 'null'),
          _SortableTestClass(sortIndex: 3, name: '3'),
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(sortIndex: 5, name: '5'),
          _SortableTestClass(name: 'null'),
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
          _SortableTestClass(name: 'null'),
          _SortableTestClass(name: 'null'),
        ]);
      });
    });

    group('fill Null Indices', () {
      test('1-5', () {
        final result = <SortableMixin>[
          _SortableTestClass(sortIndex: 3, name: '3'),
          _SortableTestClass(sortIndex: 1, name: '1'),
          _SortableTestClass(name: 'null'),
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
          _SortableTestClass(name: 'null'),
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
        final result = list.moveBetween(
          moveAfter: null,
          movedItem: movedItem,
          moveBefore: list[1],
        );
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
          _SortableTestClass(name: 'null'),
          _SortableTestClass(sortIndex: 2, name: '2'),
          _SortableTestClass(sortIndex: 4, name: '4'),
          _SortableTestClass(sortIndex: 8, name: '8'),
        ];
        // Act
        final result = list.moveBetween(
          moveAfter: moveAfter,
          movedItem: movedItem,
          moveBefore: moveBefore,
        );
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
    // TokenFolder.== includes sortIndex, unlike _SortableTestClass, so these
    // use the real sortables of the main view.
    group('move between tokens and folders', () {
      test('a token dropped right before a folder whose sort index has a gap', () {
        final a = _token('a', 0);
        const folder = TokenFolder(label: 'f', folderId: 1, sortIndex: 5);
        final b = _token('b', 6);

        final result = <SortableMixin>[
          a,
          folder,
          b,
        ].moveBetween(moveAfter: a, movedItem: b, moveBefore: folder);

        expect(_order(result), ['a', 'b', 'f']);
        expect(result.map((s) => s.sortIndex), [0, 1, 2]);
      });

      test('a folder dropped right before another folder whose sort index has a gap', () {
        const first = TokenFolder(label: 'first', folderId: 1, sortIndex: 0);
        final inFirst = _token('inFirst', 1);
        const second = TokenFolder(label: 'second', folderId: 2, sortIndex: 7);
        const moved = TokenFolder(label: 'moved', folderId: 3, sortIndex: 9);
        final inMoved = _token('inMoved', 10);

        final result = <SortableMixin>[first, inFirst, second, moved, inMoved]
            .moveAllBetween(
              moveAfter: inFirst,
              movedItems: [moved, inMoved],
              moveBefore: second,
            );

        expect(_order(result), [
          'first',
          'inFirst',
          'moved',
          'inMoved',
          'second',
        ]);
        expect(result.map((s) => s.sortIndex), [0, 1, 2, 3, 4]);
      });

      test('a moveBefore that is not in the list falls back to moveAfter', () {
        final a = _token('a', 0);
        final b = _token('b', 1);
        final c = _token('c', 2);
        const goneFolder = TokenFolder(label: 'gone', folderId: 9, sortIndex: 1);

        final result = <SortableMixin>[
          a,
          b,
          c,
        ].moveBetween(moveAfter: a, movedItem: c, moveBefore: goneFolder);

        expect(_order(result), ['a', 'c', 'b']);
      });

      test('the moved token is the current one from the list, not the dragged copy', () {
        final a = _token('a', 0);
        final current = _token('b', 1, label: 'current');
        final draggedCopy = _token('b', 1, label: 'stale');

        final result = <SortableMixin>[
          a,
          current,
        ].moveBetween(moveBefore: a, movedItem: draggedCopy);

        expect(result.first, isA<HOTPToken>());
        expect((result.first as HOTPToken).label, 'current');
      });
    });
  });
}

HOTPToken _token(String id, int sortIndex, {String label = ''}) => HOTPToken(
  id: id,
  label: label,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret$id',
  sortIndex: sortIndex,
);

List<String> _order(List<SortableMixin> sortables) => [
  for (final s in sortables)
    if (s is TokenFolder) s.label else (s as HOTPToken).id,
];
