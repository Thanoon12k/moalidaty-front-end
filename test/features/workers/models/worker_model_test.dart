import 'package:flutter_test/flutter_test.dart';
import 'package:moalidaty1/features/workers/models/model.dart';

void main() {
  group('Gen_Worker Model Tests', () {
    test('should create a Gen_Worker with required parameters', () {
      final worker = Gen_Worker(
        id: 1,
        name: 'Ahmed Ali',
        phone: '07712345678',
        salary: '500.0',
      );

      expect(worker.id, equals(1));
      expect(worker.name, equals('Ahmed Ali'));
      expect(worker.phone, equals('07712345678'));
      expect(worker.salary, equals('500.0'));
    });

    test('should create a Gen_Worker with default values', () {
      final worker = Gen_Worker(name: 'Default Worker');

      expect(worker.id, equals(0));
      expect(worker.name, equals('Default Worker'));
      expect(worker.phone, equals('077'));
      expect(worker.salary, equals('0.0'));
    });

    test('should create a Gen_Worker with null optional parameters', () {
      final worker = Gen_Worker(
        id: 2,
        name: 'Test Worker',
        phone: null,
        salary: null,
      );

      expect(worker.id, equals(2));
      expect(worker.name, equals('Test Worker'));
      expect(worker.phone, isNull);
      expect(worker.salary, isNull);
    });

    test('should convert Gen_Worker to JSON', () {
      final worker = Gen_Worker(
        id: 3,
        name: 'JSON Worker',
        phone: '07798765432',
        salary: '750.0',
      );

      final json = worker.toJson();

      expect(json, isA<Map<String, dynamic>>);
      expect(json['name'], equals('JSON Worker'));
      expect(json['phone'], equals('07798765432'));
      expect(json['salary'], equals('750.0'));
      expect(json.containsKey('id'), isFalse); // id is not included in toJson
    });

    test('should create Gen_Worker from JSON', () {
      final json = {
        'id': 4,
        'name': 'From JSON Worker',
        'phone': '07711111111',
        'salary': '600.0',
      };

      final worker = Gen_Worker.fromJson(json);

      expect(worker.id, equals(4));
      expect(worker.name, equals('From JSON Worker'));
      expect(worker.phone, equals('07711111111'));
      expect(worker.salary, equals('600.0'));
    });

    test('should handle JSON with null values', () {
      final json = {
        'id': 5,
        'name': 'Null Worker',
        'phone': null,
        'salary': null,
      };

      final worker = Gen_Worker.fromJson(json);

      expect(worker.id, equals(5));
      expect(worker.name, equals('Null Worker'));
      expect(worker.phone, isNull);
      expect(worker.salary, isNull);
    });

    test('should return name in toString method', () {
      final worker = Gen_Worker(name: 'String Worker');

      expect(worker.toString(), equals('String Worker'));
    });

    test('should handle different data types in JSON conversion', () {
      final json = {
        'id': '6', // String instead of int
        'name': 'Type Test Worker',
        'phone': '07722222222',
        'salary': '800.0',
      };

      final worker = Gen_Worker.fromJson(json);

      expect(worker.id, equals(6)); // Should convert string to int
      expect(worker.name, equals('Type Test Worker'));
      expect(worker.phone, equals('07722222222'));
      expect(worker.salary, equals('800.0'));
    });
  });
}
