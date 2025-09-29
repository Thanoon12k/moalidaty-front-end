import 'package:flutter/material.dart';
import 'package:get/get.dart';


/// Global snackbar function for custom actions
///
/// [success] - true for success (green), false for error (red)
/// [action] - the action performed ('تحميل', 'حذف', 'إضافة', 'تعديل')
/// [label] - the item name (e.g., 'الميزانية', 'الإيصال')
void DispalySnackbar(bool success, String action, String label) {
  
  Get.snackbar(
    success ? '✅ نجاح' : '❌ فشل',
    success ? 'تم $action $label' : 'فشل $action $label',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: success ? Colors.green[100] : Colors.red[100],
    colorText: success ? Colors.green[900] : Colors.red[900],
    margin: const EdgeInsets.all(12),
    duration: const Duration(seconds: 2),
  );
}
