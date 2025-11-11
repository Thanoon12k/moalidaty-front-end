import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/features/budgets/services/budget_service.dart';
import 'package:moalidaty/features/reciepts/models/receipt_model.dart';
import 'package:moalidaty/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty/features/reciepts/ui/list_reciepts.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty/features/subscripers/models/model.dart';
import 'package:moalidaty/features/budgets/models/budgets_model.dart';
import 'package:moalidaty/features/workers/models/model.dart';
import 'package:moalidaty/features/workers/controllers/worker_controller.dart';
import 'package:image_picker/image_picker.dart';

class AddReceiptDialoge extends StatefulWidget {
  final Subscriper? deisinatedSubscriper;
  final int? destination_month;
  final int? destination_year;
  const AddReceiptDialoge({
    super.key,
    this.deisinatedSubscriper,
    this.destination_month,
    this.destination_year,
  });

  @override
  State<AddReceiptDialoge> createState() => _AddReceiptDialogeState();
}

class _AddReceiptDialogeState extends State<AddReceiptDialoge> {
  final receiptService = Get.find<ReceiptServices>();

  late List<Subscriper> subscribers;
  late List<Gen_Worker> workers;
  late List<int> years;
  late List<int> months;
  late List<Budget> budgets;
  XFile? selectedImage;

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
    final subsService = Get.find<SubscribersService>();
    final budgetService = Get.find<BudgetService>();
    final workersService = Get.find<WorkerController>();

    subscribers = subsService.subscribersList;
    budgets = budgetService.BudgetList;
    workers = workersService.workersList;

    years = budgets.map((b) => b.year).toSet().toList()..sort();
    months = budgets.map((b) => b.month).toSet().toList()..sort();

    selectedSubscriber = widget.deisinatedSubscriper ?? subscribers.first;
    selectedYear = widget.destination_year ?? years.first;
    selectedMonth = widget.destination_month ?? months.first;

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
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('اختر صورة الإيصال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: selectImage,
              ),
              const SizedBox(height: 24),
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(selectedImage!.path),
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          imageFile: selectedImage,
                        ),
                      );
                      Navigator.of(context).pop();
                      Get.to(() => RecieptsListPage());
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

  Future<void> selectImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('اختر من المعرض'),
                onTap: () async {
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      selectedImage = image;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('التقط صورة بالكاميرا'),
                onTap: () async {
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() {
                      selectedImage = image;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dropdownSubs() {
    return DropdownButtonFormField<Subscriper>(
      initialValue: selectedSubscriber,
      decoration: const InputDecoration(
        labelText: 'اختر المشترك',
        border: OutlineInputBorder(),
      ),
      items: subscribers.map((sub) {
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
      initialValue: selectedWorker ?? workers.first,
      decoration: const InputDecoration(
        labelText: 'اختر المشغل',
        border: OutlineInputBorder(),
      ),
      items: workers.map((worker) {
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
      initialValue: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item.toString()));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
