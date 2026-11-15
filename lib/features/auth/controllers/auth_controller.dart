import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app.dart';
import '../../../core/data/app_error.dart';
import '../../../core/data/backend.dart';
import '../../../core/data/data_source.dart';
import '../../../core/data/local_cache.dart';
import '../../budgets/controllers/budget_controller.dart';
import '../../receipts/controllers/receipt_controller.dart';
import '../../subscribers/controllers/subscriber_controller.dart';
import '../../workers/controllers/worker_controller.dart';
import '../models/user_profile.dart';

class AuthController extends GetxController {
  final _backend = Get.find<Backend>();

  final profile = Rxn<UserProfile>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  StreamSubscription<AuthState>? _authSub;
  bool _signingOut = false;

  DataSource get _ds => _backend.source;
  bool get isManager => profile.value?.isManager ?? false;
  bool get isDemo => _backend.isDemo;

  @override
  void onInit() {
    super.onInit();
    if (_backend.hasRemote) {
      // A refresh token that is rejected (password changed, worker
      // deactivated…) ends the session: go back to the login screen.
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((s) {
        if (s.event == AuthChangeEvent.signedOut && profile.value != null && !isDemo && !_signingOut) {
          _endSession(message: 'انتهت الجلسة، سجّل الدخول من جديد');
        }
      });
    }
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  /// Called by the splash screen: resume a saved session or show the login.
  Future<void> bootstrap() async {
    UserProfile? restored;
    if (_backend.hasRemote) {
      try {
        restored = await _ds.restoreSession();
        await LocalCache.saveProfile(restored?.toRow());
      } catch (e) {
        // Offline start with a saved session: use the cached profile.
        final cached = await LocalCache.readProfile();
        if (isNetworkError(e) && cached != null) restored = UserProfile.fromRow(cached);
      }
    }
    if (restored == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    profile.value = restored;
    Get.offAllNamed(AppRoutes.home);
    unawaited(reloadAll());
  }

  Future<void> signIn(LoginKind kind, String identifier, String password) async {
    _backend.useRemote();
    await _start(() => _ds.signIn(kind, identifier, password));
  }

  /// Explore the app with sample data, as the manager or as a worker.
  Future<void> startDemo(LoginKind kind) async {
    _backend.useDemo();
    await _start(() => kind == LoginKind.account
        ? _ds.signIn(kind, 'مولدة الكرخ', 'test1234')
        : _ds.signIn(kind, '07720000001', 'worker123'));
  }

  Future<void> _start(Future<UserProfile> Function() signIn) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final p = await signIn();
      profile.value = p;
      if (!isDemo) await LocalCache.saveProfile(p.toRow());
      Get.offAllNamed(AppRoutes.home);
      unawaited(reloadAll());
    } catch (e) {
      errorMessage.value = describeError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads every list, then sends receipts recorded offline.
  Future<void> reloadAll() async {
    final receipts = Get.find<ReceiptController>();
    await Future.wait([
      Get.find<SubscriberController>().load(),
      Get.find<BudgetController>().load(),
      receipts.load(),
      Get.find<WorkerController>().load(),
      receipts.loadPending(),
    ]);
    await receipts.syncPending();
  }

  Future<void> changePassword(String newPassword) => _ds.changePassword(newPassword);

  Future<void> logout() async {
    _signingOut = true;
    try {
      await _ds.signOut();
    } catch (_) {
      // Offline: the local session is still cleared below.
    } finally {
      _signingOut = false;
    }
    await _endSession();
  }

  Future<void> _endSession({String? message}) async {
    profile.value = null;
    Get.find<SubscriberController>().clear();
    Get.find<BudgetController>().clear();
    Get.find<ReceiptController>().clear();
    Get.find<WorkerController>().clear();
    await LocalCache.clearSession();
    _backend.useRemote();
    errorMessage.value = message ?? '';
    Get.offAllNamed(AppRoutes.login);
  }
}
