// ignore_for_file: non_constant_identifier_names

import 'package:moalidaty/constants/global_constants.dart';

class Subscriper {
  int id;
  int generator;
  String name;
  String circuit_number;
  int amber;
  String phone;
  String? barcode_data;

  Subscriper({
    this.id = 0,
    required this.generator,
    required this.name,
    required this.amber,
    this.circuit_number = "0",
    this.phone = "077",
    this.barcode_data,
  });

  @override
  String toString() => name;

  factory Subscriper.fromJson(Map<String, dynamic> json) {
    final subscriber = Subscriper(
      id: json["id"] ?? 0,
      generator: json['generator'],
      name: json["name"] ?? "",
      amber: json["Ambers"] ?? 0,
      circuit_number: json["circuit_number"] ?? "0",
      phone: json["phone"] ?? "077",
      barcode_data: json["barcode_data"],
    );

    return subscriber;
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
'generator':generator
    ,
    'name': name,
    'Ambers': amber,
    'circuit_number': circuit_number,
    'phone': phone,
    'barcode_data': barcode_data,
  };
}
