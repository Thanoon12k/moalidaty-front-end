import '../../features/auth/models/user_profile.dart';
import '../../features/budgets/models/budget.dart';
import '../../features/receipts/models/receipt.dart';
import '../../features/subscribers/models/subscriber.dart';
import '../../features/workers/models/worker.dart';

enum LoginKind { account, worker }

/// Everything the app reads or writes. Implemented by [SupabaseDataSource]
/// (the real backend) and [DemoDataSource] (in-memory sample data).
abstract class DataSource {
  bool get isDemo;

  // ── Session ───────────────────────────────────────────────────────────────
  /// Profile of a session persisted on this device, or null.
  Future<UserProfile?> restoreSession();
  Future<UserProfile> signIn(LoginKind kind, String identifier, String password);
  Future<void> signOut();
  Future<void> changePassword(String newPassword);

  // ── Subscribers ───────────────────────────────────────────────────────────
  Future<List<Subscriber>> fetchSubscribers();
  Future<Subscriber> addSubscriber(SubscriberInput input);
  Future<Subscriber> updateSubscriber(int id, SubscriberInput input);
  Future<void> archiveSubscriber(int id);

  // ── Budgets ───────────────────────────────────────────────────────────────
  Future<List<Budget>> fetchBudgets();
  Future<Budget> addBudget(int year, int month, double amberPrice);
  Future<Budget> updateBudgetPrice(int id, double amberPrice);
  Future<void> deleteBudget(int id);

  // ── Receipts ──────────────────────────────────────────────────────────────
  Future<List<Receipt>> fetchReceipts();
  Future<Receipt> addReceipt(ReceiptInput input);
  Future<void> deleteReceipt(int id);

  // ── Workers ───────────────────────────────────────────────────────────────
  Future<List<Worker>> fetchWorkers();
  Future<Worker> createWorker(String name, String phone, String password);
  Future<Worker> updateWorker(int id, String name, String phone);
  Future<void> setWorkerPassword(int id, String password);
  Future<Worker> setWorkerActive(int id, bool active);
}
