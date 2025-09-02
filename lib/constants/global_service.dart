import 'package:get/get.dart';
import 'package:moalidaty1/features/budgets/services/budget_service.dart';
import 'package:moalidaty1/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/workers/services/service_worker.dart';

class GlobalService extends GetxService {
  Future<void> resetAll() async {
    await Get.find<BudgetService>().getBudgets();
    await Get.find<WorkerService>().getWorkers();
    await Get.find<SubscribersService>().getSubscripers();
    await Get.find<ReceiptServices>().getReciepts();
  }

  Future<void> resetServices({
    BudgetService? ser1,
    WorkerService? ser2,
    SubscribersService? ser3,
    ReceiptServices? ser4,
  }) async {
    if (ser1 != null) await ser1.getBudgets();
    if (ser2 != null) await ser2.getWorkers();
    if (ser3 != null) await ser3.getSubscripers();
    if (ser4 != null) await ser4.getReciepts();
  }
}
