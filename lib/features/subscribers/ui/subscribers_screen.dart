import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme.dart';
import '../controllers/subscriber_controller.dart';
import '../models/subscriber.dart';
import 'subscriber_detail_screen.dart';

class SubscribersScreen extends StatelessWidget {
  const SubscribersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SubscriberController>();

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
                  itemBuilder: (_, i) => _SubscriberCard(
                    subscriber: ctrl.items[i],
                    onDelete: () => _confirmDelete(context, ctrl, ctrl.items[i]),
                    onTap: () => Get.to(
                      () => SubscriberDetailScreen(subscriber: ctrl.items[i]),
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'sub_fab',
          onPressed: () => ctrl.showAddSheet(context),
          child: const Icon(Icons.person_add),
        ),
      );
    });
  }

  void _confirmDelete(
      BuildContext ctx, SubscriberController ctrl, Subscriber s) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('حذف المشترك',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: Text('حذف "${s.name}"؟',
            style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Get.back(),
              child: const Text('إلغاء', style: TextStyle(fontFamily:'Cairo'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { Get.back(); ctrl.delete(s.id); },
            child: const Text('حذف', style: TextStyle(fontFamily:'Cairo')),
          ),
        ],
      ),
    );
  }
}

class _SubscriberCard extends StatelessWidget {
  final Subscriber subscriber;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SubscriberCard({
    required this.subscriber,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
            // Avatar
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: AppTheme.primary),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subscriber.name,
                    style: const TextStyle(fontFamily:'Cairo',
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Row(children: [
                  _chip(Icons.electrical_services, '${subscriber.ambers} أمبير',
                      AppTheme.warning),
                  const SizedBox(width: 8),
                  _chip(Icons.tag, subscriber.circuitNumber, AppTheme.primary),
                ]),
                if (subscriber.phone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subscriber.phone,
                        style: const TextStyle(fontFamily:'Cairo',
                            color: AppTheme.textLight, fontSize: 12)),
                  ),
              ],
            )),
            // Actions
            IconButton(
              icon: const Icon(Icons.qr_code_2, color: AppTheme.primary),
              onPressed: onTap,
              tooltip: 'تفاصيل ورمز QR',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontFamily:'Cairo', fontSize:11, color:color)),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.people_outline, size: 80, color: AppTheme.textLight),
      const SizedBox(height: 16),
      const Text('لا يوجد مشتركون بعد',
          style: TextStyle(fontFamily:'Cairo', fontSize:18,
              fontWeight: FontWeight.w600, color: AppTheme.textMid)),
      const SizedBox(height: 8),
      const Text('أضف أول مشترك للبدء',
          style: TextStyle(fontFamily:'Cairo', color: AppTheme.textLight)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة مشترك'),
      ),
    ]),
  );
}
