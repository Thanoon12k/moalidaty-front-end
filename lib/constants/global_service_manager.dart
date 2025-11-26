// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/Account/controllers/account_controller.dart';
import 'package:moalidaty/features/Account/models/account_model.dart';
import 'package:moalidaty/features/budgets/services/budget_service.dart';
import 'package:moalidaty/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty/features/workers/controllers/worker_controller.dart';
import 'package:moalidaty/features/workers/controllers/worker_login_controller.dart';
import 'package:moalidaty/features/workers/models/workers_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalServiceManager extends GetxService {
  SharedPreferences get _prefs => Get.find<SharedPreferences>();

 

  Future<dynamic> getUserFromPreference() async {
    final manager = _prefs.getString('user_account');
    final worker = _prefs.getString('worker_account');
    debugPrint('checking user status: manager$manager     worker:$worker');
    if (manager != null) {
      final Account account = Account.fromJson(jsonDecode(manager));
      setManagerConstants(account);
      return account;
    } else if (worker != null) {
      final MyWorker myWorker = MyWorker.fromJson(jsonDecode(worker));
      setWorkeConstants(myWorker);
      return myWorker;
    }

    if (manager == null && worker == null) {
      //no user found in ooreference ()
      _resetGlobalConstants();
      return null;
    }
  }

  Future<dynamic> clearUserSeasion() async {
    _prefs.clear();
    _resetGlobalConstants();
    _disposeCoreServices();
  }

  void setManagerConstants(Account account) {
    GlobalConstants.manager = account;
    GlobalConstants.accountID = account.id;
    GlobalConstants.GeneratorName = account.generator_name;
    GlobalConstants.AccountType = 'manager';
  }

  void setWorkeConstants(MyWorker worker) {
    GlobalConstants.worker = worker;
    GlobalConstants.accountID = worker.generator;
    GlobalConstants.GeneratorName = worker.generator_name;
    GlobalConstants.AccountType = 'worker';
  }

  void _resetGlobalConstants() {
    GlobalConstants.worker = null;
    GlobalConstants.manager = null;
    GlobalConstants.AccountType = null;
    GlobalConstants.GeneratorName = null;
    GlobalConstants.accountID = null;
  }

  Future<void> _disposeCoreServices() async {
    _deleteIfExists<ReceiptServices>();
    _deleteIfExists<SubscribersService>();
    _deleteIfExists<BudgetService>();
    _deleteIfExists<WorkerController>();
  }

  Future<void> refershApplicationData() async {
    if (Get.isRegistered<BudgetService>()) {
      await Get.find<BudgetService>().getBudgets();
    }
    if (Get.isRegistered<SubscribersService>()) {
      await Get.find<SubscribersService>().getSubscripers();
    }
    if (Get.isRegistered<WorkerController>()) {
      await Get.find<WorkerController>().getWorkers();
    }
    if (Get.isRegistered<ReceiptServices>()) {
      await Get.find<ReceiptServices>().getReciepts();
    }
  }

  void _deleteIfExists<T>() {
    if (Get.isRegistered<T>()) {
      Get.delete<T>(force: true);
    }
  }
}
