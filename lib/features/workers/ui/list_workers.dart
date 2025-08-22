import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/common_widgets/appbar.dart';
import 'package:moalidaty1/common_widgets/delete_dialoge.dart';
import 'package:moalidaty1/common_widgets/loading_indicator.dart';
import 'package:moalidaty1/features/workers/ui/add_worker.dart';
import 'package:moalidaty1/features/workers/ui/update_worker.dart';
import '../services/service_worker.dart';

class WorkersListPage extends StatelessWidget {
  const WorkersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workerService = Get.find<WorkerService>();

    return Scaffold(
      appBar: CustomAppBar(title: "قائمة المشغلين"),
      body: FutureBuilder(
        future: workerService.getWorkers(),
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
                              worker.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الهاتف: ${worker.phone ?? "غير محدد"}',
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
                            builder: (_) => deleteYesNoBox(worker: worker),
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
              showDialog(context: context, builder: (_) => AddWorkerDialog());
            },
          ),
        ),
      ),
    );
  }
}
