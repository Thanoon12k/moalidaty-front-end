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

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'حقل مطلوب';
    if (v.trim().length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    return null;
  }

  String? _validateCircuit(String? v) {
    if (v == null || v.trim().isEmpty) return 'حقل مطلوب';
    return null;
  }

  String? _validateAmbers(String? v) {
    if (v == null || v.trim().isEmpty) return 'حقل مطلوب';
    final n = int.tryParse(v.trim());
    if (n == null || n < 1 || n > 50) return 'قيمة صحيحة بين 1 و 50';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return null; // optional
    final digits = v.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11 || !digits.startsWith('07')) {
      return 'رقم هاتف غير صالح (07XXXXXXXXX)';
    }
    return null;
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
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
          child: Form(
            key: _formKey,
            child: ListView(controller: sc, children: [
              const Text('إضافة مشترك جديد',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 20,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                textDirection: TextDirection.rtl,
                validator: _validateName,
                decoration: const InputDecoration(
                  labelText: 'اسم المشترك *',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _circuit,
                textDirection: TextDirection.ltr,
                validator: _validateCircuit,
                decoration: const InputDecoration(
                  labelText: 'رقم الجوزة *',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ambers,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                validator: _validateAmbers,
                decoration: const InputDecoration(
                  labelText: 'عدد الأمبيرات *',
                  suffixText: 'أمبير',
                  prefixIcon: Icon(Icons.electrical_services),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                validator: _validatePhone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: '07XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text('حفظ المشترك',
                    style: TextStyle(fontFamily: 'Cairo')),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
