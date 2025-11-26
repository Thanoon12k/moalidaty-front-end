import 'package:get/get.dart';
import 'package:moalidaty/features/Account/controllers/account_controller.dart';
import 'package:moalidaty/features/workers/controllers/worker_login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AccountController>()) {
      Get.lazyPut<AccountController>(() => AccountController(), fenix: true);
    }
    if (!Get.isRegistered<WorkerLoginController>()) {
      Get.lazyPut<WorkerLoginController>(
        () => WorkerLoginController(),
        fenix: true,
      );
    }
  }
}