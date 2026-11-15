import '../../../core/utils/format.dart';
import '../../../core/utils/json.dart';

/// The price of one amber for one month of one generator.
class Budget {
  final int id;
  final int generatorId;
  final int year;
  final int month;
  final double amberPrice;
  final DateTime? dateCreated;

  const Budget({
    required this.id,
    required this.generatorId,
    required this.year,
    required this.month,
    required this.amberPrice,
    this.dateCreated,
  });

  factory Budget.fromRow(Map<String, dynamic> j) => Budget(
        id: asInt(j['id']),
        generatorId: asInt(j['generator_id']),
        year: asInt(j['year']),
        month: asInt(j['month']),
        amberPrice: asDouble(j['amber_price']),
        dateCreated: asDate(j['date_created']),
      );

  Map<String, dynamic> toRow() => {
        'id': id,
        'generator_id': generatorId,
        'year': year,
        'month': month,
        'amber_price': amberPrice,
        'date_created': dateCreated?.toUtc().toIso8601String(),
      };

  Budget copyWith({double? amberPrice}) => Budget(
        id: id,
        generatorId: generatorId,
        year: year,
        month: month,
        amberPrice: amberPrice ?? this.amberPrice,
        dateCreated: dateCreated,
      );

  String get monthName => Fmt.monthName(month);
  String get label => '$monthName $year';

  /// Sort key: newer months first when sorted descending.
  int get period => year * 100 + month;
}
