class Gen_Worker {
  final int id;
  final String name;
  final String? phone;

  Gen_Worker({
    this.id = 0,
    required this.name,
    this.phone = "077",
  });

  @override
  String toString() => name;

  factory Gen_Worker.fromJson(Map<String, dynamic> json) {
    return Gen_Worker(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? "",
      phone: json['phone'] as String?,
    );
  }
  

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name, 
      'phone': phone,
    };
  }
}
