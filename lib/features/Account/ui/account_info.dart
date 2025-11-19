import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/appbar.dart';
import 'package:moalidaty/features/Account/controllers/account_preferences_manager.dart';
import 'package:moalidaty/features/Account/controllers/account_controller.dart';
import 'package:moalidaty/features/Account/ui/account_login.dart';

class AccountInfoPage extends StatelessWidget {
  AccountInfoPage({super.key});
  final controller = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "مرحبا بك"),
      body: Center(
        child: (controller.account != null)
            ? Column(
                children: [
                  SizedBox(height: 40),

                  Text(controller.account!.generator_name),
                  SizedBox(height: 40),
                  Text(controller.account!.username),
                  SizedBox(height: 40),
                  Text(controller.account!.phone),
                  SizedBox(height: 40),
                  Text('${controller.account!.date_created}'),
                  SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("تسجيل الخروج الان "),
                      IconButton(
                        onPressed: () async {
                          await AccountPreferencesManager().clearUserAccount();
                          Get.to(() => AccountLoginPage());
                        },
                        icon: Icon(Icons.logout_outlined),
                      ),
                    ],
                  ),
                ],
              )
            : Text("no account found data"),
      ),
    );
  }
}
