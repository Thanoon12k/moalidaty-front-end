import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moalidaty/features/subscripers/models/model.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty/features/workers/models/model.dart';
import 'package:moalidaty/features/workers/services/service_worker.dart';

class Reciept {
  final int? id;
  final String? yearMonthSubscriberId;
  final int year;
  final int month;
  final double amberPrice;
  final double amountPaid;
  final DateTime? dateCreated;
  final DateTime? dateReceived;
  final String? imageUrl;
  final XFile? imageFile; // for POST/uploading
  final int subscriber;
  final int? worker;
  Subscriper? subscriperObj;
  Gen_Worker? workerObj;

  Reciept({
    this.id,
    this.yearMonthSubscriberId,
    required this.year,
    required this.month,
    required this.amberPrice,
    required this.amountPaid,
    this.dateCreated,
    this.dateReceived,
    this.imageUrl,
    this.imageFile,
    required this.subscriber,
    this.worker,
  }) {
    // debugPrint(
    //   "Initializing Reciept: id=$id, year=$year, month=$month, subscriber=$subscriber, worker=$worker",
    // );
    subscriperObj = Get.find<SubscribersService>().subscribersList.firstWhere(
      (s) => s.id == subscriber,
    );

    if (worker != null) {
      workerObj = Get.find<WorkerService>().workersList.firstWhere(
        (w) => w.id == worker,
      );
    }
  }

  String get subscriberName => subscriperObj?.name ?? "id-$subscriber";

  String get subscriperCircuitNummber =>
      subscriperObj?.circuit_number ?? "id-$subscriber";
  String get workerName => workerObj?.name ?? "no worker -$worker";

  factory Reciept.fromJson(Map<String, dynamic> json) {
    return Reciept(
      id: json['id'] as int?,
      yearMonthSubscriberId: json['year_month_subscriber_id'] as String?,
      year: json['year'] as int,
      month: json['month'] as int,
      amberPrice: double.tryParse(json['amber_price'].toString()) ?? 0.0,
      amountPaid: double.tryParse(json['amount_paid'].toString()) ?? 0.0,
      dateCreated: json['date_created'] != null
          ? DateTime.tryParse(json['date_created'])
          : null,
      dateReceived: json['date_received'] != null
          ? DateTime.tryParse(json['date_received'])
          : null,
      imageUrl: json['image'] as String?,
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
      'image': imageFile,
      'subscriber': subscriber,
      'worker': worker,
    };
  }
}
