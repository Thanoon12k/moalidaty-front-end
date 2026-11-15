import 'dart:math' as math;

import '../../features/budgets/models/budget.dart';
import '../../features/receipts/models/receipt.dart';
import '../../features/subscribers/models/subscriber.dart';
import '../../features/workers/models/worker.dart';
import '../utils/format.dart';

/// A calendar month (year + month).
class MonthKey implements Comparable<MonthKey> {
  final int year;
  final int month;
  const MonthKey(this.year, this.month);

  factory MonthKey.of(DateTime d) => MonthKey(d.year, d.month);
  factory MonthKey.fromPeriod(int period) => MonthKey(period ~/ 100, period % 100);

  int get period => year * 100 + month;
  String get label => '${Fmt.monthName(month)} $year';
  String get shortLabel => Fmt.monthName(month);
  DateTime get start => DateTime(year, month);
  DateTime get end => DateTime(year, month + 1).subtract(const Duration(microseconds: 1));
  int get days => DateTime(year, month + 1, 0).day;
  MonthKey get previous => MonthKey.of(DateTime(year, month - 1));
  MonthKey get next => MonthKey.of(DateTime(year, month + 1));

  @override
  int compareTo(MonthKey other) => period.compareTo(other.period);
  @override
  bool operator ==(Object other) => other is MonthKey && other.period == period;
  @override
  int get hashCode => period;
}

/// Collection figures for one budget month.
class MonthSummary {
  final MonthKey key;
  final double amberPrice;
  final double collected;
  final double expected;
  final int paidCount;
  final int dueCount;
  final int receiptCount;

  const MonthSummary({
    required this.key,
    required this.amberPrice,
    required this.collected,
    required this.expected,
    required this.paidCount,
    required this.dueCount,
    required this.receiptCount,
  });

  int get unpaidCount => math.max(0, dueCount - paidCount);
  double get remaining => math.max(0, expected - collected);

  /// Share of the expected amount collected (0..1).
  double get rate => expected <= 0 ? 0 : (collected / expected).clamp(0, 1).toDouble();
}

class AmberBucket {
  final String label;
  final int subscribers;
  final int ambers;
  const AmberBucket(this.label, this.subscribers, this.ambers);
}

/// Money collected by one collector (a worker, or the manager when null).
class CollectorShare {
  final int? workerId;
  final String name;
  final int receipts;
  final double amount;
  const CollectorShare(this.workerId, this.name, this.receipts, this.amount);
}

class SubscriberStanding {
  final Subscriber subscriber;
  final double totalPaid;
  final int paidMonths;
  final int unpaidMonths;
  const SubscriberStanding(this.subscriber, this.totalPaid, this.paidMonths, this.unpaidMonths);
}

/// All derived numbers behind the dashboard and reports.
class Analytics {
  final List<Subscriber> subscribers;
  final List<Budget> budgets;
  final List<Receipt> receipts;
  final List<Worker> workers;

  Analytics({
    required this.subscribers,
    required this.budgets,
    required this.receipts,
    this.workers = const [],
  }) {
    for (final r in receipts) {
      _byMonth.putIfAbsent(r.period, () => []).add(r);
      _bySubscriber.putIfAbsent(r.subscriberId, () => []).add(r);
    }
  }

  final _byMonth = <int, List<Receipt>>{};
  final _bySubscriber = <int, List<Receipt>>{};

  static const managerLabel = 'المدير';

  List<Receipt> receiptsIn(MonthKey key) => _byMonth[key.period] ?? const [];
  List<Receipt> receiptsOf(int subscriberId) => _bySubscriber[subscriberId] ?? const [];

  Budget? budgetFor(MonthKey key) =>
      budgets.where((b) => b.year == key.year && b.month == key.month).firstOrNull;

  /// Budget months, oldest first.
  List<MonthKey> get months {
    final keys = budgets.map((b) => MonthKey(b.year, b.month)).toSet().toList()..sort();
    return keys;
  }

  /// Subscribers who owe for [key]: active and subscribed by the month's end.
  List<Subscriber> dueIn(MonthKey key) => subscribers
      .where((s) => s.isActive && (s.dateSubscribed == null || !s.dateSubscribed!.isAfter(key.end)))
      .toList();

  Set<int> paidIds(MonthKey key) => receiptsIn(key).map((r) => r.subscriberId).toSet();

  List<Subscriber> unpaidIn(MonthKey key) {
    final paid = paidIds(key);
    return dueIn(key).where((s) => !paid.contains(s.id)).toList()
      ..sort((a, b) => b.ambers.compareTo(a.ambers));
  }

