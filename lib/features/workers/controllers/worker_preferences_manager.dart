import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moalidaty/features/workers/models/workers_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerPreferencesManager {
  static final Future<SharedPreferences> _pref =
      SharedPreferences.getInstance();

  Future<bool> clearAllData() async {
    final prefs = await _pref;
    return await prefs.clear();
  }

  Future<MyWorker?> getWorkerAccount() async {
    final prefs = await _pref;

    final worker_details = prefs.getString('worker_account');
    if (worker_details != null) {
      return MyWorker.fromJson(jsonDecode(worker_details));
    }
    return null;
  }

  Future<bool> saveWorkerAccount(MyWorker worker) async {
    final prefs = await _pref;
    return await prefs.setString('worker_account', jsonEncode(worker.toJson()));
  }

  Future<bool> removeWorkerAccount() async {
    final prefs = await _pref;
    return await prefs.remove('worker_account');
  }

  Future<bool> dispalyData() async {
    final prefs = await _pref;
    final data = prefs.getString('worker_account');
    if (data != null) {
      debugPrint("data: $data");
      return true;
    }
    return false;
  }
}
