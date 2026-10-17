import '../../../core/utils/json.dart';

/// The signed-in manager or worker (public.my_profile()).
class UserProfile {
  final String type; // 'account' | 'worker'
  final int generatorId;
  final String generatorName;
  final String phone;
  final int? workerId;
  final String? workerName;

  const UserProfile({
    required this.type,
    required this.generatorId,
    required this.generatorName,
    required this.phone,
    this.workerId,
    this.workerName,
  });

  bool get isManager => type == 'account';
  bool get isWorker => type == 'worker';

  String get displayName => isManager ? generatorName : (workerName ?? generatorName);
  String get roleLabel => isManager ? 'مدير المولدة' : 'عامل جباية';

  factory UserProfile.fromRow(Map<String, dynamic> j) => UserProfile(
        type: j['type'] as String? ?? 'worker',
        generatorId: asInt(j['generator_id']),
        generatorName: j['generator_name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        workerId: asIntOrNull(j['worker_id']),
        workerName: j['worker_name'] as String?,
      );

  Map<String, dynamic> toRow() => {
        'type': type,
        'generator_id': generatorId,
        'generator_name': generatorName,
        'phone': phone,
        'worker_id': workerId,
        'worker_name': workerName,
      };
}
