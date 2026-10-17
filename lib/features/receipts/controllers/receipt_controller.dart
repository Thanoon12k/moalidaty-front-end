import 'dart:async';

import 'package:get/get.dart';

import '../../../core/data/app_error.dart';
import '../../../core/data/collection_controller.dart';
import '../../../core/data/local_cache.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../subscribers/models/subscriber.dart';
import '../models/receipt.dart';

enum SaveOutcome { saved, queued }

class ReceiptController extends CollectionController<Receipt> {
  /// Receipts recorded offline, waiting to be sent (قائمة الانتظار).
  final pending = <PendingReceipt>[].obs;
  final isSyncing = false.obs;

  Timer? _retry;

  @override
  String get cacheName => 'receipts';

  @override
  Future<List<Receipt>> fetch() => ds.fetchReceipts();

  @override
  Receipt fromRow(Map<String, dynamic> row) => Receipt.fromRow(row);

  @override
  Map<String, dynamic> toRow(Receipt item) => item.toRow();

  int? get _generatorId => Get.find<AuthController>().profile.value?.generatorId;

  bool isPaid(int subscriberId, int year, int month) =>
      items.any((r) => r.subscriberId == subscriberId && r.year == year && r.month == month) ||
      pending.any((p) =>
          p.input.subscriberId == subscriberId && p.input.year == year && p.input.month == month);

  /// Saves the receipt; without a connection it is queued and sent later.
  Future<(SaveOutcome, Receipt?)> add(ReceiptInput input, Subscriber subscriber) async {
    try {
      final r = await ds.addReceipt(input);
      items.insert(0, r);
      return (SaveOutcome.saved, r);
    } catch (e) {
      final gid = _generatorId;
      if (!isNetworkError(e) || gid == null || ds.isDemo) rethrow;
      pending.add(PendingReceipt(
        localId: '${DateTime.now().microsecondsSinceEpoch}',
        generatorId: gid,
        input: input,
        subscriberName: subscriber.name,
        subscriberCircuit: subscriber.circuitNumber,
        createdAt: DateTime.now(),
      ));
      await LocalCache.savePending(pending);
      _scheduleRetry();
      return (SaveOutcome.queued, null);
    }
  }

  Future<void> delete(int id) async {
    await ds.deleteReceipt(id);
    items.removeWhere((r) => r.id == id);
  }

  // ── Offline queue ─────────────────────────────────────────────────────────

  Future<void> loadPending() async {
    final gid = _generatorId;
    final all = await LocalCache.readPending();
    pending.assignAll(all.where((p) => p.generatorId == gid));
    if (pending.isNotEmpty) _scheduleRetry();
  }

  /// Sends queued receipts. Returns how many were sent.
  Future<int> syncPending() async {
    if (isSyncing.value || pending.isEmpty || ds.isDemo) return 0;
    isSyncing.value = true;
    var sent = 0;
    try {
      for (final p in List.of(pending)) {
        try {
          final r = await ds.addReceipt(p.input);
          items.insert(0, r);
          pending.removeWhere((x) => x.localId == p.localId);
          sent++;
        } catch (e) {
          if (isNetworkError(e)) break; // still offline — try again later
          // Rejected by the server (e.g. already paid): keep it with the
          // reason so the user can decide to delete it.
          final i = pending.indexWhere((x) => x.localId == p.localId);
          if (i >= 0) pending[i] = p.withError(describeError(e));
        }
      }
      await _persistPending();
    } finally {
      isSyncing.value = false;
    }
    if (pending.any((p) => p.lastError == null)) _scheduleRetry();
    return sent;
  }

  Future<void> removePending(String localId) async {
    pending.removeWhere((p) => p.localId == localId);
    await _persistPending();
  }

  Future<void> _persistPending() async {
    // Keep other generators' queued receipts (another account on this device).
    final others = (await LocalCache.readPending()).where((p) => p.generatorId != _generatorId);
    await LocalCache.savePending([...others, ...pending]);
  }

  void _scheduleRetry() {
    _retry?.cancel();
    _retry = Timer(const Duration(minutes: 1), syncPending);
  }

  @override
  void clear() {
    super.clear();
    pending.clear();
    _retry?.cancel();
  }

  @override
  void onClose() {
    _retry?.cancel();
    super.onClose();
  }
}
