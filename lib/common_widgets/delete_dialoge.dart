// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/features/budgets/models/budgets_model.dart';
import 'package:moalidaty1/features/budgets/services/budget_service.dart';
import 'package:moalidaty1/features/reciepts/models/receipt_model.dart';
import 'package:moalidaty1/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/workers/models/model.dart';
import 'package:moalidaty1/features/workers/services/service_worker.dart';

class DeleteYesNoBox extends StatelessWidget {
  final dynamic instance;

  const DeleteYesNoBox({super.key, required this.instance});

  @override
  Widget build(BuildContext context) {
    final title =
        instance is Gen_Worker
            ? 'المشغل'
            : instance is Subscriper
            ? 'المشترك'
            : instance is Budget
            ? 'الفاتورة'
            : instance is Reciept
            ? 'الإيصال'
            : 'العنصر';

    return AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: Text('هل أنت متأكد أنك تريد حذف $title؟'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('لا')),
        TextButton(
          onPressed: () async {
            Get.back();

            bool success = false;

            if (instance is Gen_Worker) {
              success = await Get.find<WorkerService>().removeWorker(instance);
            } else if (instance is Subscriper) {
              success = await Get.find<SubscribersService>().removeSubscriper(
                instance,
              );
            } else if (instance is Budget) {
              success = await Get.find<BudgetService>().removeBudget(instance);
            } else if (instance is Reciept) {
              success = await Get.find<ReceiptServices>().removeReceipt(
                instance,
              );
            }
            debugPrint('Deletion success: $success');

            Get.snackbar(
              success ? '✅ نجاح' : '❌ فشل',
              success ? 'تم حذف $title' : 'فشل حذف $title',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: success ? Colors.green[100] : Colors.red[100],
              colorText: success ? Colors.green[900] : Colors.red[900],
            );
          },
          child: const Text('نعم'),
        ),
      ],
    );
  }
}
