import 'package:flutter_test/flutter_test.dart';
import 'package:moalidaty1/features/reciepts/models/model.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/workers/models/model.dart';

void main() {
  group('Reciept Model Tests', () {
    late Subscriper testSubscriper;
    late Gen_Worker testWorker;

    setUp(() {
      testSubscriper = Subscriper(
        id: 1,
        name: 'Test Subscriber',
        amber: 5,
        circuit_number: 'C001',
        phone: '07712345678',
      );

      testWorker = Gen_Worker(
        id: 1,
        name: 'Test Worker',
        phone: '07798765432',
        salary: '500.0',
      );
    });

    test('should create a Reciept with required parameters', () {
      final reciept = Reciept(
        id: 1,
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 10.5,
        amount_paid: 52.5,
        worker: testWorker,
      );

      expect(reciept.id, equals(1));
      expect(reciept.date, equals(DateTime(2025, 1, 15)));
      expect(reciept.subscriper, equals(testSubscriper));
      expect(reciept.amber_price, equals(10.5));
      expect(reciept.amount_paid, equals(52.5));
      expect(reciept.worker, equals(testWorker));
    });

    test('should create a Reciept with default values', () {
      final reciept = Reciept(
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 8.0,
        amount_paid: 40.0,
      );

      expect(reciept.id, equals(0));
      expect(reciept.date, equals(DateTime(2025, 1, 15)));
      expect(reciept.subscriper, equals(testSubscriper));
      expect(reciept.image, isNull);
      expect(reciept.amber_price, equals(8.0));
      expect(reciept.amount_paid, equals(40.0));
      expect(reciept.worker, isNull);
    });

    test('should return subscriber name from getter', () {
      final reciept = Reciept(
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 10.0,
        amount_paid: 50.0,
      );

      expect(reciept.subscriberName, equals('Test Subscriber'));
    });

    test('should convert Reciept to JSON', () {
      final reciept = Reciept(
        id: 2,
        date: DateTime(2025, 1, 15, 10, 30),
        subscriper: testSubscriper,
        image: 'path/to/image.jpg',
        amber_price: 12.0,
        amount_paid: 60.0,
        worker: testWorker,
      );

      final json = reciept.toJson();

      expect(json, isA<Map<String, dynamic>>);
      expect(json['id'], equals(2));
      expect(json['date'], equals('2025-01-15T10:30:00.000'));
      expect(json['subscriper'], isA<Map<String, dynamic>>);
      expect(json['image'], equals('path/to/image.jpg'));
      expect(json['amber_price'], equals(12.0));
      expect(json['amount_paid'], equals(60.0));
      expect(json['worker'], isA<Map<String, dynamic>>);
    });

    test('should create Reciept from JSON', () {
      final json = {
        'id': 3,
        'date': '2025-01-15T14:30:00.000',
        'subscriper': {
          'id': 2,
          'name': 'JSON Subscriber',
          'Ambers': 6,
          'circuit_number': 'C002',
          'phone': '07711111111',
        },
        'image': 'path/to/json_image.jpg',
        'amber_price': 15.0,
        'amount_paid': 75.0,
        'worker': {
          'id': 2,
          'name': 'JSON Worker',
          'phone': '07722222222',
          'salary': '600.0',
        },
      };

      final reciept = Reciept.fromJson(json);

      expect(reciept.id, equals(3));
      expect(reciept.date, equals(DateTime(2025, 1, 15, 14, 30)));
      expect(reciept.subscriper.name, equals('JSON Subscriber'));
      expect(reciept.image, equals('path/to/json_image.jpg'));
      expect(reciept.amber_price, equals(15.0));
      expect(reciept.amount_paid, equals(75.0));
      expect(reciept.worker?.name, equals('JSON Worker'));
    });

    test('should create Reciept from JSON without worker', () {
      final json = {
        'id': 4,
        'date': '2025-01-15T16:00:00.000',
        'subscriper': {
          'id': 3,
          'name': 'No Worker Subscriber',
          'Ambers': 4,
          'circuit_number': 'C003',
          'phone': '07733333333',
        },
        'image': null,
        'amber_price': 10.0,
        'amount_paid': 50.0,
        'worker': null,
      };

      final reciept = Reciept.fromJson(json);

      expect(reciept.id, equals(4));
      expect(reciept.date, equals(DateTime(2025, 1, 15, 16, 0)));
      expect(reciept.subscriper.name, equals('No Worker Subscriber'));
      expect(reciept.image, isNull);
      expect(reciept.amber_price, equals(10.0));
      expect(reciept.amount_paid, equals(50.0));
      expect(reciept.worker, isNull);
    });

    test('should return formatted string in toString method', () {
      final reciept = Reciept(
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 10.0,
        amount_paid: 50.0,
      );

      final string = reciept.toString();
      expect(string, contains('reciept: Test Subscriber'));
      expect(string, contains('date: 2025-01-15'));
      expect(string, contains('amber_price: 10.0'));
      expect(string, contains('amount_paid: 50.0'));
    });

    test('should handle different numeric types in JSON', () {
      final json = {
        'id': '5',
        'date': '2025-01-15T18:00:00.000',
        'subscriper': {
          'id': 4,
          'name': 'Type Test Subscriber',
          'Ambers': 7,
          'circuit_number': 'C004',
          'phone': '07744444444',
        },
        'image': 'path/to/type_test.jpg',
        'amber_price': 20, // int instead of double
        'amount_paid': 100, // int instead of double
        'worker': null,
      };

      final reciept = Reciept.fromJson(json);

      expect(reciept.id, equals(5));
      expect(reciept.amber_price, equals(20.0));
      expect(reciept.amount_paid, equals(100.0));
    });

    test('should handle edge cases for amounts', () {
      final reciept = Reciept(
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 0.0,
        amount_paid: 0.0,
      );

      expect(reciept.amber_price, equals(0.0));
      expect(reciept.amount_paid, equals(0.0));

      final reciept2 = Reciept(
        date: DateTime(2025, 1, 15),
        subscriper: testSubscriper,
        amber_price: 999.99,
        amount_paid: 4999.95,
      );

      expect(reciept2.amber_price, equals(999.99));
      expect(reciept2.amount_paid, equals(4999.95));
    });

    test('should handle invalid date format gracefully', () {
      final json = {
        'id': 6,
        'date': 'invalid-date-format',
        'subscriper': {
          'id': 5,
          'name': 'Invalid Date Subscriber',
          'Ambers': 3,
          'circuit_number': 'C005',
          'phone': '07755555555',
        },
        'amber_price': 8.0,
        'amount_paid': 40.0,
        'worker': null,
      };

      expect(() => Reciept.fromJson(json), throwsFormatException);
    });
  });
}
