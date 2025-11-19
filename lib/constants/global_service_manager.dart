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
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();

  Future<dynamic> getUserFromPreference() async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // add 2s waiting to loading screen
    final prefs = await _pref;
    final manager = prefs.getString('user_account');
    final worker = prefs.getString('worker_account');
    debugPrint('checking user status: manager$manager     worker:$worker');
    if (manager != null) {
      final Account account = Account.fromJson(jsonDecode(manager));
      GlobalConstants.accountID = account.id!;
      GlobalConstants.GeneratorName = account.generator_name;
      GlobalConstants.AccountType = 'manager';
      await GlobalServiceManager().initAllServices();
      return account;
    } else if (worker != null) {
      final MyWorker myWorker = MyWorker.fromJson(jsonDecode(worker));
      GlobalConstants.accountID = myWorker.generator;
      GlobalConstants.GeneratorName = myWorker.generator_name;
      GlobalConstants.AccountType = 'worker';
      await GlobalServiceManager().initAllServices();
      return myWorker;
    }

    if (manager == null && worker == null) {
      //no user found in ooreference ()
      Get.put(AccountController());
      Get.put(WorkerLoginController());
      return null;
    }
  }

  Future<dynamic> clearAllPreference() async {
    final prefs = await _pref;
    prefs.clear();
  }

  Future<void> initAllServices() async {
    // Remove existing controllers first
    if (Get.isRegistered<BudgetService>()) Get.delete<BudgetService>();
    if (Get.isRegistered<SubscribersService>())
      Get.delete<SubscribersService>();
    if (Get.isRegistered<WorkerController>()) Get.delete<WorkerController>();
    if (Get.isRegistered<ReceiptServices>()) Get.delete<ReceiptServices>();
    if (Get.isRegistered<AccountController>()) Get.delete<AccountController>();
    if (Get.isRegistered<WorkerLoginController>())
      Get.delete<WorkerLoginController>();

    // Now put them fresh
    Get.put(BudgetService());
    Get.put(SubscribersService());
    Get.put(WorkerController());
    Get.put(ReceiptServices());
    Get.put(AccountController());
    Get.put(WorkerLoginController());

    // Initialize
    await Get.find<BudgetService>().onInit();
    await Get.find<SubscribersService>().onInit();
    await Get.find<WorkerController>().onInit();
    await Get.find<ReceiptServices>().onInit();
    await Get.find<AccountController>().onInit();
  }

  Future<void> refershAllServices() async {
    await Get.find<BudgetService>().getBudgets();
    await Get.find<WorkerController>().getWorkers();
    await Get.find<SubscribersService>().getSubscripers();
    await Get.find<ReceiptServices>().getReciepts();
    await Get.find<AccountController>().onInit();
  }

  Future<void> resetServices({
    BudgetService? ser1,
    WorkerController? ser2,
    SubscribersService? ser3,
    ReceiptServices? ser4,
    AccountController? ser5,
  }) async {
    if (ser1 != null) await ser1.getBudgets();
    if (ser2 != null) await ser2.getWorkers();
    if (ser3 != null) await ser3.getSubscripers();
    if (ser4 != null) await ser4.getReciepts();
    if (ser5 != null) await ser5.onInit();
  }
}
