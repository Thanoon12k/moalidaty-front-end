
class Account {
  final int? id;
  final String generator_name;
  final String username;
  final String phone;
  final String password;
  DateTime? date_created;

  Account({
     this.id,
    required this.generator_name,
    required this.username,
    required this.password,
    required this.phone,
    this.date_created,
  });

  @override
  String toString() => generator_name;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as int,

      generator_name: json['generator_name'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String,
      date_created: DateTime.parse(json['date_created']),
    );
  }
 


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'generator_name': generator_name,
      'username': username,
      'phone': phone,
      'password': password,
      'date_created': '$date_created',
    };
  }
}
