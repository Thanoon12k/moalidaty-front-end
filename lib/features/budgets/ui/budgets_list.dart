import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:moalidaty1/common_widgets/appbar.dart';
import 'package:moalidaty1/features/budgets/models/budgets_model.dart';
import 'package:moalidaty1/features/budgets/services/budget_service.dart';
import 'package:moalidaty1/features/budgets/ui/add_budget_dialoge.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';

class BudgetsListPage extends StatelessWidget {
  BudgetsListPage({super.key});
  final budget_service = Get.find<BudgetService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "قائمة الميزانيات",
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث الميزانيات',
            onPressed: () async {
              await budget_service
                  .fetchBudgets(); // or any method that reloads data
              Get.snackbar(
                'تم التحديث',
                'تم تحميل الميزانيات من جديد',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green[400],
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: budget_service.list_budgets.length,

          itemBuilder: (context, index) {
            final budget = budget_service.list_budgets[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              tileColor: Colors.grey[100],
              title: Text(
                'ميزانية الشهر ${budget.year_month}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.right,
              ),
              leading: const Icon(
                Icons.calendar_month,
                size: 32,
                color: Colors.green,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.visibility,
                      color: Colors.blue,
                      size: 28,
                    ),
                    tooltip: 'عرض التفاصيل',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ViewBudgetDetailsDialoge(budget),
                      );
                      print('View budget ${budget.id}');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                    tooltip: 'حذف الميزانية',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) =>
                                DeleteBudgetDialoge(budget, budget_service),
                      );
                      print('Delete budget ${budget.id}');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 32),
            label: const Text(
              'إضافة ميزانية جديدة',
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
              showDialog(context: context, builder: (_) => AddBudgetDialoge());
            },
          ),
        ),
      ),
    );
  }
}

class ViewBudgetDetailsDialoge extends StatelessWidget {
  final Budget bu;
  const ViewBudgetDetailsDialoge(this.bu, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[100],
      title: Column(
        children: [
          const Icon(Icons.receipt_long, size: 40, color: Colors.green),
          const SizedBox(height: 8),
          Text(
            'تفاصيل ميزانية ${bu.year_month}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _infoCard(
              title: 'المعلومات الأساسية',
              items: [
                _infoTile('السنة', bu.year.toString()),
                _infoTile('الشهر', bu.month.toString()),
                _infoTile(
                  'سعر الأمبير',
                  '${bu.amber_price.toStringAsFixed(2)}',
                ),
              ],
            ),
            _infoCard(
              title: 'الإجماليات',
              items: [
                _infoTile(
                  'إجمالي الواصل',
                  '${calculateTotalPaid().toStringAsFixed(2)}',
                ),
                _infoTile(
                  'إجمالي غير الواصل',
                  '${calculateTotalUnpaid().toStringAsFixed(2)}',
                ),
                _infoTile(
                  'عدد المشتركين الكلي',
                  '${bu.paid_subs.length + bu.unpaid_subs.length}',
                ),
              ],
            ),
            _infoCard(
              title: 'المشتركين الواصل (${bu.paid_subs.length})',
              items:
                  bu.getPaidSubsObjects().map((sub) {
                    final total = (sub.amber * bu.amber_price).toStringAsFixed(
                      2,
                    );
                    return _infoTile(
                      '${sub.name}',
                      '${sub.amber} أمبير — $total',
                    );
                  }).toList(),
            ),
            _infoCard(
              title: 'المشتركين غير الواصل (${bu.unpaid_subs.length})',
              items:
                  bu.getUnpaidSubsObjects().map((sub) {
                    final total = (sub.amber * bu.amber_price).toStringAsFixed(
                      2,
                    );
                    return _infoTile(
                      '${sub.name}',
                      ' (${sub.amber} أمبير ) — $total',
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text('رجوع'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }

  Widget _infoCard({required String title, required List<Widget> items}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.right,
            ),
            const Divider(),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  double calculateTotalPaid() {
    final paid = bu.getPaidSubsObjects();
    return paid.fold(0.0, (sum, sub) => sum + sub.amber * bu.amber_price);
  }

  double calculateTotalUnpaid() {
    final unpaid = bu.getUnpaidSubsObjects();
    return unpaid.fold(0.0, (sum, sub) => sum + sub.amber * bu.amber_price);
  }
}

// delete budget dialoge
class DeleteBudgetDialoge extends StatelessWidget {
  final BudgetService budget_service;
  final Budget bu;
  const DeleteBudgetDialoge(this.bu, this.budget_service, {super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('حذف الميزانية'),
      content: Text(
        'هل أنت متأكد من رغبتك في حذف هذه الميزانية ${bu.year_month} ؟',
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('رجوع'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await budget_service.removeBudget(bu.id);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('حذف'),
        ),
      ],
    );
  }
}
