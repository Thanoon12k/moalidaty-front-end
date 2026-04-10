import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Worker;

import '../../../core/theme.dart';
import '../controllers/worker_controller.dart';
import '../models/worker.dart';

class WorkersScreen extends StatelessWidget {
  const WorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<WorkerController>();

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: ctrl.items.isEmpty
            ? _EmptyState(onAdd: () => ctrl.showAddSheet(context))
            : RefreshIndicator(
                onRefresh: ctrl.load,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: ctrl.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _WorkerCard(
                    worker: ctrl.items[i],
                    onDelete: () => _confirmDelete(context, ctrl, ctrl.items[i]),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'wor_fab',
          onPressed: () => ctrl.showAddSheet(context),
          child: const Icon(Icons.person_add),
        ),
      );
    });
  }

  void _confirmDelete(BuildContext ctx, WorkerController ctrl, Worker w) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('حذف العامل',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: Text('حذف "${w.name}"؟',
            style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Get.back(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { Get.back(); ctrl.delete(w.id); },
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback onDelete;
  const _WorkerCard({required this.worker, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentL,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.engineering, color: AppTheme.accent),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(worker.name,
                style: const TextStyle(fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text(worker.phone,
                style: const TextStyle(fontFamily: 'Cairo',
                    color: AppTheme.textMid, fontSize: 13)),
          ])),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.engineering_outlined, size: 80, color: AppTheme.textLight),
      const SizedBox(height: 16),
      const Text('لا يوجد عمال بعد',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 18,
              fontWeight: FontWeight.w600, color: AppTheme.textMid)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة عامل'),
      ),
    ]),
  );
}
