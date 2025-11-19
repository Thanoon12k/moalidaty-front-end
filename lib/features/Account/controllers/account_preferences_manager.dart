import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/Account/models/account_model.dart';
import 'package:moalidaty/features/workers/models/workers_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPreferencesManager {
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();

  Future<bool> clearAllData() async {
    final prefs = await _pref;
    return await prefs.clear();
  }

  Future<Account?> getUserAccount() async {
    final prefs = await _pref;

    final account_details = prefs.getString('user_account');
    if (account_details != null) {
      return Account.fromJson(jsonDecode(account_details));
    }
    return null;
  }

  Future<bool> saveUserAccount(Account account) async {
    final prefs = await _pref;
    final saved = await prefs.setString(
      'user_account',
      jsonEncode(account.toJson()),
    );
   
    return saved;
  }

  Future<bool> clearUserAccount() async {
    final prefs = await _pref;
    return await prefs.remove('user_account');
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
    final data = prefs.getString('user_account');
    if (data != null) {
      debugPrint("data: $data");
      return true;
    }
    return false;
  }

  Future<bool> check_if_user_manager() async {
    final prefs = await _pref;
    final data = prefs.getString('user_account');
    if (data != null) {
      debugPrint("data: $data");
      return true;
    }
    return false;
  }

  Future<bool> check_if_user_worker() async {
    final prefs = await _pref;
    final data = prefs.getString('worker_account');
    if (data != null) {
      debugPrint("data: $data");
      return true;
    }
    return false;
  }

  Future<String?> check_user_type() async {
    final prefs = await _pref;
    final manager = prefs.getString('user_account');
    final worker = prefs.getString('worker_account');
    debugPrint('checking user status: manager$manager     worker:$worker');
    if (manager != null) {
      return "manager";
    } else if (worker != null) {
      return "worker";
    }
    return null;
  }
}
