import '../../../core/utils/json.dart';

class Subscriber {
  final int id;
  final int generatorId;
  final String name;
  final String circuitNumber;
  final int ambers;
  final String phone;
  final DateTime? dateSubscribed;
  final bool isActive;

  const Subscriber({
    required this.id,
    required this.generatorId,
    required this.name,
    required this.circuitNumber,
    required this.ambers,
    required this.phone,
    required this.dateSubscribed,
    required this.isActive,
  });

  factory Subscriber.fromRow(Map<String, dynamic> j) => Subscriber(
        id: asInt(j['id']),
        generatorId: asInt(j['generator_id']),
        name: j['name'] as String? ?? '',
        circuitNumber: j['circuit_number'] as String? ?? '',
        ambers: asInt(j['ambers']),
        phone: j['phone'] as String? ?? '',
        dateSubscribed: asDate(j['date_subscribed']),
        isActive: j['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toRow() => {
        'id': id,
        'generator_id': generatorId,
        'name': name,
        'circuit_number': circuitNumber,
        'ambers': ambers,
        'phone': phone,
        'date_subscribed': dateSubscribed?.toIso8601String().split('T').first,
        'is_active': isActive,
      };

  Subscriber copyWith({String? name, String? circuitNumber, int? ambers, String? phone, bool? isActive}) =>
      Subscriber(
        id: id,
        generatorId: generatorId,
        name: name ?? this.name,
        circuitNumber: circuitNumber ?? this.circuitNumber,
        ambers: ambers ?? this.ambers,
        phone: phone ?? this.phone,
        dateSubscribed: dateSubscribed,
        isActive: isActive ?? this.isActive,
      );

  String get initial => name.trim().isEmpty ? '؟' : name.trim().characters1;
}

/// Fields a user can enter for a subscriber.
class SubscriberInput {
  final String name;
  final String circuitNumber;
  final int ambers;
  final String phone;

  const SubscriberInput({
    required this.name,
    required this.circuitNumber,
    required this.ambers,
    required this.phone,
  });

  Map<String, dynamic> toRow() => {
        'name': name.trim(),
        'circuit_number': circuitNumber.trim(),
        'ambers': ambers,
        'phone': phone.trim(),
      };
}
