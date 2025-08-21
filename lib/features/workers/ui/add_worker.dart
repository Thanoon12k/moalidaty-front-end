import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/features/workers/models/model.dart';
import 'package:moalidaty1/features/workers/services/service.dart';

class AddWorkerDialog extends StatelessWidget {
  AddWorkerDialog({super.key});

  final nameCtrl = TextEditingController();

  final phoneCtrl = TextEditingController();

  final salaryCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final workerService = Get.find<WorkerService>();

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
              controller: salaryCtrl,
              decoration: const InputDecoration(
                labelText: 'الراتب',
                border: OutlineInputBorder(),
              ),
            ),
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
          onPressed: () {
            final worker = Gen_Worker(
              name: nameCtrl.text,
              phone: phoneCtrl.text == "" ? "077" : phoneCtrl.text,
              salary: salaryCtrl.text == "" ? "0" : salaryCtrl.text,
            );
            workerService.addWorker(worker);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
