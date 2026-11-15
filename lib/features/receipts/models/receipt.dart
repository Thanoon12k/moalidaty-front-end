import '../../../core/utils/format.dart';
import '../../../core/utils/json.dart';

class Receipt {
  final int id;
  final int generatorId;
  final int subscriberId;
  final String subscriberName;
  final String subscriberCircuit;
  final String subscriberPhone;
  final int subscriberAmbers;
  final int? workerId;
  final String? workerName;
  final int year;
  final int month;
  final double amberPrice;
  final double amountPaid;
  final String notes;
  final DateTime dateReceived;

  const Receipt({
    required this.id,
    required this.generatorId,
    required this.subscriberId,
    required this.subscriberName,
    required this.subscriberCircuit,
    required this.subscriberPhone,
    required this.subscriberAmbers,
    this.workerId,
    this.workerName,
    required this.year,
    required this.month,
    required this.amberPrice,
    required this.amountPaid,
    required this.notes,
    required this.dateReceived,
  });

  /// Columns + the embedded subscriber / worker selected in one request.
  static const select =
      '*, subscriber:subscribers(name, circuit_number, phone, ambers), worker:workers(name)';

  factory Receipt.fromRow(Map<String, dynamic> j) {
    final sub = (j['subscriber'] as Map?)?.cast<String, dynamic>() ?? const {};
    final worker = (j['worker'] as Map?)?.cast<String, dynamic>();
    return Receipt(
      id: asInt(j['id']),
      generatorId: asInt(j['generator_id']),
      subscriberId: asInt(j['subscriber_id']),
      subscriberName: sub['name'] as String? ?? '',
      subscriberCircuit: sub['circuit_number'] as String? ?? '',
      subscriberPhone: sub['phone'] as String? ?? '',
      subscriberAmbers: asInt(sub['ambers']),
      workerId: asIntOrNull(j['worker_id']),
      workerName: worker?['name'] as String?,
      year: asInt(j['year']),
      month: asInt(j['month']),
      amberPrice: asDouble(j['amber_price']),
      amountPaid: asDouble(j['amount_paid']),
      notes: j['notes'] as String? ?? '',
      dateReceived: asDate(j['date_received']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toRow() => {
        'id': id,
        'generator_id': generatorId,
        'subscriber_id': subscriberId,
        'subscriber': {
          'name': subscriberName,
          'circuit_number': subscriberCircuit,
          'phone': subscriberPhone,
          'ambers': subscriberAmbers,
        },
        'worker_id': workerId,
        'worker': workerName == null ? null : {'name': workerName},
        'year': year,
        'month': month,
        'amber_price': amberPrice,
        'amount_paid': amountPaid,
        'notes': notes,
        'date_received': dateReceived.toUtc().toIso8601String(),
      };

  String get monthName => Fmt.monthName(month);
  String get label => '$monthName $year';
  int get period => year * 100 + month;
  String get number => '#${id.toString().padLeft(5, '0')}';
  String get formattedAmount => Fmt.money(amountPaid);
  String get formattedPrice => Fmt.money(amberPrice);
}

/// A receipt as entered in the form (also the payload stored in the offline
/// queue while there is no connection).
class ReceiptInput {
  final int subscriberId;
  final int? workerId;
  final int year;
  final int month;
  final double amberPrice;
  final double amountPaid;
  final String notes;

  const ReceiptInput({
    required this.subscriberId,
    required this.workerId,
    required this.year,
    required this.month,
    required this.amberPrice,
    required this.amountPaid,
    this.notes = '',
  });

  Map<String, dynamic> toRow() => {
        'subscriber_id': subscriberId,
        'worker_id': workerId,
        'year': year,
        'month': month,
        'amber_price': amberPrice,
        'amount_paid': amountPaid,
        'notes': notes.trim(),
      };

  factory ReceiptInput.fromRow(Map<String, dynamic> j) => ReceiptInput(
        subscriberId: asInt(j['subscriber_id']),
        workerId: asIntOrNull(j['worker_id']),
        year: asInt(j['year']),
        month: asInt(j['month']),
        amberPrice: asDouble(j['amber_price']),
        amountPaid: asDouble(j['amount_paid']),
        notes: j['notes'] as String? ?? '',
      );

  String get label => '${Fmt.monthName(month)} $year';
}
