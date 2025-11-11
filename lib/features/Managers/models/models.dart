import 'dart:convert';

class Manager {
  final int id;
  final String generator_name;
  final String? phone;
  final String? password;
  DateTime? date_created;

  Manager({
    this.id = 0,
    required this.generator_name,
    this.password,
    this.phone,
    this.date_created,
  });

  @override
  String toString() => generator_name;

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'] as int? ?? 0,
      generator_name: json['name'] as String? ?? "",
      phone: json['phone'] as String?,
      password: json['password'] as String?,
      date_created: DateTime.parse(json['date_created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': generator_name,
      'phone': phone,
      'password': password,
      'date_created': date_created,
    };
  }
}
