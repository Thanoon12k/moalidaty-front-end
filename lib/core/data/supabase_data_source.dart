import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/models/user_profile.dart';
import '../../features/budgets/models/budget.dart';
import '../../features/receipts/models/receipt.dart';
import '../../features/subscribers/models/subscriber.dart';
import '../../features/workers/models/worker.dart';
import 'app_error.dart';
import 'data_source.dart';

/// Talks to the Supabase project (schema in supabase/migrations). Every query
/// is scoped to the caller's generator by row level security on the server.
class SupabaseDataSource implements DataSource {
  SupabaseClient get _db => Supabase.instance.client;

  /// PostgREST returns at most 1000 rows per request by default.
  static const _page = 1000;

  @override
  bool get isDemo => false;

  // ── Session ───────────────────────────────────────────────────────────────

  @override
  Future<UserProfile?> restoreSession() async {
    if (_db.auth.currentSession == null) return null;
    return _profile();
  }

  @override
  Future<UserProfile> signIn(LoginKind kind, String identifier, String password) async {
    final email = await _db.rpc<String>('login_email', params: {
      'p_kind': kind.name,
      'p_identifier': identifier.trim(),
    });
    await _db.auth.signInWithPassword(email: email, password: password);
    final profile = await _profile();
    if (profile == null) {
      await _db.auth.signOut();
      throw const AppException('هذا الحساب غير مفعّل');
    }
    return profile;
  }

  Future<UserProfile?> _profile() async {
    final row = await _db.rpc<Map<String, dynamic>?>('my_profile');
    return row == null ? null : UserProfile.fromRow(row);
  }

  @override
  Future<void> signOut() => _db.auth.signOut();

  @override
  Future<void> changePassword(String newPassword) =>
      _db.auth.updateUser(UserAttributes(password: newPassword));

  // ── Subscribers ───────────────────────────────────────────────────────────

  @override
  Future<List<Subscriber>> fetchSubscribers() => _all(
        (from, to) => _db
            .from('subscribers')
            .select()
            .eq('is_active', true)
            .order('name')
            .order('id')
            .range(from, to),
        Subscriber.fromRow,
      );

  @override
  Future<Subscriber> addSubscriber(SubscriberInput input) async =>
      Subscriber.fromRow(await _db.from('subscribers').insert(input.toRow()).select().single());

  @override
  Future<Subscriber> updateSubscriber(int id, SubscriberInput input) async => Subscriber.fromRow(
      _single(await _db.from('subscribers').update(input.toRow()).eq('id', id).select()));

  @override
  Future<void> archiveSubscriber(int id) async =>
      _single(await _db.from('subscribers').update({'is_active': false}).eq('id', id).select('id'));

  // ── Budgets ───────────────────────────────────────────────────────────────

  @override
  Future<List<Budget>> fetchBudgets() => _all(
        (from, to) => _db
            .from('budgets')
            .select()
            .order('year', ascending: false)
            .order('month', ascending: false)
            .range(from, to),
        Budget.fromRow,
      );

  @override
  Future<Budget> addBudget(int year, int month, double amberPrice) async =>
      Budget.fromRow(await _db
          .from('budgets')
          .insert({'year': year, 'month': month, 'amber_price': amberPrice})
          .select()
          .single());

  @override
  Future<Budget> updateBudgetPrice(int id, double amberPrice) async => Budget.fromRow(
      _single(await _db.from('budgets').update({'amber_price': amberPrice}).eq('id', id).select()));

  @override
  Future<void> deleteBudget(int id) async =>
      _single(await _db.from('budgets').delete().eq('id', id).select('id'));

  // ── Receipts ──────────────────────────────────────────────────────────────

  @override
  Future<List<Receipt>> fetchReceipts() => _all(
        (from, to) => _db
            .from('receipts')
            .select(Receipt.select)
            .order('date_received', ascending: false)
            .order('id', ascending: false)
            .range(from, to),
        Receipt.fromRow,
      );

  @override
  Future<Receipt> addReceipt(ReceiptInput input) async =>
      Receipt.fromRow(await _db.from('receipts').insert(input.toRow()).select(Receipt.select).single());

  @override
  Future<void> deleteReceipt(int id) async =>
      _single(await _db.from('receipts').delete().eq('id', id).select('id'));

  // ── Workers ───────────────────────────────────────────────────────────────

  @override
  Future<List<Worker>> fetchWorkers() => _all(
        (from, to) => _db.from('workers').select().order('name').order('id').range(from, to),
        Worker.fromRow,
      );

  @override
  Future<Worker> createWorker(String name, String phone, String password) async =>
      Worker.fromRow(await _db.rpc<Map<String, dynamic>>('create_worker', params: {
        'p_name': name.trim(),
        'p_phone': phone.trim(),
        'p_password': password,
      }));

  @override
  Future<Worker> updateWorker(int id, String name, String phone) async =>
      Worker.fromRow(await _db.rpc<Map<String, dynamic>>('update_worker', params: {
        'p_worker_id': id,
        'p_name': name.trim(),
        'p_phone': phone.trim(),
      }));

  @override
  Future<void> setWorkerPassword(int id, String password) =>
      _db.rpc<void>('set_worker_password', params: {'p_worker_id': id, 'p_password': password});

  @override
  Future<Worker> setWorkerActive(int id, bool active) async =>
      Worker.fromRow(await _db.rpc<Map<String, dynamic>>('set_worker_active', params: {
        'p_worker_id': id,
        'p_active': active,
      }));

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Reads every page of a query.
  Future<List<T>> _all<T>(
    PostgrestTransformBuilder<List<Map<String, dynamic>>> Function(int from, int to) query,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final out = <T>[];
    for (var from = 0;; from += _page) {
      final rows = await query(from, from + _page - 1);
      out.addAll(rows.map(parse));
      if (rows.length < _page) return out;
    }
  }

  /// Row level security turns a forbidden update/delete into "0 rows changed"
  /// rather than an error — surface that to the user.
  Map<String, dynamic> _single(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) throw const AppException('ليست لديك صلاحية لهذه العملية أو العنصر غير موجود');
    return rows.first;
  }
}
