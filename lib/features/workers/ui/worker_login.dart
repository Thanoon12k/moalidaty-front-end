import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/appbar.dart';
import 'package:moalidaty/common_widgets/snackbars.dart';
import 'package:moalidaty/constants/global_service_manager.dart';
import 'package:moalidaty/features/Account/models/account_model.dart';
import 'package:moalidaty/features/Account/ui/account_login.dart';
import 'package:moalidaty/features/workers/controllers/worker_login_controller.dart';
import 'package:moalidaty/features/workers/models/workers_model.dart';
import 'package:moalidaty/home.dart';

class WorkerLoginPage extends StatelessWidget {
  final WorkerLoginController controller = Get.find<WorkerLoginController>();

  WorkerLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'مرحباً  بك', font_size: 38),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentGeometry.topCenter,
            end: AlignmentGeometry.bottomCenter,
            colors: [
              Color.fromARGB(255, 154, 131, 131),
              Color.fromARGB(255, 237, 180, 180),
            ],
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
            elevation: 8,
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Text(
                      "(للمشغلين فقط)تسجيل الدخول",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff6a11cb),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'أسم المولدة او رقم الهاتف',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        prefixIcon: Icon(Icons.perm_identity_sharp),
                      ),
                      validator: controller.validatIndetifier,

                      onSaved: (val) => controller.identifier.value = val ?? '',
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: controller.validatePassword,
                      onSaved: (val) => controller.password.value = val ?? '',
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        bool success = false;
                        MyWorker? logged_worker;

                        logged_worker = await controller.loginWorker();
                        if (logged_worker != null) {
                          success = await controller.saveWorkertoPreference();
                        }
                        if (success) {
                          debugPrint(
                            'the worker with name $logged_worker in generator  ${logged_worker!.generator_name} success in loggin and saved to preference',
                          );
                          await GlobalServiceManager().initAllServices();

                          Get.to(() => HomePage());
                        }

                        DispalySnackbar(success, "تسجيل الدخول", "المولدة");
                      },
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.center,

                        foregroundColor: Color(0xff6a11cb),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5),
                        ),
                      ),
                      child: Text('تسجيل الدخول'),
                    ),
                    SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => AccountLoginPage());
                      },
                      child: Text(
                        "أو تسجيل الدخول كمدير  ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Color(0xff6a11cb),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
