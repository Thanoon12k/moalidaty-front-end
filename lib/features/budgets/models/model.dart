// ignore_for_file: non_constant_identifier_names

import 'package:moalidaty1/features/subscripers/models/model.dart';

class Budget {
  final int id;
  String year_month;
  int year;
  int month;
  double amber_price;
  List<Subscriper> paid_subs;
  List<Subscriper> unpaid_subs;
  //  {
  //     "id": 1,
  //     "year_month": "2025-07",
  //     "year": 2025,
  //     "month": 7,
  //     "amber_price": "2000.00",
  //     "paid_subscribers": []
  //   },
  Budget({
    this.id = 0,
    required this.year_month,
    this.year = 2025,
    this.month = 5,
    required this.amber_price,
    required this.paid_subs,
    required this.unpaid_subs,
  });

  @override
  String toString() => "Budget for $year-$month";

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] ?? 0,
      year_month: json['year_month'] ?? '',
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
      amber_price: double.parse(json['amber_price']),
      paid_subs:
          json['paid_subscribers'] != null
              ? (json['paid_subscribers'] as List)
                  .map((sub) => Subscriper.fromJson(sub))
                  .toList()
              : [],
      unpaid_subs:
          json['unpaid_subscribers'] != null
              ? (json['unpaid_subscribers'] as List)
                  .map((sub) => Subscriper.fromJson(sub))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'year_month': year_month,
    'year': year,
    'month': month,
    'amber_price': amber_price,
    'paid_subscribers': paid_subs.map((sub) => sub.toJson()).toList(),
    'unpaid_subscribers': unpaid_subs.map((sub) => sub.toJson()).toList(),
  };
}
