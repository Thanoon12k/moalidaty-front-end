class Gen_Worker {
  final String name;
  final String? phone;
  final String? salary;

  Gen_Worker({required this.name, this.phone = "077", this.salary = "0.0"});

  @override
  String toString() => name;

  factory Gen_Worker.fromJson(Map<String, dynamic> json) {
    return Gen_Worker(
      name: json['name'] as String,
      phone: json['phone'] as String?,
      salary: json['salary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone, 'salary': salary};
  }
}
