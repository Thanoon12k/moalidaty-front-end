class Subscriper {
  int id;
  String name;
  String circuit_number;
  int amber;
  String Phone;

  Subscriper({
    this.id = 0,
    required this.name,
    required this.amber,
    this.circuit_number = "0",
    this.Phone = "077",
  });

  @override
  String toString() => name;

  factory Subscriper.fromJson(Map<String, dynamic> json) {
    return Subscriper(
      id: json["id"],
      name: json["name"],
      amber: json["amber"],
      circuit_number: json["circuit_number"],
      Phone: json["phone"],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amber': amber,
    'circuit_number': circuit_number,
    'phone': Phone,
  };
}
