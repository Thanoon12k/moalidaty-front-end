import 'package:flutter_test/flutter_test.dart';
import 'package:moalidatna/core/utils/format.dart';
import 'package:moalidatna/core/utils/json.dart';
import 'package:moalidatna/core/utils/validators.dart';
import 'package:moalidatna/features/budgets/models/budget.dart';
import 'package:moalidatna/features/receipts/models/receipt.dart';
import 'package:moalidatna/features/receipts/ui/subscriber_qr.dart';

void main() {
  group('Validators', () {
    test('phone accepts Iraqi mobiles, Arabic digits and spacing', () {
      expect(Validators.phone('07701234567'), isNull);
      expect(Validators.phone('٠٧٧٠١٢٣٤٥٦٧'), isNull);
      expect(Validators.phone('0770 123 4567'), isNull);
      expect(Validators.phone('0770123'), isNotNull);
      expect(Validators.phone('08701234567'), isNotNull);
      expect(Validators.optionalPhone(''), isNull);
      expect(Validators.normalizePhone(' ٠٧٧٠-١٢٣ ٤٥٦٧ '), '07701234567');
    });

    test('password, ambers, price', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
      expect(Validators.ambers('0'), isNotNull);
      expect(Validators.ambers('15'), isNull);
      expect(Validators.ambers('201'), isNotNull);
      expect(Validators.price('13,000'), isNull);
      expect(Validators.price('-1'), isNotNull);
      expect(Validators.name(' a '), isNotNull);
    });
  });

  group('Fmt', () {
    test('money and compact forms', () {
      expect(Fmt.money(1250000), '1,250,000 د.ع');
      expect(Fmt.compactMoney(1250000), '1.25 مليون');
      expect(Fmt.compactMoney(65000), '65 ألف');
      expect(Fmt.axis(1250000), '1.3M');
      expect(Fmt.axis(65000), '65K');
      expect(Fmt.monthName(10), 'أكتوبر');
      expect(Fmt.percent(0.456), '46%');
    });
  });

  group('json readers', () {
    test('accept numbers as int, double or string', () {
      expect(asInt('12'), 12);
      expect(asInt(12.0), 12);
      expect(asDouble('13000.00'), 13000);
      expect(asDouble(13000), 13000);
      expect(asIntOrNull(null), isNull);
      expect('أحمد'.characters1, 'أ');
    });
  });

  group('Models', () {
    test('receipt parses the embedded subscriber and worker', () {
      final r = Receipt.fromRow({
        'id': 7,
        'generator_id': 1,
        'subscriber_id': 3,
        'worker_id': 2,
        'year': 2026,
        'month': 10,
        'amber_price': '13000.00',
        'amount_paid': 65000,
        'notes': '',
        'date_received': '2026-10-05T09:00:00Z',
        'subscriber': {'name': 'علي', 'circuit_number': 'A-3', 'phone': '', 'ambers': 5},
        'worker': {'name': 'خالد'},
      });
      expect(r.subscriberName, 'علي');
      expect(r.subscriberAmbers, 5);
      expect(r.workerName, 'خالد');
      expect(r.amberPrice, 13000);
      expect(r.number, '#00007');
      // Round trip (offline cache).
      final again = Receipt.fromRow(r.toRow());
      expect(again.subscriberName, r.subscriberName);
      expect(again.workerName, r.workerName);
      expect(again.dateReceived, r.dateReceived);
    });

    test('budget label and round trip', () {
      final b = Budget.fromRow({'id': 1, 'generator_id': 1, 'year': 2026, 'month': 3, 'amber_price': '12500.5'});
      expect(b.label, 'مارس 2026');
      expect(Budget.fromRow(b.toRow()).amberPrice, 12500.5);
    });

    test('receipt input survives the offline queue', () {
      const input = ReceiptInput(
        subscriberId: 1,
        workerId: null,
        year: 2026,
        month: 10,
        amberPrice: 13000,
        amountPaid: 65000,
        notes: ' نقداً ',
      );
      final back = ReceiptInput.fromRow(input.toRow());
      expect(back.amountPaid, 65000);
      expect(back.workerId, isNull);
      expect(back.notes, 'نقداً');
    });
  });

  group('Subscriber QR', () {
    test('round trip', () {
      expect(parseSubscriberQr(subscriberQrData(12, 3)), (12, 3));
    });

    test('rejects foreign or malformed codes', () {
      expect(parseSubscriberQr('https://example.com'), isNull);
      expect(parseSubscriberQr('moalidatna://sub/x/gen/3'), isNull);
      expect(parseSubscriberQr('moalidatna://sub/12'), isNull);
      expect(parseSubscriberQr('moalidatna://sub/12/gen/0'), isNull);
    });
  });
}
