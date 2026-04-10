class Receipt {
  final int id;
  final int generator;
  final int subscriber;
  final String subscriberName;
  final String subscriberCircuit;
  final String subscriberPhone;
  final int subscriberAmbers;
  final int? worker;
  final String? workerName;
  final int year;
  final int month;
  final double amberPrice;
  final double amountPaid;
  final String? receiptImageUrl;
  final String notes;
  final String dateReceived;

  const Receipt({
    required this.id,
    required this.generator,
    required this.subscriber,
    required this.subscriberName,
    required this.subscriberCircuit,
    required this.subscriberPhone,
    required this.subscriberAmbers,
    this.worker,
    this.workerName,
    required this.year,
    required this.month,
    required this.amberPrice,
    required this.amountPaid,
    this.receiptImageUrl,
    required this.notes,
    required this.dateReceived,
  });

  factory Receipt.fromJson(Map<String, dynamic> j) => Receipt(
    id:                j['id'] as int,
    generator:         j['generator'] as int,
    subscriber:        j['subscriber'] as int,
    subscriberName:    j['subscriber_name'] as String? ?? '',
    subscriberCircuit: j['subscriber_circuit'] as String? ?? '',
    subscriberPhone:   j['subscriber_phone'] as String? ?? '',
    subscriberAmbers:  j['subscriber_ambers'] as int? ?? 0,
    worker:            j['worker'] as int?,
    workerName:        j['worker_name'] as String?,
    year:              j['year'] as int,
    month:             j['month'] as int,
    amberPrice:        double.tryParse('${j['amber_price']}') ?? 0.0,
    amountPaid:        double.tryParse('${j['amount_paid']}') ?? 0.0,
    receiptImageUrl:   j['receipt_image_url'] as String?,
    notes:             j['notes'] as String? ?? '',
    dateReceived:      j['date_received'] as String? ?? '',
  );

  static const _months = [
    '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String get monthName => (month >= 1 && month <= 12) ? _months[month] : '$month';
  String get label     => '$monthName $year';
  String get formattedAmount => '${amountPaid.toStringAsFixed(0)} د.ع';
  String get formattedPrice  => '${amberPrice.toStringAsFixed(0)} د.ع';
}
