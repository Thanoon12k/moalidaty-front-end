class Budget {
  final int id;
  final int generator;
  final int year;
  final int month;
  final double amberPrice;
  final int paidCount;
  final int unpaidCount;
  final String dateCreated;

  const Budget({
    required this.id,
    required this.generator,
    required this.year,
    required this.month,
    required this.amberPrice,
    required this.paidCount,
    required this.unpaidCount,
    required this.dateCreated,
  });

  factory Budget.fromJson(Map<String, dynamic> j) => Budget(
    id:          j['id'] as int,
    generator:   j['generator'] as int,
    year:        j['year'] as int,
    month:       j['month'] as int,
    amberPrice:  double.tryParse('${j['amber_price']}') ?? 0.0,
    paidCount:   j['paid_count'] as int? ?? 0,
    unpaidCount: j['unpaid_count'] as int? ?? 0,
    dateCreated: j['date_created'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'amber_price': amberPrice,
  };

  static const _months = [
    '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String get monthName => (month >= 1 && month <= 12) ? _months[month] : '$month';
  String get label     => '$monthName $year';
}
