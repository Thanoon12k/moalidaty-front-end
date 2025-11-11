import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/snackbars.dart';
import 'package:moalidaty/features/workers/models/model.dart';
import 'package:moalidaty/features/workers/controllers/worker_controller.dart';

class UpdateWorkerDialog extends StatefulWidget {
  final Gen_Worker worker;
  const UpdateWorkerDialog({super.key, required this.worker});

  @override
  State<UpdateWorkerDialog> createState() => _UpdateWorkerDialogState();
}

class _UpdateWorkerDialogState extends State<UpdateWorkerDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.worker.name);
    phoneCtrl = TextEditingController(text: widget.worker.phone ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workerService = Get.find<WorkerController>();

    return AlertDialog(
      title: const Text('تعديل بيانات المشغل'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معرف المشغل: ${widget.worker.id}',
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
            final updatedWorker = Gen_Worker(
              id: widget.worker.id,
              name: nameCtrl.text,
              phone: phoneCtrl.text,
            );
            Navigator.pop(context);

            bool success = await workerService.updateWorker(updatedWorker);
            DispalySnackbar(success, "تعديل", "المشغل");
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('تحديث'),
        ),
      ],
    );
  }
}
