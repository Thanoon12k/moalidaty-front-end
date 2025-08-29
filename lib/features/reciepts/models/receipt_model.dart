import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/workers/models/model.dart';

class Reciept {
  final int? id;
  final String? yearMonthSubscriberId;
  final int year;
  final int month;
  final double amberPrice;
  final double amountPaid;
  final DateTime? dateCreated;
  final DateTime? dateReceived;
  final String? image;
  final int subscriber;
  final int? worker;

  Subscriper? _subscriber;
  Gen_Worker? _worker;

  Reciept({
    this.id,
    this.yearMonthSubscriberId,
    required this.year,
    required this.month,
    required this.amberPrice,
    required this.amountPaid,
    this.dateCreated,
    this.dateReceived,
    this.image,
    required this.subscriber,
    this.worker,
    Subscriper? subscriberObj,
    Gen_Worker? workerObj,
  }) {
    _subscriber = subscriberObj;
    _worker = workerObj;
  }

  String get subscriberName =>
      _subscriber?.name ?? 'subscriber_num=:$subscriber';

  String get subscriperCircuitNummber => _subscriber?.circuit_number ?? "x";

  String get workerName => _worker?.name ?? 'worker_num=:$worker';
  factory Reciept.fromJson(Map<String, dynamic> json) {
    return Reciept(
      id: json['id'] as int?,
      yearMonthSubscriberId: json['year_month_subscriber_id'] as String?,
      year: json['year'] as int,
      month: json['month'] as int,
      amberPrice: double.tryParse(json['amber_price'].toString()) ?? 0.0,
      amountPaid: double.tryParse(json['amount_paid'].toString()) ?? 0.0,
      dateCreated:
          json['date_created'] != null
              ? DateTime.tryParse(json['date_created'])
              : null,
      dateReceived:
          json['date_received'] != null
              ? DateTime.tryParse(json['date_received'])
              : null,
      image: json['image'] as String?,
      subscriber: json['subscriber'] as int,
      worker: json['worker'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year_month_subscriber_id': yearMonthSubscriberId,
      'year': year,
      'month': month,
      'amber_price': amberPrice.toStringAsFixed(2),
      'amount_paid': amountPaid.toStringAsFixed(2),
      'date_created': dateCreated?.toIso8601String(),
      'date_received': dateReceived?.toIso8601String(),
      'image': image,
      'subscriber': subscriber,
      'worker': worker,
    };
  }

  void setSubscriber(Subscriper subscriberObj) {
    _subscriber = subscriberObj;
  }

  void setWorker(Gen_Worker workerObj) {
    _worker = workerObj;
  }
}
