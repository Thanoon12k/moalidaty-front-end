import 'package:get/get.dart';
import 'package:moalidaty1/features/budgets/services/budget_service.dart';
import 'package:moalidaty1/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/workers/services/service_worker.dart';

class GlobalService extends GetxService {
  Future<void> resetAll() async {
    await Get.find<BudgetService>().onInit();
    await Get.find<WorkerService>().onInit();
    await Get.find<SubscribersService>().onInit();
    await Get.find<ReceiptServices>().onInit();
  }

  Future<void> resetServices(ser1, ser2, ser3, ser4) async {
    if (ser1) {
      await ser1.onInit();
    }
    if (ser2) {
      await ser2.onInit();
    }
    if (ser3) {
      await ser3.onInit();
    }
    if (ser4) {
      await ser4.onInit();
    }
  }
}
