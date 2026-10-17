import '../../features/auth/models/user_profile.dart';
import '../../features/budgets/models/budget.dart';
import '../../features/receipts/models/receipt.dart';
import '../../features/subscribers/models/subscriber.dart';
import '../../features/workers/models/worker.dart';
import 'app_error.dart';
import 'data_source.dart';
import 'demo_data.dart';

/// In-memory backend for trying the app without a server. Applies the same
/// role rules as the database policies (supabase/migrations).
class DemoDataSource implements DataSource {
  DemoDataSource({DateTime? now}) : _now = now ?? DateTime.now() {
    final data = DemoData.generate(_now);
    _subscribers = data.subscribers;
    _workers = data.workers;
    _budgets = data.budgets;
    _receipts = data.receipts;
  }

  final DateTime _now;
  late List<Subscriber> _subscribers;
  late List<Worker> _workers;
  late List<Budget> _budgets;
  late List<Receipt> _receipts;
  UserProfile? _profile;

  static const _latency = Duration(milliseconds: 250);

  @override
  bool get isDemo => true;

  bool get _isManager => _profile?.isManager ?? false;

  void _requireManager() {
    if (!_isManager) throw const AppException('هذه العملية متاحة لمدير المولدة فقط');
  }

  int _nextId(Iterable<int> ids) => ids.fold(0, (a, b) => a > b ? a : b) + 1;

  // ── Session ───────────────────────────────────────────────────────────────

  @override
  Future<UserProfile?> restoreSession() async => _profile;

  @override
  Future<UserProfile> signIn(LoginKind kind, String identifier, String password) async {
    await Future<void>.delayed(_latency);
    final id = identifier.trim();
    if (kind == LoginKind.account) {
      if (id != DemoData.generatorName || password != 'test1234') {
        throw const AppException('بيانات الدخول غير صحيحة');
      }
      return _profile = const UserProfile(
        type: 'account',
        generatorId: DemoData.generatorId,
        generatorName: DemoData.generatorName,
        phone: DemoData.managerPhone,
      );
    }
    final worker = _workers.where((w) => w.phone == id && w.isActive).firstOrNull;
    if (worker == null || password != 'worker123') {
      throw const AppException('بيانات الدخول غير صحيحة');
    }
    return _profile = UserProfile(
      type: 'worker',
      generatorId: DemoData.generatorId,
      generatorName: DemoData.generatorName,
      phone: worker.phone,
      workerId: worker.id,
      workerName: worker.name,
    );
  }

  @override
  Future<void> signOut() async => _profile = null;

  @override
  Future<void> changePassword(String newPassword) async {
    await Future<void>.delayed(_latency);
    throw const AppException('لا يمكن تغيير كلمة المرور في الوضع التجريبي');
  }

  // ── Subscribers ───────────────────────────────────────────────────────────

