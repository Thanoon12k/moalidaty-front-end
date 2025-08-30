class Gen_Worker {
  final int id;
  final String name;
  final String? phone;
  DateTime? date_created;

  Gen_Worker({
    this.id = 0,
    required this.name,
    this.phone = "077",
    this.date_created,
  });

  @override
  String toString() => name;

  factory Gen_Worker.fromJson(Map<String, dynamic> json) {
    return Gen_Worker(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? "",
      phone: json['phone'] as String?,
      date_created: DateTime.parse(json['date_created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phone': phone, 'date_created': ''};
  }
}
