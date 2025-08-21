import 'package:flutter_test/flutter_test.dart';
import 'package:moalidaty1/utils/dummy_functions.dart';

void main() {
  group('DummyFunctions Tests', () {
    group('SubtractArrays', () {
      test('should subtract arrays with integers', () {
        // Arrange
        final all = [1, 2, 3, 4, 5];
        final part = [3, 5];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals([1, 2, 4]));
        expect(result.length, equals(3));
      });

      test('should subtract arrays with strings', () {
        // Arrange
        final all = ['apple', 'banana', 'cherry', 'date', 'elderberry'];
        final part = ['banana', 'date'];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals(['apple', 'cherry', 'elderberry']));
        expect(result.length, equals(3));
      });

      test('should subtract arrays with mixed types', () {
        // Arrange
        final all = [1, 'two', 3.0, true, false];
        final part = [1, true];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals(['two', 3.0, false]));
        expect(result.length, equals(3));
      });

      test('should return empty list when all elements are subtracted', () {
        // Arrange
        final all = [1, 2, 3, 4, 5];
        final part = [1, 2, 3, 4, 5];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, isEmpty);
        expect(result.length, equals(0));
      });

      test('should return original list when part is empty', () {
        // Arrange
        final all = [1, 2, 3, 4, 5];
        final part = <dynamic>[];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals(all));
        expect(result.length, equals(5));
      });

      test('should return original list when part contains no matching elements', () {
        // Arrange
        final all = [1, 2, 3, 4, 5];
        final part = [6, 7, 8, 9, 10];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals(all));
        expect(result.length, equals(5));
      });

      test('should handle duplicate elements in all array', () {
        // Arrange
        final all = [1, 2, 2, 3, 4, 4, 5];
        final part = [2, 4];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals([1, 3, 5]));
        expect(result.length, equals(3));
      });

      test('should handle duplicate elements in part array', () {
        // Arrange
        final all = [1, 2, 3, 4, 5];
        final part = [2, 2, 4, 4];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals([1, 3, 5]));
        expect(result.length, equals(3));
      });

      test('should handle null values', () {
        // Arrange
        final all = [1, null, 3, 4, 5];
        final part = [null, 4];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals([1, 3, 5]));
        expect(result.length, equals(3));
      });

      test('should handle empty all array', () {
        // Arrange
        final all = <dynamic>[];
        final part = [1, 2, 3];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, isEmpty);
        expect(result.length, equals(0));
      });

      test('should handle both arrays empty', () {
        // Arrange
        final all = <dynamic>[];
        final part = <dynamic>[];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, isEmpty);
        expect(result.length, equals(0));
      });

      test('should handle large arrays', () {
        // Arrange
        final all = List.generate(1000, (index) => index);
        final part = List.generate(100, (index) => index * 10);

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result.length, equals(900));
        expect(result.contains(5), isTrue);
        expect(result.contains(10), isFalse);
        expect(result.contains(100), isFalse);
      });

      test('should handle case-sensitive string comparison', () {
        // Arrange
        final all = ['Apple', 'apple', 'APPLE', 'Banana'];
        final part = ['Apple'];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals(['apple', 'APPLE', 'Banana']));
        expect(result.length, equals(3));
      });

      test('should handle floating point precision', () {
        // Arrange
        final all = [1.0, 1.1, 1.2, 1.3, 1.4];
        final part = [1.1, 1.3];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals([1.0, 1.2, 1.4]));
        expect(result.length, equals(3));
      });

      test('should handle boolean values', () {
        // Arrange
        final all = [true, false, true, false];
        final part = [true];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals([false, false]));
        expect(result.length, equals(2));
      });

      test('should handle custom objects', () {
        // Arrange
        final all = [
          {'id': 1, 'name': 'Alice'},
          {'id': 2, 'name': 'Bob'},
          {'id': 3, 'name': 'Charlie'},
        ];
        final part = [
          {'id': 2, 'name': 'Bob'},
        ];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result.length, equals(2));
        expect(result.contains({'id': 1, 'name': 'Alice'}), isTrue);
        expect(result.contains({'id': 3, 'name': 'Charlie'}), isTrue);
        expect(result.contains({'id': 2, 'name': 'Bob'}), isFalse);
      });

      test('should handle nested arrays', () {
        // Arrange
        final all = [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ];
        final part = [
          [4, 5, 6],
        ];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result.length, equals(2));
        expect(result.contains([1, 2, 3]), isTrue);
        expect(result.contains([7, 8, 9]), isTrue);
        expect(result.contains([4, 5, 6]), isFalse);
      });

      test('should preserve order of elements', () {
        // Arrange
        final all = [5, 2, 8, 1, 9, 3];
        final part = [2, 9];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals([5, 8, 1, 3]));
        expect(result.length, equals(4));
      });

      test('should handle special characters in strings', () {
        // Arrange
        final all = ['Hello!', 'World@', 'Test#', 'Demo$'];
        final part = ['World@', 'Demo$'];

        // Act
        final result = DummyFunctions.SubtractArrays(all, part);

        // Assert
        expect(result, equals(['Hello!', 'Test#']));
        expect(result.length, equals(2));
      });
    });
  });
}
