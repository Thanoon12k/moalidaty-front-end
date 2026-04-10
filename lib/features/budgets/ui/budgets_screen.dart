import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme.dart';
import '../controllers/budget_controller.dart';
import '../models/budget.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BudgetController>();

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
                  itemBuilder: (_, i) => _BudgetCard(budget: ctrl.items[i]),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'bud_fab',
          onPressed: () => ctrl.showAddSheet(context),
          child: const Icon(Icons.add),
        ),
      );
    });
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  const _BudgetCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final total = budget.paidCount + budget.unpaidCount;
    final paidPct = total == 0 ? 0.0 : budget.paidCount / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(budget.label,
                style: const TextStyle(fontFamily:'Cairo',
                    fontSize:18, fontWeight: FontWeight.w700)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
              decoration: BoxDecoration(
                color: AppTheme.primaryL,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${budget.amberPrice.toStringAsFixed(0)} د.ع/أمبير',
                  style: const TextStyle(fontFamily:'Cairo',
                      color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize:12)),
            ),
          ]),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: paidPct,
              backgroundColor: Colors.red.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _stat(Icons.check_circle, '${budget.paidCount} مدفوع', AppTheme.accent),
            _stat(Icons.cancel_outlined, '${budget.unpaidCount} غير مدفوع', Colors.red),
          ]),
        ]),
      ),
    );
  }

  Widget _stat(IconData icon, String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontFamily:'Cairo', fontSize:13, color:color)),
    ]);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.account_balance_wallet_outlined,
          size: 80, color: AppTheme.textLight),
      const SizedBox(height: 16),
      const Text('لا توجد ميزانيات بعد',
          style: TextStyle(fontFamily:'Cairo', fontSize:18,
              fontWeight: FontWeight.w600, color: AppTheme.textMid)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: const Text('إضافة ميزانية'),
      ),
    ]),
  );
}
