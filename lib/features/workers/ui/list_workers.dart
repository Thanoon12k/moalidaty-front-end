import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/service.dart';

class WorkersListPage extends StatelessWidget {
  const WorkersListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workerService = Get.put(WorkerService());

    return Scaffold(
      appBar: AppBar(
        title: const Text('المشغلين'),
        backgroundColor: Colors.deepPurple[400],
        toolbarHeight: 80,
        titleTextStyle: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 36),
      ),
      body: FutureBuilder(
        future: workerService.fetchWorkers(),
        builder: (context, snapshot) {
          return Obx(() {
            if (workerService.workers.isEmpty) {
              return const Center(
                child: Text('لا يوجد مشغلين.', style: TextStyle(fontSize: 28)),
              );
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
                    ],
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }
}
