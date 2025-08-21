import 'package:flutter_test/flutter_test.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';

void main() {
  group('Subscriper Model Tests', () {
    test('should create a Subscriper with required parameters', () {
      final subscriper = Subscriper(
        id: 1,
        name: 'Ahmed Subscriber',
        amber: 5,
        circuit_number: 'C001',
        phone: '07712345678',
      );

      expect(subscriper.id, equals(1));
      expect(subscriper.name, equals('Ahmed Subscriber'));
      expect(subscriper.amber, equals(5));
      expect(subscriper.circuit_number, equals('C001'));
      expect(subscriper.phone, equals('07712345678'));
    });

    test('should create a Subscriper with default values', () {
      final subscriper = Subscriper(
        name: 'Default Subscriber',
        amber: 3,
      );

      expect(subscriper.id, equals(0));
      expect(subscriper.name, equals('Default Subscriber'));
      expect(subscriper.amber, equals(3));
      expect(subscriper.circuit_number, equals('0'));
      expect(subscriper.phone, equals('077'));
    });

    test('should convert Subscriper to JSON', () {
      final subscriper = Subscriper(
        id: 2,
        name: 'JSON Subscriber',
        amber: 7,
        circuit_number: 'C002',
        phone: '07798765432',
      );

      final json = subscriper.toJson();

      expect(json, isA<Map<String, dynamic>>);
      expect(json['id'], equals(2));
      expect(json['name'], equals('JSON Subscriber'));
      expect(json['Ambers'], equals(7));
      expect(json['circuit_number'], equals('C002'));
      expect(json['phone'], equals('07798765432'));
    });

    test('should create Subscriper from JSON', () {
      final json = {
        'id': 3,
        'name': 'From JSON Subscriber',
        'Ambers': 4,
        'circuit_number': 'C003',
        'phone': '07711111111',
      };

      final subscriper = Subscriper.fromJson(json);

      expect(subscriper.id, equals(3));
      expect(subscriper.name, equals('From JSON Subscriber'));
      expect(subscriper.amber, equals(4));
      expect(subscriper.circuit_number, equals('C003'));
      expect(subscriper.phone, equals('07711111111'));
    });

    test('should handle JSON with different amber field name', () {
      final json = {
        'id': 4,
        'name': 'Amber Test Subscriber',
        'Ambers': 6, // Note: JSON uses 'Ambers' but model expects 'amber'
        'circuit_number': 'C004',
        'phone': '07722222222',
      };

      final subscriper = Subscriper.fromJson(json);

      expect(subscriper.id, equals(4));
      expect(subscriper.name, equals('Amber Test Subscriber'));
      expect(subscriper.amber, equals(6));
      expect(subscriper.circuit_number, equals('C004'));
      expect(subscriper.phone, equals('07722222222'));
    });

    test('should return name in toString method', () {
      final subscriper = Subscriper(
        name: 'String Test Subscriber',
        amber: 2,
      );

      expect(subscriper.toString(), equals('String Test Subscriber'));
    });

    test('should handle different data types in JSON conversion', () {
      final json = {
        'id': '5', // String instead of int
        'name': 'Type Test Subscriber',
        'Ambers': '8', // String instead of int
        'circuit_number': 'C005',
        'phone': '07733333333',
      };

      final subscriper = Subscriper.fromJson(json);

      expect(subscriper.id, equals(5)); // Should convert string to int
      expect(subscriper.name, equals('Type Test Subscriber'));
      expect(subscriper.amber, equals(8)); // Should convert string to int
      expect(subscriper.circuit_number, equals('C005'));
      expect(subscriper.phone, equals('07733333333'));
    });

    test('should handle edge cases for amber value', () {
      final subscriper = Subscriper(
        name: 'Edge Case Subscriber',
        amber: 0,
      );

      expect(subscriper.amber, equals(0));

      final subscriper2 = Subscriper(
        name: 'Large Amber Subscriber',
        amber: 999,
      );

      expect(subscriper2.amber, equals(999));
    });

    test('should handle empty string values', () {
      final subscriper = Subscriper(
        name: '',
        amber: 1,
        circuit_number: '',
        phone: '',
      );

      expect(subscriper.name, equals(''));
      expect(subscriper.amber, equals(1));
      expect(subscriper.circuit_number, equals(''));
      expect(subscriper.phone, equals(''));
    });
  });
}
