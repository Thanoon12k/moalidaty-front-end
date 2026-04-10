import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../../../core/network/api_client.dart';
import '../models/subscriber.dart';

class SubscriberController extends GetxController {
  final _dio = Get.find<ApiClient>().dio;

  final items      = <Subscriber>[].obs;
  final isLoading  = false.obs;
  final errorMsg   = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final res = await _dio.get('/subscribers/');
      items.value = (res.data as List)
          .map((j) => Subscriber.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      errorMsg.value = _err(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> add(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/subscribers/', data: data);
      items.insert(0, Subscriber.fromJson(res.data as Map<String, dynamic>));
      return true;
    } on DioException catch (e) {
      errorMsg.value = _err(e);
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _dio.delete('/subscribers/$id/');
      items.removeWhere((s) => s.id == id);
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
      builder: (_) => const _AddSubscriberSheet(),
    );
  }
}

// ─── Add subscriber bottom sheet ──────────────────────────────────────────────
class _AddSubscriberSheet extends StatefulWidget {
  const _AddSubscriberSheet();

  @override
  State<_AddSubscriberSheet> createState() => _AddSubscriberSheetState();
}

class _AddSubscriberSheetState extends State<_AddSubscriberSheet> {
  final _ctrl = Get.find<SubscriberController>();
  final _name    = TextEditingController();
  final _circuit = TextEditingController();
  final _ambers  = TextEditingController();
  final _phone   = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose(); _circuit.dispose();
    _ambers.dispose(); _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _circuit.text.trim().isEmpty ||
        _ambers.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة الحقول المطلوبة')),
      );
      return;
    }
    setState(() => _loading = true);
    final ok = await _ctrl.add({
      'name':           _name.text.trim(),
      'circuit_number': _circuit.text.trim(),
      'ambers':         int.tryParse(_ambers.text.trim()) ?? 0,
      'phone':          _phone.text.trim(),
    });
    setState(() => _loading = false);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(controller: sc, children: [
            const Text('إضافة مشترك جديد',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 20,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextField(controller: _name,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'اسم المشترك *')),
            const SizedBox(height: 12),
            TextField(controller: _circuit,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(labelText: 'رقم الجوزة *')),
            const SizedBox(height: 12),
            TextField(controller: _ambers,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(labelText: 'عدد الأمبيرات *', suffixText: 'أمبير')),
            const SizedBox(height: 12),
            TextField(controller: _phone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(labelText: 'رقم الهاتف', hintText: '07XXXXXXXXX')),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('حفظ المشترك'),
            ),
          ]),
        ),
      ),
    );
  }
}
