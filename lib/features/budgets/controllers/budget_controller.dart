import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../../../core/network/api_client.dart';
import '../models/budget.dart';

class BudgetController extends GetxController {
  final _dio = Get.find<ApiClient>().dio;

  final items     = <Budget>[].obs;
  final isLoading = false.obs;
  final errorMsg  = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final res = await _dio.get('/budgets/');
      items.value = (res.data as List)
          .map((j) => Budget.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      errorMsg.value = _err(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> add(int year, int month, double amberPrice) async {
    try {
      final res = await _dio.post('/budgets/', data: {
        'year': year,
        'month': month,
        'amber_price': amberPrice,
      });
      items.insert(0, Budget.fromJson(res.data as Map<String, dynamic>));
      return true;
    } on DioException catch (e) {
      errorMsg.value = _err(e);
      return false;
    }
  }

  Budget? budgetFor(int year, int month) {
    try {
      return items.firstWhere((b) => b.year == year && b.month == month);
    } catch (_) {
      return null;
    }
  }

  String _err(DioException e) {
    final d = e.response?.data;
    if (d is Map && d.containsKey('detail')) return d['detail'];
    return 'حدث خطأ';
  }

  void showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddBudgetSheet(),
    );
  }
}

class _AddBudgetSheet extends StatefulWidget {
  const _AddBudgetSheet();
  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final _ctrl = Get.find<BudgetController>();
  int _year  = DateTime.now().year;
  int _month = DateTime.now().month;
  final _price = TextEditingController();
  bool _loading = false;

  static const _months = ['','يناير','فبراير','مارس','أبريل','مايو','يونيو',
    'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];

  @override
  void dispose() { _price.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24, left: 24, right: 24,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('إضافة ميزانية شهرية',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 20,
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: DropdownButtonFormField<int>(
            value: _year,
            decoration: const InputDecoration(labelText: 'السنة'),
            items: List.generate(5, (i) => DateTime.now().year - 2 + i)
                .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                .toList(),
            onChanged: (v) => setState(() => _year = v!),
          )),
          const SizedBox(width: 12),
          Expanded(child: DropdownButtonFormField<int>(
            value: _month,
            decoration: const InputDecoration(labelText: 'الشهر'),
            items: List.generate(12, (i) => i + 1)
                .map((m) => DropdownMenuItem(value: m, child: Text(_months[m])))
                .toList(),
            onChanged: (v) => setState(() => _month = v!),
          )),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: _price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(
              labelText: 'سعر الأمبير *', suffixText: 'د.ع'),
        ),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: _loading ? null : () async {
            final price = double.tryParse(_price.text.trim()) ?? 0;
            if (price <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('أدخل سعر صحيح')));
              return;
            }
            setState(() => _loading = true);
            final ok = await _ctrl.add(_year, _month, price);
            setState(() => _loading = false);
            if (ok && mounted) Navigator.pop(context);
          },
          child: _loading
              ? const SizedBox(width:20,height:20,
                  child: CircularProgressIndicator(color:Colors.white,strokeWidth:2))
              : const Text('حفظ الميزانية'),
        )),
      ]),
    );
  }
}
