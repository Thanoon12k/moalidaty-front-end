// ignore_for_file: non_constant_identifier_names

import 'package:get/get.dart';
import 'package:moalidaty/features/subscripers/models/model.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';

class Budget {
  final int id;
  String year_month;
  int year;
  int month;
  double amber_price;
  List<dynamic> paid_subs; // IDs only, not full objects
  List<dynamic> unpaid_subs; // IDs only, not full objects
  DateTime? date_created;

  Budget({
    this.id = 0,
    required this.year_month,
    this.year = 2025,
    this.month = 5,
    required this.amber_price,
    required this.paid_subs,
    required this.unpaid_subs,
    this.date_created,
  });

  List<Subscriper> getPaidSubsObjects() {
    List<Subscriper> allsubs = Get.find<SubscribersService>().subscribersList;
    return allsubs.where((sub) => paid_subs.contains(sub.id)).toList();
  }

  List<Subscriper> getUnpaidSubsObjects() {
    List<Subscriper> allsubs = Get.find<SubscribersService>().subscribersList;
    return allsubs.where((sub) => unpaid_subs.contains(sub.id)).toList();
  }

  @override
  String toString() => "Budget for $year-$month";

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] ?? 0,
      year_month: json['year_month'] ?? '',
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
      amber_price: double.tryParse(json['amber_price'].toString()) ?? 0.0,
      paid_subs: json['paid_subscribers'] ?? [],
      unpaid_subs: json['unpaid_subscribers'] ?? [],
      date_created: json['date_created'] != null
          ? DateTime.tryParse(json['date_created'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'year_month': year_month,
    'year': year,
    'month': month,
    'amber_price': amber_price.toStringAsFixed(2),
    'paid_subscribers': paid_subs,
    'unpaid_subscribers': unpaid_subs,
    'date_created': date_created?.toIso8601String(),
  };
}
