import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/features/budgets/services/budget_service.dart';
import 'package:moalidaty1/features/reciepts/models/receipt_model.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/reciepts/services/service_recepts.dart';

class AddReceiptDialoge extends StatelessWidget {
  AddReceiptDialoge({super.key});

  final totalPaidCtrl = TextEditingController();
  final ampereCtrl = TextEditingController();

  final selectedSubscriperId = RxnInt();
  final selectedMonth = RxInt(1);
  final selectedYear = RxInt(DateTime.now().year);

  int subsciperAmbers = 0;

  @override
  Widget build(BuildContext context) {
    final subscriperService = Get.find<SubscripersService>();
    final budgetService = Get.find<BudgetService>();
    final receiptService = Get.find<RecieptServices>();

    final months =
        budgetService.list_budgets.map((b) => b.month).toSet().toList()..sort();
    final years =
        budgetService.list_budgets.map((b) => b.year).toSet().toList()..sort();

    return AlertDialog(
      title: const Text('إضافة إيصال جديد'),
      content: SingleChildScrollView(
        child: Obx(() {
          final subs = subscriperService.list_subs;

          if (subs.isEmpty || months.isEmpty || years.isEmpty) {
            return const Center(child: Text('البيانات غير متوفرة'));
          }

          selectedSubscriperId.value ??= subs.last.id;
          selectedMonth.value = months.last;
          selectedYear.value = years.last;

          return Column(
            children: [
              DropdownButtonFormField<int>(
                value: selectedSubscriperId.value,
                decoration: const InputDecoration(
                  labelText: 'المشترك',
                  border: OutlineInputBorder(),
                ),
                items:
                    subs.map((s) {
                      return DropdownMenuItem<int>(
                        value: s.id,
                        child: Text(s.name),
                      );
                    }).toList(),
                onChanged: (val) => selectedSubscriperId.value = val,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedYear.value,
                decoration: const InputDecoration(
                  labelText: 'السنة',
                  border: OutlineInputBorder(),
                ),
                items:
                    years.map((y) {
                      return DropdownMenuItem<int>(
                        value: y,
                        child: Text(y.toString()),
                      );
                    }).toList(),
                onChanged:
                    (val) => selectedYear.value = val ?? DateTime.now().year,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedMonth.value,
                decoration: const InputDecoration(
                  labelText: 'الشهر',
                  border: OutlineInputBorder(),
                ),
                items:
                    months.map((m) {
                      return DropdownMenuItem<int>(
                        value: m,
                        child: Text(m.toString()),
                      );
                    }).toList(),
                onChanged: (val) {
                  selectedMonth.value = val ?? 1;

                  final budget = budgetService.list_budgets.firstWhere(
                    (b) =>
                        b.month == selectedMonth.value &&
                        b.year == selectedYear.value,
                    orElse: () => budgetService.list_budgets.first,
                  );

                  ampereCtrl.text = budget.amber_price.toString();

                  final subscriper = subs.firstWhere(
                    (s) => s.id == selectedSubscriperId.value,
                    orElse: () => subs.first,
                  );

                  subsciperAmbers = subscriper.amber;
                  totalPaidCtrl.text = (subsciperAmbers * budget.amber_price)
                      .toStringAsFixed(2);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ampereCtrl,
                decoration: const InputDecoration(
                  labelText: 'سعر الامبير',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: totalPaidCtrl,
                decoration: const InputDecoration(
                  labelText: 'المبلغ الكلي المدفوع',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }),
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
            if (selectedSubscriperId.value != null) {
              final receipt = Reciept(
                amberPrice: double.tryParse(ampereCtrl.text) ?? 0.0,
                amountPaid: double.tryParse(totalPaidCtrl.text) ?? 0.0,
                month: selectedMonth.value,
                year: selectedYear.value,
                subscriber: selectedSubscriperId.value!,
                dateReceived: DateTime.now(),
              );
              receiptService.addReciept(receipt);
              Navigator.pop(context);
            } else {
              Get.snackbar('خطأ', 'يرجى اختيار مشترك صالح');
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
