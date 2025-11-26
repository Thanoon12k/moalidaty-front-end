import 'package:get/get.dart';
import 'package:moalidaty/features/Account/controllers/account_controller.dart';
import 'package:moalidaty/features/Account/ui/account_info.dart';
import 'package:moalidaty/features/Account/ui/account_login.dart';
import 'package:moalidaty/features/budgets/services/budget_service.dart';
import 'package:moalidaty/features/budgets/ui/budgets_list.dart';
import 'package:moalidaty/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty/features/reciepts/ui/list_reciepts.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty/features/subscripers/ui/subscripers_list.dart';
import 'package:moalidaty/features/workers/controllers/worker_controller.dart';
import 'package:moalidaty/features/workers/controllers/worker_login_controller.dart';
import 'package:moalidaty/features/workers/ui/list_workers.dart';
import 'package:moalidaty/home.dart';
import 'package:moalidaty/main.dart';

/// Route bindings for dependency injection

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Put all required controllers for home and features
    if (!Get.isRegistered<AccountController>()) {
      Get.lazyPut<AccountController>(() => AccountController(), fenix: true);
    }
    if (!Get.isRegistered<WorkerController>()) {
      Get.lazyPut<WorkerController>(() => WorkerController(), fenix: true);
    }
    if (!Get.isRegistered<BudgetService>()) {
      Get.lazyPut<BudgetService>(() => BudgetService(), fenix: true);
    }
    if (!Get.isRegistered<SubscribersService>()) {
      Get.lazyPut<SubscribersService>(() => SubscribersService(), fenix: true);
    }
    if (!Get.isRegistered<ReceiptServices>()) {
      Get.lazyPut<ReceiptServices>(() => ReceiptServices(), fenix: true);
    }
  }
}
