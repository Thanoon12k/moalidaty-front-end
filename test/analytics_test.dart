import 'package:flutter_test/flutter_test.dart';
import 'package:moalidatna/core/analytics/analytics.dart';
import 'package:moalidatna/core/data/demo_data.dart';
import 'package:moalidatna/features/budgets/models/budget.dart';
import 'package:moalidatna/features/receipts/models/receipt.dart';
import 'package:moalidatna/features/subscribers/models/subscriber.dart';

Subscriber sub(int id, int ambers, {DateTime? since}) => Subscriber(
      id: id,
      generatorId: 1,
      name: 'مشترك $id',
      circuitNumber: 'A-$id',
      ambers: ambers,
      phone: '',
      dateSubscribed: since ?? DateTime(2025, 1, 1),
      isActive: true,
    );

Receipt rec(int id, Subscriber s, int year, int month, double price, {int? worker, DateTime? at}) => Receipt(
      id: id,
      generatorId: 1,
      subscriberId: s.id,
      subscriberName: s.name,
      subscriberCircuit: s.circuitNumber,
      subscriberPhone: '',
      subscriberAmbers: s.ambers,
      workerId: worker,
      workerName: worker == null ? null : 'عامل $worker',
      year: year,
      month: month,
      amberPrice: price,
      amountPaid: price * s.ambers,
      notes: '',
      dateReceived: at ?? DateTime(year, month, 5),
    );

void main() {
  group('MonthKey', () {
    test('wraps across years', () {
      expect(const MonthKey(2026, 1).previous, const MonthKey(2025, 12));
      expect(const MonthKey(2025, 12).next, const MonthKey(2026, 1));
      expect(const MonthKey(2024, 2).days, 29);
      expect(MonthKey.fromPeriod(202610), const MonthKey(2026, 10));
    });
  });

  group('Analytics', () {
    final a1 = sub(1, 5), a2 = sub(2, 3), a3 = sub(3, 10);
    final late = sub(4, 2, since: DateTime(2026, 10, 20)); // joined mid-October
    final budgets = [
      const Budget(id: 1, generatorId: 1, year: 2026, month: 9, amberPrice: 10000),
      const Budget(id: 2, generatorId: 1, year: 2026, month: 10, amberPrice: 12000),
    ];
    final receipts = [
      rec(1, a1, 2026, 9, 10000, worker: 7),
      rec(2, a2, 2026, 9, 10000),
      rec(3, a3, 2026, 9, 10000, worker: 7),
      rec(4, a1, 2026, 10, 12000, at: DateTime(2026, 10, 3)),
      rec(5, a3, 2026, 10, 12000, worker: 7, at: DateTime(2026, 10, 9)),
    ];
    final a = Analytics(subscribers: [a1, a2, a3, late], budgets: budgets, receipts: receipts);

    test('months come from budgets, oldest first', () {
      expect(a.months, [const MonthKey(2026, 9), const MonthKey(2026, 10)]);
    });

    test('summary counts only subscribers due in that month', () {
      final sep = a.summary(const MonthKey(2026, 9));
      expect(sep.dueCount, 3); // the late subscriber joined in October
      expect(sep.paidCount, 3);
      expect(sep.collected, 180000);
      expect(sep.expected, 180000);
      expect(sep.rate, 1);

      final oct = a.summary(const MonthKey(2026, 10));
      expect(oct.dueCount, 4);
      expect(oct.paidCount, 2);
      expect(oct.unpaidCount, 2);
      expect(oct.collected, 12000 * 15);
      expect(oct.expected, 12000 * 20);
      expect(oct.remaining, 12000 * 5);
    });

    test('unpaid list is biggest subscription first', () {
      expect(a.unpaidIn(const MonthKey(2026, 10)).map((s) => s.id), [2, 4]);
    });

    test('change vs previous month', () {
      expect(a.changeVsPrevious(const MonthKey(2026, 10)), closeTo((180000 - 180000) / 180000, 1e-9));
      expect(a.changeVsPrevious(const MonthKey(2026, 9)), isNull);
    });

    test('daily running total ends at the month total', () {
      final daily = a.dailyCumulative(const MonthKey(2026, 10));
      expect(daily.length, 31);
      expect(daily[1], 0);
      expect(daily[2], 60000);
      expect(daily.last, 180000);
      expect(a.dailyCumulative(const MonthKey(2026, 10), until: DateTime(2026, 10, 5)).length, 5);
    });

    test('amber buckets cover every active subscriber', () {
      final b = a.amberBuckets();
      expect(b.map((x) => x.subscribers), [2, 1, 1, 0]);
      expect(b.fold(0, (s, x) => s + x.ambers), a.totalAmbers);
    });

    test('collectors add up to the total, manager included', () {
      final c = a.collectors();
      expect(c.fold(0.0, (s, x) => s + x.amount), a.totalCollected);
      expect(c.map((x) => x.name), containsAll(['عامل 7', Analytics.managerLabel]));
    });

    test('standings', () {
      expect(a.standing(a2).unpaidMonths, 1);
      expect(a.standing(late).unpaidMonths, 1);
      expect(a.mostLate().first.subscriber.id, 2);
      expect(a.topPayers(1).single.subscriber.id, 3);
    });
  });

  group('DemoData', () {
    test('matches supabase/seed.sql for the first generator', () {
      final d = DemoData.generate(DateTime(2026, 10, 17, 12));
      expect(d.subscribers, hasLength(12));
      expect(d.workers, hasLength(2));
      expect(d.budgets, hasLength(8));
      expect(d.budgets.first.label, 'أكتوبر 2026');
      expect(d.budgets.last.label, 'مارس 2026');
      // Current month: every 3rd subscriber still unpaid.
      final a = Analytics(subscribers: d.subscribers, budgets: d.budgets, receipts: d.receipts);
      final now = a.summary(const MonthKey(2026, 10));
      expect(now.paidCount, 8);
      expect(now.unpaidCount, 4);
      // No receipt is dated in the future.
      expect(d.receipts.every((r) => !r.dateReceived.isAfter(DateTime(2026, 10, 17, 12))), isTrue);
      // One receipt per subscriber per month.
      final keys = d.receipts.map((r) => '${r.subscriberId}-${r.period}').toSet();
      expect(keys.length, d.receipts.length);
    });
  });
}
