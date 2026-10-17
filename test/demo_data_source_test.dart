import 'package:flutter_test/flutter_test.dart';
import 'package:moalidatna/core/data/app_error.dart';
import 'package:moalidatna/core/data/data_source.dart';
import 'package:moalidatna/core/data/demo_data_source.dart';
import 'package:moalidatna/features/receipts/models/receipt.dart';

/// The demo backend must enforce the same rules as the database policies.
void main() {
  late DemoDataSource ds;
  final now = DateTime(2026, 10, 17, 12);

  setUp(() => ds = DemoDataSource(now: now));

  test('rejects wrong credentials', () async {
    expect(() => ds.signIn(LoginKind.account, 'مولدة الكرخ', 'nope'), throwsA(isA<AppException>()));
    expect(() => ds.signIn(LoginKind.worker, '07799999999', 'worker123'), throwsA(isA<AppException>()));
  });

  test('worker receipts are always in the worker\'s name', () async {
    final p = await ds.signIn(LoginKind.worker, '07720000001', 'worker123');
    expect(p.isWorker, isTrue);
    final unpaid = (await ds.fetchSubscribers()).firstWhere((s) => s.name == 'علي كريم جاسم'); // A-03
    final r = await ds.addReceipt(ReceiptInput(
      subscriberId: unpaid.id,
      workerId: 2, // tries to record it for a colleague
      year: 2026,
      month: 10,
      amberPrice: 13000,
      amountPaid: 13000.0 * unpaid.ambers,
    ));
    expect(r.workerId, p.workerId);
  });

  test('one receipt per subscriber per month', () async {
    await ds.signIn(LoginKind.account, 'مولدة الكرخ', 'test1234');
    final paid = (await ds.fetchReceipts()).first;
    expect(
      () => ds.addReceipt(ReceiptInput(
        subscriberId: paid.subscriberId,
        workerId: null,
        year: paid.year,
        month: paid.month,
        amberPrice: paid.amberPrice,
        amountPaid: paid.amountPaid,
      )),
      throwsA(isA<AppException>()),
    );
  });

  test('workers cannot manage budgets, receipts or workers', () async {
    await ds.signIn(LoginKind.worker, '07720000001', 'worker123');
    final receipt = (await ds.fetchReceipts()).first;
    expect(() => ds.deleteReceipt(receipt.id), throwsA(isA<AppException>()));
    expect(() => ds.addBudget(2027, 1, 1000), throwsA(isA<AppException>()));
    expect(() => ds.createWorker('عامل', '07730000000', 'secret1'), throwsA(isA<AppException>()));
  });

  test('manager manages workers; phones stay unique', () async {
    await ds.signIn(LoginKind.account, 'مولدة الكرخ', 'test1234');
    final w = await ds.createWorker('عامل جديد', '07730000009', 'secret1');
    expect(w.isActive, isTrue);
    expect(() => ds.createWorker('آخر', '07730000009', 'secret1'), throwsA(isA<AppException>()));
    final off = await ds.setWorkerActive(w.id, false);
    expect(off.isActive, isFalse);
    expect(() => ds.signIn(LoginKind.worker, '07730000009', 'worker123'), throwsA(isA<AppException>()));
  });

  test('archived subscribers leave the list', () async {
    await ds.signIn(LoginKind.account, 'مولدة الكرخ', 'test1234');
    final before = await ds.fetchSubscribers();
    await ds.archiveSubscriber(before.first.id);
    expect((await ds.fetchSubscribers()).length, before.length - 1);
  });
}
