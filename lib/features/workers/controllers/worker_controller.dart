import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, Worker;

import '../../../core/network/api_client.dart';
import '../models/worker.dart';

class WorkerController extends GetxController {
  final _dio = Get.find<ApiClient>().dio;

  final items     = <Worker>[].obs;
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
      final res = await _dio.get('/workers/');
      items.value = (res.data as List)
          .map((j) => Worker.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      errorMsg.value = _err(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> add(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/workers/', data: data);
      items.insert(0, Worker.fromJson(res.data as Map<String, dynamic>));
      return true;
    } on DioException catch (e) {
      errorMsg.value = _err(e);
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _dio.delete('/workers/$id/');
      items.removeWhere((w) => w.id == id);
      return true;
    } on DioException catch (e) {
      errorMsg.value = _err(e);
      return false;
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
      builder: (_) => const _AddWorkerSheet(),
    );
  }
}

class _AddWorkerSheet extends StatefulWidget {
  const _AddWorkerSheet();
  @override
  State<_AddWorkerSheet> createState() => _AddWorkerSheetState();
}

class _AddWorkerSheetState extends State<_AddWorkerSheet> {
  final _ctrl = Get.find<WorkerController>();
  final _name  = TextEditingController();
  final _phone = TextEditingController();
  final _pass  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() { _name.dispose(); _phone.dispose(); _pass.dispose(); super.dispose(); }

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
        const Text('إضافة عامل جديد',
            style: TextStyle(fontFamily:'Cairo',fontSize:20,fontWeight:FontWeight.w700),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        TextField(controller: _name, textDirection: TextDirection.rtl,
            decoration: const InputDecoration(labelText: 'اسم العامل *')),
        const SizedBox(height: 12),
        TextField(controller: _phone, keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(labelText: 'رقم الهاتف *', hintText: '07XXXXXXXXX')),
        const SizedBox(height: 12),
        TextField(
          controller: _pass,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'كلمة المرور *',
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: _loading ? null : () async {
            if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty ||
                _pass.text.trim().length < 4) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('تأكد من تعبئة جميع الحقول وكلمة مرور ≥4 أحرف')));
              return;
            }
            setState(() => _loading = true);
            final ok = await _ctrl.add({
              'name': _name.text.trim(),
              'phone': _phone.text.trim(),
              'password': _pass.text.trim(),
            });
            setState(() => _loading = false);
            if (ok && mounted) Navigator.pop(context);
          },
          child: _loading
              ? const SizedBox(width:20,height:20,
                  child: CircularProgressIndicator(color:Colors.white,strokeWidth:2))
              : const Text('حفظ العامل'),
        )),
      ]),
    );
  }
}
