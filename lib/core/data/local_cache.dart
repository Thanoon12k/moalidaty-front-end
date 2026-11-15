import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/receipts/models/receipt.dart';

/// Device-local storage for working offline:
///  • the last downloaded lists (shown when the server can't be reached)
///  • the signed-in profile (so a cold start without internet still works)
///  • the queue of receipts recorded offline (قائمة الانتظار)
class LocalCache {
  LocalCache._();

  static const _pendingKey = 'pending_receipts_v1';

  static Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  static String _listKey(int generatorId, String name) => 'cache_v1_${generatorId}_$name';

  static Future<void> saveList(int generatorId, String name, List<Map<String, dynamic>> rows) async {
    await (await _prefs())?.setString(_listKey(generatorId, name), jsonEncode(rows));
  }

  static Future<List<Map<String, dynamic>>?> readList(int generatorId, String name) async {
    final raw = (await _prefs())?.getString(_listKey(generatorId, name));
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveProfile(Map<String, dynamic>? row) async {
    final prefs = await _prefs();
    if (row == null) {
      await prefs?.remove('cache_v1_profile');
    } else {
      await prefs?.setString('cache_v1_profile', jsonEncode(row));
    }
  }

  static Future<Map<String, dynamic>?> readProfile() async {
    final raw = (await _prefs())?.getString('cache_v1_profile');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Removes everything cached for the signed-out user (the pending queue is
  /// kept: it belongs to the generator and is sent at the next sign-in).
  static Future<void> clearSession() async {
    final prefs = await _prefs();
    if (prefs == null) return;
    for (final key in prefs.getKeys().where((k) => k.startsWith('cache_v1_')).toList()) {
      await prefs.remove(key);
    }
  }

  // ── Pending receipts ──────────────────────────────────────────────────────

  static Future<List<PendingReceipt>> readPending() async {
    final raw = (await _prefs())?.getString(_pendingKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((j) => PendingReceipt.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePending(List<PendingReceipt> items) async {
    await (await _prefs())?.setString(_pendingKey, jsonEncode(items.map((p) => p.toJson()).toList()));
  }
}

/// A receipt recorded without connection, waiting to be sent.
class PendingReceipt {
  final String localId;
  final int generatorId;
  final ReceiptInput input;
  final String subscriberName;
  final String subscriberCircuit;
  final DateTime createdAt;
  final String? lastError;

  const PendingReceipt({
    required this.localId,
    required this.generatorId,
    required this.input,
    required this.subscriberName,
    required this.subscriberCircuit,
    required this.createdAt,
    this.lastError,
  });

  PendingReceipt withError(String? error) => PendingReceipt(
        localId: localId,
        generatorId: generatorId,
        input: input,
        subscriberName: subscriberName,
        subscriberCircuit: subscriberCircuit,
        createdAt: createdAt,
        lastError: error,
      );

  Map<String, dynamic> toJson() => {
        'local_id': localId,
        'generator_id': generatorId,
        'input': input.toRow(),
        'subscriber_name': subscriberName,
        'subscriber_circuit': subscriberCircuit,
        'created_at': createdAt.toIso8601String(),
        'last_error': lastError,
      };

  factory PendingReceipt.fromJson(Map<String, dynamic> j) => PendingReceipt(
        localId: j['local_id'] as String,
        generatorId: j['generator_id'] as int,
        input: ReceiptInput.fromRow((j['input'] as Map).cast<String, dynamic>()),
        subscriberName: j['subscriber_name'] as String? ?? '',
        subscriberCircuit: j['subscriber_circuit'] as String? ?? '',
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
        lastError: j['last_error'] as String?,
      );
}
