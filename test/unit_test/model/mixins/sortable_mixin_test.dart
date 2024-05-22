import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/mixins/sortable_mixin.dart';

void main() {
  _testSortableMixin();
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

void _testSortableMixin() {
  group('SortableMixin', () {
    group('compareTo equal', () {
      test('number', () {
        // Arrange
        final a = _SortableTestClass(sortIndex: 1, name: '1');
        final b = _SortableTestClass(sortIndex: 1, name: '1');
        // Act
        final result = a.compareTo(b);
        // Assert
        expect(result, 0);
      });
      test('null', () {
        // Arrange
        final a = _SortableTestClass(sortIndex: null, name: 'null');
        final b = _SortableTestClass(sortIndex: null, name: 'null');
        // Act
        final result = a.compareTo(b);
        // Assert
        expect(result, 0);
      });
    });
    group('compareTo a < b', () {
      test('a < b', () {
        // Arrange
        final a = _SortableTestClass(sortIndex: 1, name: '1');
        final b = _SortableTestClass(sortIndex: 2, name: '2');
        // Act
        final result = a.compareTo(b);
        // Assert
        expect(result, -1);
      });
      test('a = 1, b = null', () {
        // Arrange
        final a = _SortableTestClass(sortIndex: 1, name: '1');
        final b = _SortableTestClass(sortIndex: null, name: 'null');
        // Act
        final result = a.compareTo(b);
        // Assert
        expect(result, -1);
      });
    });
    group('compareTo a > b', () {
      test('a > b', () {
        // Arrange
        final a = _SortableTestClass(sortIndex: 2, name: '2');
        final b = _SortableTestClass(sortIndex: 1, name: '1');
        // Act
        final result = a.compareTo(b);
        // Assert
        expect(result, 1);
      });
      test('a = null, b = 1', () {
        // Arrange
        final a = _SortableTestClass(sortIndex: null, name: 'null');
        final b = _SortableTestClass(sortIndex: 1, name: '1');
        // Act
        final result = a.compareTo(b);
        // Assert
        expect(result, 1);
      });
    });
  });
}
