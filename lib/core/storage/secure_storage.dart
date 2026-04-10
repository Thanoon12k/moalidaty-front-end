import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SecureStorage extends GetxService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _kAccess       = 'access_token';
  static const _kRefresh      = 'refresh_token';
  static const _kType         = 'user_type';         // 'account' | 'worker'
  static const _kGeneratorId  = 'generator_id';
  static const _kGeneratorName = 'generator_name';
  static const _kWorkerId     = 'worker_id';
  static const _kWorkerName   = 'worker_name';

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<void> saveSession(Map<String, dynamic> tokenResponse) async {
    await _storage.write(key: _kAccess,        value: tokenResponse['access']);
    await _storage.write(key: _kRefresh,       value: tokenResponse['refresh']);
    await _storage.write(key: _kType,          value: tokenResponse['type']);
    await _storage.write(key: _kGeneratorId,   value: '${tokenResponse['generator_id']}');
    await _storage.write(key: _kGeneratorName, value: tokenResponse['generator_name']);
    if (tokenResponse['worker_id'] != null) {
      await _storage.write(key: _kWorkerId,   value: '${tokenResponse['worker_id']}');
    }
    if (tokenResponse['worker_name'] != null) {
      await _storage.write(key: _kWorkerName, value: tokenResponse['worker_name']);
    }
  }

  Future<void> updateAccessToken(String newToken) async {
    await _storage.write(key: _kAccess, value: newToken);
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<String?> get accessToken       => _storage.read(key: _kAccess);
  Future<String?> get refreshToken      => _storage.read(key: _kRefresh);
  Future<String?> get userType          => _storage.read(key: _kType);
  Future<String?> get generatorId       => _storage.read(key: _kGeneratorId);
  Future<String?> get generatorName     => _storage.read(key: _kGeneratorName);
  Future<String?> get workerName        => _storage.read(key: _kWorkerName);

  Future<bool> get hasSession async {
    final token = await accessToken;
    return token != null && token.isNotEmpty;
  }

  // ── Clear ──────────────────────────────────────────────────────────────────

  Future<void> clearSession() => _storage.deleteAll();
}
