import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/common_widgets/appbar.dart';
import 'package:moalidaty1/common_widgets/loading_indicator.dart';
import 'package:moalidaty1/features/workers/models/model.dart';
import '../services/service.dart';

class WorkersListPage extends StatelessWidget {
  const WorkersListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workerService = Get.put(WorkerService());

    return Scaffold(
      appBar: CustomAppBar(title: "قائمة المشغلين"),
      body: FutureBuilder(
        future: workerService.fetchWorkers(),
        builder: (context, snapshot) {
          return Obx(() {
            if (workerService.workers.isEmpty) {
              return const Center(child: GeneratorLoadingIndicator());
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: workerService.workers.length,
              separatorBuilder: (_, __) => const Divider(thickness: 2),
              itemBuilder: (context, index) {
                final worker = workerService.workers[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red[300],
                        radius: 28,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker.name ?? '',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الراتب: ${worker.salary}',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الهاتف: ${worker.phone}',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => UpdateWorkerDialog(worker: worker),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => DeleteWorkerDialog(worker: worker),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
            // Add button at the bottom right
          });
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 32),
            label: const Text(
              'إضافة مشغل جديد',
              style: TextStyle(fontSize: 24),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddWorkerDialog(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AddWorkerDialog extends StatefulWidget {
  const AddWorkerDialog({Key? key}) : super(key: key);

  @override
  State<AddWorkerDialog> createState() => _AddWorkerDialogState();
}

class _AddWorkerDialogState extends State<AddWorkerDialog> {
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
              phone: phoneCtrl.text,
              salary: salaryCtrl.text,
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

class UpdateWorkerDialog extends StatefulWidget {
  final Gen_Worker worker;
  const UpdateWorkerDialog({Key? key, required this.worker}) : super(key: key);

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

class DeleteWorkerDialog extends StatelessWidget {
  final Gen_Worker worker;
  const DeleteWorkerDialog({Key? key, required this.worker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workerService = Get.find<WorkerService>();

    return AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: const Text('هل أنت متأكد أنك تريد حذف هذا المشغل؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('لا'),
        ),
        TextButton(
          onPressed: () {
            workerService.removeWorker(worker);
            Navigator.pop(context);
          },
          child: const Text('نعم'),
        ),
      ],
    );
  }
}