  @override
  Future<List<Subscriber>> fetchSubscribers() async {
    await Future<void>.delayed(_latency);
    return _subscribers.where((s) => s.isActive).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<Subscriber> addSubscriber(SubscriberInput input) async {
    await Future<void>.delayed(_latency);
    final s = Subscriber(
      id: _nextId(_subscribers.map((s) => s.id)),
      generatorId: DemoData.generatorId,
      name: input.name.trim(),
      circuitNumber: input.circuitNumber.trim(),
      ambers: input.ambers,
      phone: input.phone.trim(),
      dateSubscribed: DateTime.now(),
      isActive: true,
    );
    _subscribers.add(s);
    return s;
  }

  @override
  Future<Subscriber> updateSubscriber(int id, SubscriberInput input) async {
    await Future<void>.delayed(_latency);
    _requireManager();
    final i = _subscribers.indexWhere((s) => s.id == id);
    if (i < 0) throw const AppException('المشترك غير موجود');
    return _subscribers[i] = _subscribers[i].copyWith(
      name: input.name.trim(),
      circuitNumber: input.circuitNumber.trim(),
      ambers: input.ambers,
      phone: input.phone.trim(),
    );
  }

  @override
  Future<void> archiveSubscriber(int id) async {
    await Future<void>.delayed(_latency);
    _requireManager();
    final i = _subscribers.indexWhere((s) => s.id == id);
    if (i >= 0) _subscribers[i] = _subscribers[i].copyWith(isActive: false);
  }

  // ── Budgets ───────────────────────────────────────────────────────────────

  @override
  Future<List<Budget>> fetchBudgets() async {
    await Future<void>.delayed(_latency);
    return List.of(_budgets)..sort((a, b) => b.period.compareTo(a.period));
  }

  @override
  Future<Budget> addBudget(int year, int month, double amberPrice) async {
    await Future<void>.delayed(_latency);
    _requireManager();
    if (_budgets.any((b) => b.year == year && b.month == month)) {
      throw const AppException('الميزانية لهذا الشهر موجودة مسبقاً');
    }
    final b = Budget(
      id: _nextId(_budgets.map((b) => b.id)),
      generatorId: DemoData.generatorId,
      year: year,
      month: month,
      amberPrice: amberPrice,
      dateCreated: DateTime.now(),
    );
    _budgets.add(b);
    return b;
  }

  @override
  Future<Budget> updateBudgetPrice(int id, double amberPrice) async {
    await Future<void>.delayed(_latency);
    _requireManager();
    final i = _budgets.indexWhere((b) => b.id == id);
    if (i < 0) throw const AppException('الميزانية غير موجودة');
    return _budgets[i] = _budgets[i].copyWith(amberPrice: amberPrice);
  }

  @override
  Future<void> deleteBudget(int id) async {
    await Future<void>.delayed(_latency);
    _requireManager();
    _budgets.removeWhere((b) => b.id == id);
  }

  // ── Receipts ──────────────────────────────────────────────────────────────

  @override
  Future<List<Receipt>> fetchReceipts() async {
    await Future<void>.delayed(_latency);
    return List.of(_receipts)..sort((a, b) => b.dateReceived.compareTo(a.dateReceived));
  }

  @override
  Future<Receipt> addReceipt(ReceiptInput input) async {
    await Future<void>.delayed(_latency);
    final sub = _subscribers.where((s) => s.id == input.subscriberId).firstOrNull;
    if (sub == null) throw const AppException('المشترك غير موجود في هذه المولدة');
    if (_receipts.any((r) =>
        r.subscriberId == input.subscriberId && r.year == input.year && r.month == input.month)) {
      throw const AppException('يوجد إيصال لهذا المشترك في هذا الشهر مسبقاً');
    }
    // A worker always collects in their own name (same as the DB trigger).
    final workerId = _profile?.workerId ?? input.workerId;
    final worker = _workers.where((w) => w.id == workerId).firstOrNull;
    final r = Receipt(
      id: _nextId(_receipts.map((r) => r.id)),
      generatorId: DemoData.generatorId,
      subscriberId: sub.id,
      subscriberName: sub.name,
      subscriberCircuit: sub.circuitNumber,
      subscriberPhone: sub.phone,
      subscriberAmbers: sub.ambers,
      workerId: worker?.id,
      workerName: worker?.name,
      year: input.year,
      month: input.month,
      amberPrice: input.amberPrice,
      amountPaid: input.amountPaid,
      notes: input.notes.trim(),
      dateReceived: DateTime.now(),
    );
    _receipts.insert(0, r);
    return r;
  }

  @override
  Future<void> deleteReceipt(int id) async {
    await Future<void>.delayed(_latency);
    _requireManager();
    _receipts.removeWhere((r) => r.id == id);
  }

  // ── Workers ───────────────────────────────────────────────────────────────

  @override
  Future<List<Worker>> fetchWorkers() async {
    await Future<void>.delayed(_latency);
    return List.of(_workers)..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<Worker> createWorker(String name, String phone, String password) async {
    await Future<void>.delayed(_latency);
    _requireManager();
    if (_workers.any((w) => w.phone == phone.trim())) {
      throw const AppException('رقم الهاتف مستخدم مسبقاً');
    }
    final w = Worker(
      id: _nextId(_workers.map((w) => w.id)),
      generatorId: DemoData.generatorId,
      name: name.trim(),
      phone: phone.trim(),
      isActive: true,
      dateCreated: DateTime.now(),
    );
    _workers.add(w);
    return w;
  }

  @override
  Future<Worker> updateWorker(int id, String name, String phone) async {
    await Future<void>.delayed(_latency);
    _requireManager();
    if (_workers.any((w) => w.phone == phone.trim() && w.id != id)) {
      throw const AppException('رقم الهاتف مستخدم مسبقاً');
    }
    final i = _workers.indexWhere((w) => w.id == id);
    if (i < 0) throw const AppException('العامل غير موجود');
    return _workers[i] = _workers[i].copyWith(name: name.trim(), phone: phone.trim());
  }

  @override
  Future<void> setWorkerPassword(int id, String password) async {
    await Future<void>.delayed(_latency);
    _requireManager();
  }

  @override
  Future<Worker> setWorkerActive(int id, bool active) async {
    await Future<void>.delayed(_latency);
    _requireManager();
    final i = _workers.indexWhere((w) => w.id == id);
    if (i < 0) throw const AppException('العامل غير موجود');
    return _workers[i] = _workers[i].copyWith(isActive: active);
  }

  /// Reference date the sample data was generated for (tests).
  DateTime get generatedFor => _now;
}
