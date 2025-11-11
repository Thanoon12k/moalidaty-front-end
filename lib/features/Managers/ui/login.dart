import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/appbar.dart';
import 'package:moalidaty/features/Managers/controllers/loginController.dart';

class LoginPage extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'مرحباً  بك'),
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'أسم المولدة او رقم الهاتف',
              ),
              validator: controller.validatIndetifier,

              onSaved: (val) => controller.identifier.value = val ?? '',
            ),

            TextFormField(
              decoration: InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
              validator: controller.validatePassword,
              onSaved: (val) => controller.password.value = val ?? '',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
