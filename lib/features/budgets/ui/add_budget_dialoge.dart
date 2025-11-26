import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/budgets/models/budgets_model.dart';
import 'package:moalidaty/features/budgets/services/budget_service.dart';

class AddBudgetDialoge extends StatelessWidget {
  AddBudgetDialoge({super.key});
  BudgetService budgetService = Get.find<BudgetService>();
  final List<String> _months_list = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];
  final List<String> _years_list = List.generate(
    11,
    (index) => (2020 + index).toString(),
  );
  int _selected_month = DateTime.now().month;
  int _selected_year = DateTime.now().year;
  final _price_per_ampere = TextEditingController(text: '1000.0');
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة ميزانية جديدة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          DropdownMenu(
            label: const Text('السنة'),
            initialSelection: _selected_year.toString(),
            onSelected: (value) => _selected_year = int.parse(value!),
            dropdownMenuEntries: _years_list
                .map((year) => DropdownMenuEntry(value: year, label: year))
                .toList(),
          ),
          SizedBox(height: 20),

          DropdownMenu(
            label: const Text('الشهر'),
            initialSelection: _selected_month.toString(),
            onSelected: (value) => _selected_month = int.parse(value!),
            dropdownMenuEntries: _months_list
                .map((month) => DropdownMenuEntry(value: month, label: month))
                .toList(),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _price_per_ampere,
            decoration: const InputDecoration(
              labelText: 'سعر الأمبير',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          // يمكنك إضافة حقول أخرى حسب الحاجة
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_back),
          label: const Text('رجوع'),

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            // padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          label: const Text('     حفظ      '),

          icon: const Icon(Icons.check, size: 20),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            // padding: const EdgeInsets.symmetric(vertical: 5),
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: () {
            // هنا يمكنك إضافة منطق حفظ الميزانية الجديدة
            // Navigator.pop(context);
            final newBudget = Budget(
              generator: GlobalConstants.accountID!,
              amber_price: double.tryParse(_price_per_ampere.text)!,
              year: _selected_year,
              month: _selected_month,
              budget_uuid: "$_selected_year-$_selected_month",
              paid_subs: [],
              unpaid_subs: [],
            );
            budgetService.addBudget(newBudget);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
