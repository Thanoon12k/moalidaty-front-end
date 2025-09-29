import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/appbar.dart';
import 'package:moalidaty/common_widgets/snackbars.dart';
import 'package:moalidaty/features/workers/ui/add_worker.dart';
import 'package:moalidaty/features/workers/ui/widgets.dart';
import '../services/service_worker.dart';

class WorkersListPage extends StatelessWidget {
  const WorkersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workerService = Get.find<WorkerService>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: "المشغلون",
        font_size: 28,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'البحث',
            onPressed: () {
              workerService.showSearch.value = !workerService.showSearch.value;
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'refresh') {
                bool success = await workerService.getWorkers();
                DispalySnackbar(success, "تحميل", "المشغلين");
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.grey[700]),
                    SizedBox(width: 12),
                    Text('تحديث القائمة'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (workerService.filteredWorkers.isEmpty) {
          return buildEmptyState();
        }

        return Column(
          children: [
            if (workerService.showSearch.value)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مشغل...',
                    hintTextDirection: TextDirection.rtl,
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: workerService.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () =>
                                workerService.searchQuery.value = '',
                            tooltip: 'مسح البحث',
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    workerService.searchQuery.value = value;
                  },
                ),
              ),

            buildHeaderStats(workerService.filteredWorkers.length),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  bool success = await workerService.getWorkers();
                  DispalySnackbar(success, "تحميل", "المشغلين");
                },
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: workerService.filteredWorkers.length,
                  itemBuilder: (context, index) {
                    final worker = workerService.filteredWorkers[index];
                    return buildWorkerCard(context, worker, index);
                  },
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(context: context, builder: (_) => AddWorkerDialog());
        },
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
        icon: Icon(Icons.person_add),
        label: Text('إضافة مشغل', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
