import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/features/budgets/services/budget_service.dart';
import 'package:moalidaty1/features/reciepts/models/receipt_model.dart';
import 'package:moalidaty1/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/budgets/models/budgets_model.dart';
import 'package:moalidaty1/features/workers/models/model.dart';
import 'package:moalidaty1/features/workers/services/service_worker.dart';

class AddReceiptDialoge extends StatefulWidget {
  const AddReceiptDialoge({super.key});

  @override
  State<AddReceiptDialoge> createState() => _AddReceiptDialogeState();
}

class _AddReceiptDialogeState extends State<AddReceiptDialoge> {
  final receiptService = Get.find<RecieptServices>();

  late List<Subscriper> subscribers;
  late List<Gen_Worker> workers;
  late List<int> years;
  late List<int> months;
  late List<Budget> budgets;

  Subscriper? selectedSubscriber;
  Gen_Worker? selectedWorker;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  double amberPrice = 0.0;
  int subscriberAmbers = 0;
  double totalPaid = 0.0;

  @override
  void initState() {
    super.initState();
    final subsService = Get.find<SubscripersService>();
    final budgetService = Get.find<BudgetService>();
    final workersService = Get.find<WorkerService>();

    subscribers = subsService.subscripers_list;
    budgets = budgetService.list_budgets;
    workers = workersService.workers_list;

    years = budgets.map((b) => b.year).toSet().toList()..sort();
    months = budgets.map((b) => b.month).toSet().toList()..sort();

    if (subscribers.isNotEmpty) {
      selectedSubscriber = subscribers.first;
    }

    updateValues();
  }

  void updateValues() {
    if (selectedSubscriber == null) return;

    final matchingBudget = budgets.firstWhere(
      (b) => b.year == selectedYear && b.month == selectedMonth,
      orElse: () => budgets.first,
    );

    setState(() {
      amberPrice = matchingBudget.amber_price;
      subscriberAmbers = selectedSubscriber!.amber;
      totalPaid = amberPrice * subscriberAmbers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.all(16),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'إضافة إيصال جديد',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              _dropdownSubs(),
              const SizedBox(height: 12),

              _dropdownInt('السنة', years, selectedYear, (val) {
                selectedYear = val!;
                updateValues();
              }),
              const SizedBox(height: 12),

              _dropdownInt('الشهر', months, selectedMonth, (val) {
                selectedMonth = val!;
                updateValues();
              }),
              const SizedBox(height: 12),

              _dropdownWorker(),
              const SizedBox(height: 16),

              _infoRow(
                'عدد الأمبيرات',
                '$subscriberAmbers',
                Icons.flash_on,
                Colors.orange,
              ),
              _infoRow(
                'سعر الأمبير',
                '${amberPrice.toStringAsFixed(2)} د.ع',
                Icons.price_change,
                Colors.blue,
              ),
              _infoRow(
                'المبلغ الكلي المدفوع',
                '${totalPaid.toStringAsFixed(2)} د.ع',
                Icons.attach_money,
                Colors.red,
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(' رجوع '),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      // padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text(' تسجيل الإيصال '),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      // padding: const EdgeInsets.symmetric(vertical: 5),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      receiptService.addReciept(
                        Reciept(
                          subscriber: selectedSubscriber!.id,
                          worker: selectedWorker?.id,
                          year: selectedYear,
                          month: selectedMonth,
                          amberPrice: amberPrice,
                          amountPaid: totalPaid,
                          dateReceived: DateTime.now(),
                          image: null
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownSubs() {
    return DropdownButtonFormField<Subscriper>(
      value: selectedSubscriber,
      decoration: const InputDecoration(
        labelText: 'اختر المشترك',
        border: OutlineInputBorder(),
      ),
      items:
          subscribers.map((sub) {
            return DropdownMenuItem(value: sub, child: Text(sub.name));
          }).toList(),
      onChanged: (val) {
        selectedSubscriber = val;
        updateValues();
      },
    );
  }

  Widget _dropdownWorker() {
    return DropdownButtonFormField<Gen_Worker>(
      value: selectedWorker,
      decoration: const InputDecoration(
        labelText: 'اختر المشغل',
        border: OutlineInputBorder(),
      ),
      items:
          workers.map((worker) {
            return DropdownMenuItem(value: worker, child: Text(worker.name));
          }).toList(),
      onChanged: (val) {
        setState(() {
          selectedWorker = val;
        });
      },
    );
  }

  Widget _dropdownInt(
    String label,
    List<int> items,
    int selectedValue,
    ValueChanged<int?> onChanged,
  ) {
    return DropdownButtonFormField<int>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item.toString()));
          }).toList(),
      onChanged: onChanged,
    );
  }
}
