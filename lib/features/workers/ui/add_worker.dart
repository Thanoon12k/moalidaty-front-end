import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/snackbars.dart';
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/workers/controllers/worker_controller.dart';
import 'package:moalidaty/features/workers/models/workers_model.dart';

class AddWorkerDialog extends StatelessWidget {
  AddWorkerDialog({super.key});

  final nameCtrl = TextEditingController();

  final phoneCtrl = TextEditingController();
  final passwordctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final workerController = Get.find<WorkerController>();

    return AlertDialog(
      title: const Text('إضافة مشغل جديد'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'الهاتف',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: passwordctrl,
              decoration: const InputDecoration(
                labelText: 'الرمز السري',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('رجوع'),
        ),
        ElevatedButton(
          onPressed: () async {
            final new_worker = MyWorker(
              generator: -1,
              password: passwordctrl.text,
              username: nameCtrl.text,
              phone: phoneCtrl.text,
            );
            Navigator.pop(context);

            bool success = await workerController.addWorker(new_worker);
            DispalySnackbar(success, "إضافة", "المشغل");
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
