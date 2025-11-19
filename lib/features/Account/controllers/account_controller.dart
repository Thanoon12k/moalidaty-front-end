import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/Account/controllers/account_preferences_manager.dart';
import 'package:moalidaty/features/Account/api/account_api.dart';
import 'package:moalidaty/features/Account/models/account_model.dart';

class AccountController extends GetxController {
  Account? account;
  var identifier = ''.obs;
  RxString generator_name = "".obs;
  var password = ''.obs;
  String? login_user = '';

  GlobalKey<FormState>? _formKey;

  GlobalKey<FormState> get formKey => _formKey ??= GlobalKey<FormState>();

  @override
  void onClose() {
    _formKey = null;
    formKey.currentState!.dispose();
    super.onClose();
  }

  @override
  Future<void> onInit() async {
    account = await AccountPreferencesManager().getUserAccount();
    if (account != null) {
      generator_name.value = account!.generator_name;
      debugPrint(" Logged in user found (${account!.username}) ");
      GlobalConstants.AccountType = "manager";
    } else {
      debugPrint("no Logged in user found ");
    }
    super.onInit();
  }

  String? validatIndetifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'مطلوب ادخال الاسم او رقم الهاتف';
    } else if (value.trim().length > 30) {
      return 'عدد احرف الاسم كبير جداً';
      // if the dentifier value start with digit and it is not ( 11 number  or start with 0)
    } else if (value.trim().startsWith(RegExp(r'(\d+)')) &
        !RegExp(r"^0\d{10}$").hasMatch(value)) {
      return 'رقم الهاتف يجب ان يبدأ بـ0 ويحتوي 11 رقم ';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().length < 4) {
      return 'الرمز السري قصير جداً';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'مطلوب رقم الهاتف';
    }
    if (!RegExp(r"^0\d{10}$").hasMatch(value)) {
      return 'Phone must start with 0 and be exactly 11 digits';
    }
    return null;
  }

  Future<bool> saveUsertoPreference() async {
    if (await AccountPreferencesManager().saveUserAccount(account!)) {
      debugPrint('welcome there it is your app  ${account!.username} ');
      GlobalConstants.AccountType = "manager";
      GlobalConstants.accountID = account!.id!;
      GlobalConstants.GeneratorName = account!.generator_name;
      return true;
    } 
      return false;
    
  }

  Future<Account?> loginUser() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      account = await AccountApi().apiLoginUser('$identifier', '$password');

      return account; //user not logged in
    }
    return null;
  }

  Future<bool> logout() async {
    return await AccountPreferencesManager().clearUserAccount();
  }
}
