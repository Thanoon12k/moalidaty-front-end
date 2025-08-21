import 'package:flutter_test/flutter_test.dart';
import 'package:moalidaty1/features/budgets/models/model.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';

void main() {
  group('Budget Model Tests', () {
    late List<Subscriper> testPaidSubs;
    late List<Subscriper> testUnpaidSubs;

    setUp(() {
      testPaidSubs = [
        Subscriper(
          id: 1,
          name: 'Paid Subscriber 1',
          amber: 5,
          circuit_number: 'C001',
          phone: '07711111111',
        ),
        Subscriper(
          id: 2,
          name: 'Paid Subscriber 2',
          amber: 3,
          circuit_number: 'C002',
          phone: '07722222222',
        ),
      ];

      testUnpaidSubs = [
        Subscriper(
          id: 3,
          name: 'Unpaid Subscriber 1',
          amber: 4,
          circuit_number: 'C003',
          phone: '07733333333',
        ),
        Subscriper(
          id: 4,
          name: 'Unpaid Subscriber 2',
          amber: 6,
          circuit_number: 'C004',
          phone: '07744444444',
        ),
      ];
    });

    test('should create a Budget with required parameters', () {
      final budget = Budget(
        year_month: '2025-01',
        year: 2025,
        month: 1,
        amber_price: Double(10.5),
        paid_subs: testPaidSubs,
        unpaid_subs: testUnpaidSubs,
      );

      expect(budget.year_month, equals('2025-01'));
      expect(budget.year, equals(2025));
      expect(budget.month, equals(1));
      expect(budget.amber_price, equals(Double(10.5)));
      expect(budget.paid_subs, equals(testPaidSubs));
      expect(budget.unpaid_subs, equals(testUnpaidSubs));
    });

    test('should create a Budget with default values', () {
      final budget = Budget(
        year_month: '2025-05',
        amber_price: Double(12.0),
        paid_subs: testPaidSubs,
        unpaid_subs: testUnpaidSubs,
      );

      expect(budget.year_month, equals('2025-05'));
      expect(budget.year, equals(2025));
      expect(budget.month, equals(5));
      expect(budget.amber_price, equals(Double(12.0)));
      expect(budget.paid_subs, equals(testPaidSubs));
      expect(budget.unpaid_subs, equals(testUnpaidSubs));
    });

    test('should convert Budget to JSON', () {
      final budget = Budget(
        year_month: '2025-03',
        year: 2025,
        month: 3,
        amber_price: Double(15.0),
        paid_subs: testPaidSubs,
        unpaid_subs: testUnpaidSubs,
      );

      final json = budget.toJson();

      expect(json, isA<Map<String, dynamic>>);
      expect(json['year__month'], equals('2025-03'));
      expect(json['year'], equals(2025));
      expect(json['month'], equals(3));
      expect(json['amber_price'], equals(Double(15.0)));
      expect(json['paid_subs'], equals(testPaidSubs));
      expect(json['unpaid_subs'], equals(testUnpaidSubs));
    });

    test('should return formatted string in toString method', () {
      final budget = Budget(
        year_month: '2025-06',
        year: 2025,
        month: 6,
        amber_price: Double(18.0),
        paid_subs: testPaidSubs,
        unpaid_subs: testUnpaidSubs,
      );

      final string = budget.toString();
      expect(string, equals('Budget for 2025-6'));
    });

    test('should handle different year and month values', () {
      final budget1 = Budget(
        year_month: '2024-12',
        year: 2024,
        month: 12,
        amber_price: Double(20.0),
        paid_subs: testPaidSubs,
        unpaid_subs: testUnpaidSubs,
      );

      expect(budget1.year, equals(2024));
      expect(budget1.month, equals(12));

      final budget2 = Budget(
        year_month: '2026-01',
        year: 2026,
        month: 1,
        amber_price: Double(25.0),
        paid_subs: testPaidSubs,
        unpaid_subs: testUnpaidSubs,
      );

      expect(budget2.year, equals(2026));
      expect(budget2.month, equals(1));
    });

    test('should handle empty subscriber lists', () {
      final budget = Budget(
        year_month: '2025-07',
        amber_price: Double(30.0),
        paid_subs: [],
        unpaid_subs: [],
      );

      expect(budget.paid_subs, isEmpty);
      expect(budget.unpaid_subs, isEmpty);
      expect(budget.paid_subs.length, equals(0));
      expect(budget.unpaid_subs.length, equals(0));
    });

    test('should handle large subscriber lists', () {
      final largePaidList = List.generate(
        100,
        (index) => Subscriper(
          id: index + 1,
          name: 'Paid Subscriber $index',
          amber: (index % 10) + 1,
          circuit_number: 'C${index.toString().padLeft(3, '0')}',
          phone: '077${index.toString().padLeft(8, '0')}',
        ),
      );

      final largeUnpaidList = List.generate(
        50,
        (index) => Subscriper(
          id: index + 101,
          name: 'Unpaid Subscriber $index',
          amber: (index % 8) + 2,
          circuit_number: 'C${(index + 100).toString().padLeft(3, '0')}',
          phone: '077${(index + 100).toString().padLeft(8, '0')}',
        ),
      );

      final budget = Budget(
        year_month: '2025-08',
        amber_price: Double(40.0),
        paid_subs: largePaidList,
        unpaid_subs: largeUnpaidList,
      );

      expect(budget.paid_subs.length, equals(100));
      expect(budget.unpaid_subs.length, equals(50));
      expect(budget.paid_subs.first.name, equals('Paid Subscriber 0'));
      expect(budget.unpaid_subs.last.name, equals('Unpaid Subscriber 49'));
    });

    test('should handle edge cases for amber price', () {
      final budget1 = Budget(
        year_month: '2025-09',
        amber_price: Double(0.0),
        paid_subs: testPaidSubs,
        unpaid_subs: testUnpaidSubs,
      );

      expect(budget1.amber_price, equals(Double(0.0)));

      final budget2 = Budget(
        year_month: '2025-10',
        amber_price: Double(999.99),
        paid_subs: testPaidSubs,
        unpaid_subs: testUnpaidSubs,
      );

      expect(budget2.amber_price, equals(Double(999.99)));
    });

    test('should handle different year_month formats', () {
      final budget1 = Budget(
        year_month: '2024-01',
        amber_price: Double(10.0),
        paid_subs: testPaidSubs,
        unpaid_subs: testUnpaidSubs,
      );

      expect(budget1.year_month, equals('2024-01'));

      final budget2 = Budget(
        year_month: '2026-12',
        amber_price: Double(20.0),
        paid_subs: testPaidSubs,
        unpaid_subs: testUnpaidSubs,
      );

      expect(budget2.year_month, equals('2026-12'));
    });

    test('should maintain subscriber references', () {
      final budget = Budget(
        year_month: '2025-11',
        amber_price: Double(35.0),
        paid_subs: testPaidSubs,
        unpaid_subs: testUnpaidSubs,
      );

      // Modify a subscriber in the original list
      testPaidSubs.first.name = 'Modified Name';

      // The budget should reflect the change
      expect(budget.paid_subs.first.name, equals('Modified Name'));
    });
  });
}
