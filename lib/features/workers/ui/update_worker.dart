import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/features/workers/models/model.dart';
import 'package:moalidaty1/features/workers/services/service.dart';

class UpdateWorkerDialog extends StatefulWidget {
  final Gen_Worker worker;
  const UpdateWorkerDialog({super.key, required this.worker});

  @override
  State<UpdateWorkerDialog> createState() => _UpdateWorkerDialogState();
}

class _UpdateWorkerDialogState extends State<UpdateWorkerDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController salaryCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.worker.name ?? '');
    phoneCtrl = TextEditingController(text: widget.worker.phone ?? '');
    salaryCtrl = TextEditingController(text: widget.worker.salary ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    salaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workerService = Get.find<WorkerService>();

    return AlertDialog(
      title: const Text('تعديل بيانات المشغل'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معرف المشغل: ${widget.worker.id ?? "غير متوفر"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
            final updatedWorker = Gen_Worker(
              id: widget.worker.id,
              name: nameCtrl.text,
              phone: phoneCtrl.text,
              salary: salaryCtrl.text,
            );
            workerService.updateWorker(updatedWorker);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('تحديث'),
        ),
      ],
    );
  }
}
