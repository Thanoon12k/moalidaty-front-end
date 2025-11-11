import 'package:get/get.dart';
import 'package:moalidaty/features/Managers/controllers/loginController.dart';
import 'package:moalidaty/features/Managers/controllers/account_controller.dart';
import 'package:moalidaty/features/budgets/services/budget_service.dart';
import 'package:moalidaty/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty/features/workers/controllers/worker_controller.dart';

class GlobalServiceManager extends GetxService {
  Future<void> initAllServices() async {
    Get.lazyPut<BudgetService>(() => BudgetService());
    Get.lazyPut<SubscribersService>(() => SubscribersService());
    Get.lazyPut<WorkerController>(() => WorkerController());
    Get.lazyPut<ReceiptServices>(() => ReceiptServices());

    await Get.find<BudgetService>().onInit();
    await Get.find<SubscribersService>().onInit();
    await Get.find<WorkerController>().onInit();
    await Get.find<ReceiptServices>().onInit();
  }

  Future<void> refershAllServices() async {
    await Get.find<BudgetService>().getBudgets();
    await Get.find<WorkerController>().getWorkers();
    await Get.find<SubscribersService>().getSubscripers();
    await Get.find<ReceiptServices>().getReciepts();
  }

  Future<void> resetServices({
    BudgetService? ser1,
    WorkerController? ser2,
    SubscribersService? ser3,
    ReceiptServices? ser4,
    AccountController? ser5,
    LoginController? ser6,
  }) async {
    if (ser1 != null) await ser1.getBudgets();
    if (ser2 != null) await ser2.getWorkers();
    if (ser3 != null) await ser3.getSubscripers();
    if (ser4 != null) await ser4.getReciepts();
    if (ser5 != null) await ser5.ma();
    if (ser4 != null) await ser4.getReciepts();
  }
}
