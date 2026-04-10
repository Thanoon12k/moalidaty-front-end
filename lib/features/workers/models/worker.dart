class Worker {
  final int id;
  final int generator;
  final String generatorName;
  final String name;
  final String phone;
  final bool isActive;
  final String dateCreated;

  const Worker({
    required this.id,
    required this.generator,
    required this.generatorName,
    required this.name,
    required this.phone,
    required this.isActive,
    required this.dateCreated,
  });

  factory Worker.fromJson(Map<String, dynamic> j) => Worker(
    id:            j['id'] as int,
    generator:     j['generator'] as int,
    generatorName: j['generator_name'] as String? ?? '',
    name:          j['name'] as String,
    phone:         j['phone'] as String,
    isActive:      j['is_active'] as bool? ?? true,
    dateCreated:   j['date_created'] as String? ?? '',
  );
}
