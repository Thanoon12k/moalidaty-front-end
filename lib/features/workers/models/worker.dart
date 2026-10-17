import '../../../core/utils/json.dart';

class Worker {
  final int id;
  final int generatorId;
  final String name;
  final String phone;
  final bool isActive;
  final DateTime? dateCreated;

  const Worker({
    required this.id,
    required this.generatorId,
    required this.name,
    required this.phone,
    required this.isActive,
    this.dateCreated,
  });

  factory Worker.fromRow(Map<String, dynamic> j) => Worker(
        id: asInt(j['id']),
        generatorId: asInt(j['generator_id']),
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        isActive: j['is_active'] as bool? ?? true,
        dateCreated: asDate(j['date_created']),
      );

  Map<String, dynamic> toRow() => {
        'id': id,
        'generator_id': generatorId,
        'name': name,
        'phone': phone,
        'is_active': isActive,
        'date_created': dateCreated?.toUtc().toIso8601String(),
      };

  Worker copyWith({String? name, String? phone, bool? isActive}) => Worker(
        id: id,
        generatorId: generatorId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        isActive: isActive ?? this.isActive,
        dateCreated: dateCreated,
      );

  String get initial => name.trim().characters1.isEmpty ? '؟' : name.trim().characters1;
}
