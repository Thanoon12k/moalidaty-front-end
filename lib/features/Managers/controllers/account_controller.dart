import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:moalidaty/constants/global_preferences_manager.dart';
import 'package:moalidaty/features/Managers/api/auth_api.dart';
import 'package:moalidaty/features/Managers/models/models.dart';
import 'package:moalidaty/features/workers/models/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountController extends GetxController {
  Gen_Worker? worker;
  Manager? manager;
  RxBool is_manager = false.obs;

  @override
  Future<void> onInit() async {
    await getUser();
    super.onInit();
  }

  Future<dynamic> getUser() async {
    final user = await PreferencesManager().getLoggedUser();
    if (user is Manager) {
      manager = user;
      is_manager.value = true;
    } else if (user is Gen_Worker) {
      worker = user;
    } else {
      debugPrint("user not loggred in");
    }
  }
}
