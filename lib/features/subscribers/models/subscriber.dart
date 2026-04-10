class Subscriber {
  final int id;
  final int generator;
  final String name;
  final String circuitNumber;
  final int ambers;
  final String phone;
  final String dateSubscribed;
  final bool isActive;

  const Subscriber({
    required this.id,
    required this.generator,
    required this.name,
    required this.circuitNumber,
    required this.ambers,
    required this.phone,
    required this.dateSubscribed,
    required this.isActive,
  });

  factory Subscriber.fromJson(Map<String, dynamic> j) => Subscriber(
    id:             j['id'] as int,
    generator:      j['generator'] as int,
    name:           j['name'] as String,
    circuitNumber:  j['circuit_number'] as String,
    ambers:         j['ambers'] as int,
    phone:          j['phone'] as String? ?? '',
    dateSubscribed: j['date_subscribed'] as String? ?? '',
    isActive:       j['is_active'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'name':           name,
    'circuit_number': circuitNumber,
    'ambers':         ambers,
    'phone':          phone,
  };
}
