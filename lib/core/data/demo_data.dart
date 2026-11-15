import '../../features/budgets/models/budget.dart';
import '../../features/receipts/models/receipt.dart';
import '../../features/subscribers/models/subscriber.dart';
import '../../features/workers/models/worker.dart';

/// The sample generator "مولدة الكرخ" — the same data supabase/seed.sql
/// creates, generated relative to [today] so the demo always looks current.
class DemoData {
  static const generatorId = 1;
  static const generatorName = 'مولدة الكرخ';
  static const managerPhone = '07701111111';

  static const _people = [
    ('أحمد علي محمد', 'A-01', 5, '07710000001'),
    ('محمد حسن عبدالله', 'A-02', 3, '07710000002'),
    ('علي كريم جاسم', 'A-03', 7, '07710000003'),
    ('زهراء حسين عبيد', 'A-04', 5, '07710000004'),
    ('عمر خالد رشيد', 'A-05', 10, '07710000005'),
    ('سارة محمود جابر', 'A-06', 5, '07710000006'),
    ('حيدر عباس كاظم', 'A-07', 4, '07710000007'),
    ('مريم سعد ناصر', 'A-08', 6, '07710000008'),
    ('يوسف طارق حميد', 'A-09', 8, '07710000009'),
    ('نور الهدى فاضل', 'A-10', 2, '07710000010'),
    ('مصطفى جواد علوان', 'A-11', 15, '07710000011'),
    ('فاطمة رحيم صالح', 'A-12', 3, ''),
  ];

  /// Amber price per month, oldest → current.
  static const _prices = [11000.0, 11500.0, 12000.0, 13500.0, 14000.0, 15000.0, 14500.0, 13000.0];

  final List<Subscriber> subscribers;
  final List<Worker> workers;
  final List<Budget> budgets;
  final List<Receipt> receipts;

  DemoData._(this.subscribers, this.workers, this.budgets, this.receipts);

  factory DemoData.generate(DateTime today) {
    final monthStart = DateTime(today.year, today.month);
    final subscribedFrom = DateTime(monthStart.year, monthStart.month - 9);

    final subscribers = [
      for (var i = 1; i <= _people.length; i++)
        Subscriber(
          id: i,
          generatorId: generatorId,
          name: _people[i - 1].$1,
          circuitNumber: _people[i - 1].$2,
          ambers: _people[i - 1].$3,
          phone: _people[i - 1].$4,
          dateSubscribed: subscribedFrom.add(Duration(days: i * 2)),
          isActive: true,
        ),
    ];

    final workers = [
      Worker(id: 1, generatorId: generatorId, name: 'خالد محمد الجبوري', phone: '07720000001',
          isActive: true, dateCreated: subscribedFrom),
      Worker(id: 2, generatorId: generatorId, name: 'سامر علي السعيدي', phone: '07720000002',
          isActive: true, dateCreated: subscribedFrom),
    ];

    final budgets = <Budget>[];
    final receipts = <Receipt>[];
    final latest = today.subtract(const Duration(hours: 1));
    var receiptId = 1;

    for (var k = 1; k <= 8; k++) {
      final start = DateTime(monthStart.year, monthStart.month - (8 - k));
      final price = _prices[k - 1];
      budgets.add(Budget(
        id: k,
        generatorId: generatorId,
        year: start.year,
        month: start.month,
        amberPrice: price,
        dateCreated: start,
      ));

      for (var i = 1; i <= subscribers.length; i++) {
        final paid = k < 8 ? (i * 7 + k * 3) % 11 != 0 : i % 3 != 0;
        if (!paid) continue;
        final s = subscribers[i - 1];
        final worker = i % 5 == 0 ? null : (i.isEven ? workers[1] : workers[0]);
        // Current month: spread over the days that have already passed.
        final span = k == 8 ? (today.day < 1 ? 1 : today.day) : 25;
        var date = start.add(Duration(days: (i * 3 + k) % span, hours: 9, minutes: i * 7));
        if (date.isAfter(latest)) date = latest;
        receipts.add(Receipt(
          id: receiptId++,
          generatorId: generatorId,
          subscriberId: s.id,
          subscriberName: s.name,
          subscriberCircuit: s.circuitNumber,
          subscriberPhone: s.phone,
          subscriberAmbers: s.ambers,
          workerId: worker?.id,
          workerName: worker?.name,
          year: start.year,
          month: start.month,
          amberPrice: price,
          amountPaid: price * s.ambers,
          notes: i % 4 == 0 ? 'تم الدفع نقداً' : '',
          dateReceived: date,
        ));
      }
    }

    budgets.sort((a, b) => b.period.compareTo(a.period));
    receipts.sort((a, b) => b.dateReceived.compareTo(a.dateReceived));
    return DemoData._(subscribers, workers, budgets, receipts);
  }
}