  MonthSummary summary(MonthKey key) {
    final price = budgetFor(key)?.amberPrice ?? 0;
    final due = dueIn(key);
    final paid = paidIds(key);
    final rs = receiptsIn(key);
    return MonthSummary(
      key: key,
      amberPrice: price,
      collected: rs.fold(0.0, (a, r) => a + r.amountPaid),
      expected: due.fold(0.0, (a, s) => a + s.ambers * price),
      paidCount: due.where((s) => paid.contains(s.id)).length,
      dueCount: due.length,
      receiptCount: rs.length,
    );
  }

  /// One summary per budget month, oldest first.
  List<MonthSummary> monthly() => months.map(summary).toList();

  double get totalCollected => receipts.fold(0.0, (a, r) => a + r.amountPaid);

  /// Relative change of collections versus the previous month (null when the
  /// previous month had nothing). While [key] is still running ([asOf] falls
  /// inside it), both months are compared up to the same day of the month.
  double? changeVsPrevious(MonthKey key, {DateTime? asOf}) {
    double current, prev;
    if (asOf != null && MonthKey.of(asOf) == key) {
      final day = asOf.day;
      final now = dailyCumulative(key, until: asOf);
      final before = dailyCumulative(key.previous);
      current = now.isEmpty ? 0 : now.last;
      prev = before.isEmpty ? 0 : before[(day < before.length ? day : before.length) - 1];
    } else {
      current = summary(key).collected;
      prev = summary(key.previous).collected;
    }
    if (prev <= 0) return null;
    return (current - prev) / prev;
  }

  /// Running total of collections for each day of [key] (up to [until]).
  List<double> dailyCumulative(MonthKey key, {DateTime? until}) {
    var days = key.days;
    if (until != null && MonthKey.of(until) == key) days = until.day;
    final perDay = List<double>.filled(days, 0);
    for (final r in receiptsIn(key)) {
      final d = r.dateReceived;
      final i = (MonthKey.of(d) == key ? d.day : (d.isBefore(key.start) ? 1 : days)) - 1;
      perDay[i.clamp(0, days - 1)] += r.amountPaid;
    }
    var run = 0.0;
    return [for (final v in perDay) run += v];
  }

  /// Subscribers grouped by contracted ambers (ordered buckets).
  List<AmberBucket> amberBuckets() {
    const bounds = [(1, 3, '1–3 أمبير'), (4, 6, '4–6 أمبير'), (7, 10, '7–10 أمبير'), (11, 1 << 30, '11+ أمبير')];
    final active = subscribers.where((s) => s.isActive);
    return [
      for (final (lo, hi, label) in bounds)
        () {
          final group = active.where((s) => s.ambers >= lo && s.ambers <= hi);
          return AmberBucket(label, group.length, group.fold(0, (a, s) => a + s.ambers));
        }(),
    ];
  }

  int get totalAmbers => subscribers.where((s) => s.isActive).fold(0, (a, s) => a + s.ambers);

  /// Who collected the money ([key] = one month, null = all time), largest first.
  List<CollectorShare> collectors([MonthKey? key]) {
    final source = key == null ? receipts : receiptsIn(key);
    final names = {for (final w in workers) w.id: w.name};
    final count = <int?, int>{};
    final amount = <int?, double>{};
    final label = <int?, String>{};
    for (final r in source) {
      count[r.workerId] = (count[r.workerId] ?? 0) + 1;
      amount[r.workerId] = (amount[r.workerId] ?? 0) + r.amountPaid;
      label[r.workerId] ??= r.workerId == null ? managerLabel : (r.workerName ?? names[r.workerId] ?? 'عامل');
    }
    return [
      for (final id in count.keys) CollectorShare(id, label[id]!, count[id]!, amount[id]!),
    ]..sort((a, b) => b.amount.compareTo(a.amount));
  }

  SubscriberStanding standing(Subscriber s) {
    final paid = receiptsOf(s.id);
    final paidPeriods = paid.map((r) => r.period).toSet();
    final owed = months.where((m) =>
        s.dateSubscribed == null || !s.dateSubscribed!.isAfter(m.end));
    return SubscriberStanding(
      s,
      paid.fold(0.0, (a, r) => a + r.amountPaid),
      paidPeriods.length,
      owed.where((m) => !paidPeriods.contains(m.period)).length,
    );
  }

  List<SubscriberStanding> standings() =>
      subscribers.where((s) => s.isActive).map(standing).toList();

  List<SubscriberStanding> topPayers([int n = 5]) =>
      (standings()..sort((a, b) => b.totalPaid.compareTo(a.totalPaid))).take(n).toList();

  List<SubscriberStanding> mostLate([int n = 5]) => (standings()
            ..removeWhere((s) => s.unpaidMonths == 0)
            ..sort((a, b) => b.unpaidMonths != a.unpaidMonths
                ? b.unpaidMonths.compareTo(a.unpaidMonths)
                : b.subscriber.ambers.compareTo(a.subscriber.ambers)))
          .take(n)
          .toList();
}
