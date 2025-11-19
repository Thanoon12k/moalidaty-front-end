class MyWorker {
  final int? id;
  final int generator;
  final String? generator_name;
  final String username;
  final String phone;
  final String password;
  DateTime? date_created;

  MyWorker({
    this.id,
    required this.generator,
    this.generator_name,
    required this.username,
    required this.password,
    required this.phone,
    this.date_created,
  });

  @override
  String toString() => username;

  factory MyWorker.fromJson(Map<String, dynamic> json) {
    return MyWorker(
      id: json['id'] as int,
      generator_name: json['generator_name'] as String,
      generator: json['generator'] as int,
      username: json['username'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String,
      date_created: DateTime.parse(json['date_created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'generator': generator,
      'generator_name': generator_name,
      'username': username,
      'phone': phone,
      'password': password,
      'date_created': '$date_created',
    };
  }
}
