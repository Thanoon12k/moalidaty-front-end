// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/snackbars.dart';
import 'package:moalidaty/features/budgets/models/budgets_model.dart';
import 'package:moalidaty/features/budgets/services/budget_service.dart';
import 'package:moalidaty/features/reciepts/models/receipt_model.dart';
import 'package:moalidaty/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty/features/subscripers/models/model.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty/features/workers/controllers/worker_controller.dart';
import 'package:moalidaty/features/workers/models/workers_model.dart';

class DeleteYesNoBox extends StatelessWidget {
  final dynamic instance;

  const DeleteYesNoBox({super.key, required this.instance});

  @override
  Widget build(BuildContext context) {
    final title = instance is MyWorker
        ? 'المشغل'
        : instance is Subscriper
        ? 'المشترك'
        : instance is Budget
        ? 'الفاتورة'
        : instance is Reciept
        ? 'الإيصال'
        : 'العنصر';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Colors.amber[800],
            ),
            const SizedBox(height: 16),
            Text(
              'تأكيد الحذف',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.amber[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'هل أنت متأكد أنك تريد حذف $title؟',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text('لا'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      bool success = false;

                      if (instance is MyWorker) {
                        success = await Get.find<WorkerController>()
                            .removeWorker(instance.id);
                      } else if (instance is Subscriper) {
                        success = await Get.find<SubscribersService>()
                            .removeSubscriper(instance);
                      } else if (instance is Budget) {
                        success = await Get.find<BudgetService>().removeBudget(
                          instance,
                        );
                      } else if (instance is Reciept) {
                        success = await Get.find<ReceiptServices>()
                            .removeReceipt(instance);
                      }

                      Get.back();
                      DispalySnackbar(success, "حذف", title);
                    },
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text('نعم'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
