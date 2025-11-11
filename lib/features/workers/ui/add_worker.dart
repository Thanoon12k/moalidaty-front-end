import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/snackbars.dart';
import 'package:moalidaty/features/workers/models/model.dart';
import 'package:moalidaty/features/workers/controllers/worker_controller.dart';

class AddWorkerDialog extends StatelessWidget {
  AddWorkerDialog({super.key});

  final nameCtrl = TextEditingController();

  final phoneCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final workerService = Get.find<WorkerController>();

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
            final worker = Gen_Worker(
              name: nameCtrl.text,
              phone: phoneCtrl.text == "" ? "077" : phoneCtrl.text,
            );
            Navigator.pop(context);

            bool success = await workerService.addWorker(worker);
            DispalySnackbar(success, "إضافة", "المشغل");
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
