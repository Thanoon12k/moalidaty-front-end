import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/workers/models/model.dart';

class Reciept {
  final int id;
  final DateTime date;
  final Subscriper subscriper;
  final String? image;
  final double amber_price;
  final double amount_paid;
  final Gen_Worker? worker;
  Reciept({
    this.id = 0,
    required this.date,
    required this.subscriper,
    this.image,
    required this.amber_price,
    required this.amount_paid,
    this.worker,
  });

  String get subscriberName => subscriper.name ;

  @override
  String toString() =>
      "reciept: ${subscriper.name}, date: $date, amber_price: $amber_price, amount_paid: $amount_paid";

  factory Reciept.fromJson(Map<String, dynamic> json) {
    return Reciept(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      subscriper: Subscriper.fromJson(
        json['subscriper'] as Map<String, dynamic>,
      ),
      image: json['image'] as String?,
      amber_price: (json['amber_price'] as num).toDouble(),
      amount_paid: (json['amount_paid'] as num).toDouble(),
      worker:
          json['worker'] != null
              ? Gen_Worker.fromJson(json['worker'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'subscriper': subscriper.toJson(),
      'image': image,
      'amber_price': amber_price,
      'amount_paid': amount_paid,
      'worker': worker?.toJson(),
    };
  }
}
