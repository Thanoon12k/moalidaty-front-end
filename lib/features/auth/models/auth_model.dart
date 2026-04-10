/// Auth data models — minimal, from JWT token response
class AuthSession {
  final String accessToken;
  final String refreshToken;
  final String type;           // 'account' | 'worker'
  final int generatorId;
  final String generatorName;
  final int? workerId;
  final String? workerName;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.type,
    required this.generatorId,
    required this.generatorName,
    this.workerId,
    this.workerName,
  });

  bool get isAccount => type == 'account';
  bool get isWorker  => type == 'worker';

  /// Display name for current user
  String get displayName => isAccount ? generatorName : (workerName ?? generatorName);

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    accessToken:   json['access']          as String,
    refreshToken:  json['refresh']         as String,
    type:          json['type']            as String,
    generatorId:   json['generator_id']   as int,
    generatorName: json['generator_name'] as String,
    workerId:      json['worker_id']       as int?,
    workerName:    json['worker_name']     as String?,
  );
}
