// ignore_for_file: non_constant_identifier_names

import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:moalidaty1/features/subscripers/models/model.dart';

class Budget {
  String year_month;
  int year;
  int month;
  Double amber_price;
  List<Subscriper> paid_subs;
  List<Subscriper> unpaid_subs;

  Budget({
    required this.year_month,
    this.year = 2025,
    this.month = 5,
    required this.amber_price,
    required this.paid_subs,
    required this.unpaid_subs,
  });

  @override
  String toString() => "Budget for $year-$month";


  
  Map<String, dynamic> toJson() => {
    'year__month': year_month,
    'year': year,
    'month': month,
    'amber_price': amber_price,
    'paid_subs': paid_subs,
    'unpaid_subs': unpaid_subs,
  };
}
