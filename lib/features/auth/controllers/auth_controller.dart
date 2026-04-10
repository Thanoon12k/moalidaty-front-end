import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_model.dart';

class AuthController extends GetxController {
  final _dio   = Get.find<ApiClient>().dio;
  final _store = Get.find<SecureStorage>();

  // ── Observables ────────────────────────────────────────────────────────────
  final isLoading     = false.obs;
  final errorMessage  = ''.obs;
  final generatorName = ''.obs;   // reactive — drives AppBar title

  // Current session (null before login)
  AuthSession? session;

  bool get isAccount => session?.isAccount ?? false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final hasSession = await _store.hasSession;
    if (hasSession) {
      // Rebuild session from secure storage
      final genId   = int.tryParse(await _store.generatorId ?? '') ?? 0;
      final type    = await _store.userType ?? '';
      final genName = await _store.generatorName ?? '';
      final wName   = await _store.workerName;

      session = AuthSession(
        accessToken:   (await _store.accessToken)!,
        refreshToken:  (await _store.refreshToken)!,
        type:          type,
        generatorId:   genId,
        generatorName: genName,
        workerId:      null,
        workerName:    wName,
      );
      generatorName.value = genName;   // ← update reactive title
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  // ── Account login ──────────────────────────────────────────────────────────

  Future<void> loginAsAccount({
    required String genName,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _dio.post('/auth/account/login/', data: {
        'generator_name': genName.trim(),
        'password': password.trim(),
      });
      session = AuthSession.fromJson(res.data);
      generatorName.value = session!.generatorName;  // ← update reactive title
      await _store.saveSession(res.data as Map<String, dynamic>);
      Get.offAllNamed('/home');
    } on DioException catch (e) {
      errorMessage.value = _extractError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Worker login ───────────────────────────────────────────────────────────

  Future<void> loginAsWorker({
    required String phone,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _dio.post('/auth/worker/login/', data: {
        'phone': phone.trim(),
        'password': password.trim(),
      });
      session = AuthSession.fromJson(res.data);
      generatorName.value = session!.generatorName;  // ← update reactive title
      await _store.saveSession(res.data as Map<String, dynamic>);
      Get.offAllNamed('/home');
    } on DioException catch (e) {
      errorMessage.value = _extractError(e);
    } finally {
      isLoading.value = false;
    }
  }


  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    session = null;
    generatorName.value = '';   // clear reactive title
    await _store.clearSession();
    Get.offAllNamed('/login');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) return data['detail'];
    return 'حدث خطأ في الاتصال بالخادم';
  }
}
