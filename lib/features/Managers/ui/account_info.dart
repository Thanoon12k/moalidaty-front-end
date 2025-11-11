import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/appbar.dart';
import 'package:moalidaty/features/Managers/controllers/loginController.dart';

class AccountInfoPage extends StatelessWidget {
  AccountInfoPage({super.key});
  final logincontroller = Get.find<LoginController>();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: CustomAppBar(title: "مرحبا بك"),


    );
  }
}
