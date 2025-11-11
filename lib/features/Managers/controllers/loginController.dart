import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/constants/global_preferences_manager.dart';
import 'package:moalidaty/features/Managers/api/auth_api.dart';

class LoginController extends GetxController {
  var identifier = ''.obs;
  var password = ''.obs;

  String? login_user = '';

  final formKey = GlobalKey<FormState>();

  String? validatIndetifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'generator name or phone number is required';
    } else if (value.trim().length > 30) {
      return 'Name maximum Chars  must =< 30';
      // if the dentifier value start with digit and it is not ( 11 number  or start with 0)
    } else if (value.trim().startsWith(RegExp(r'(\d+)')) &
        !RegExp(r"^0\d{10}$").hasMatch(value)) {
      return 'Phone must start with 0 and be exactly 11 digits';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r"^0\d{10}$").hasMatch(value)) {
      return 'Phone must start with 0 and be exactly 11 digits';
    }
    return null;
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      debugPrint('Login with identification: $identifier, password: $password');

      login_user = await ManagerApi().loginUser(
        '$identifier',
        '$password',
      ); //from api eather manager or worker or null
      if (login_user != null) {
        debugPrint("i hate you you are nut user $login_user");
      } else {
        debugPrint('welcome there it is your app  $login_user');
        await PreferencesManager().registerUser('login_user');
      }
    }
  }

  Future<void> logout() async {
    await PreferencesManager().unRegisterUser();
  }
  
}
