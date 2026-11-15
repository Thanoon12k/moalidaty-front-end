import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/app_error.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/feedback.dart';
import '../controllers/subscriber_controller.dart';
import '../models/subscriber.dart';

/// Add a subscriber, or edit [subscriber].
Future<void> showSubscriberForm({Subscriber? subscriber}) =>
    showFormSheet(_SubscriberForm(subscriber: subscriber));

class _SubscriberForm extends StatefulWidget {
  final Subscriber? subscriber;
  const _SubscriberForm({this.subscriber});

  @override
  State<_SubscriberForm> createState() => _SubscriberFormState();
}

class _SubscriberFormState extends State<_SubscriberForm> {
  final _ctrl = Get.find<SubscriberController>();
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.subscriber?.name);
  late final _circuit = TextEditingController(text: widget.subscriber?.circuitNumber);
  late final _ambers = TextEditingController(text: widget.subscriber?.ambers.toString());
  late final _phone = TextEditingController(text: widget.subscriber?.phone);
  bool _saving = false;

  bool get _editing => widget.subscriber != null;

  @override
  void dispose() {
    _name.dispose();
    _circuit.dispose();
    _ambers.dispose();
    _phone.dispose();
    super.dispose();
  }

  String? _uniqueCircuit(String? v) {
    final base = Validators.circuit(v);
    if (base != null) return base;
    final taken = _ctrl.items.any((s) =>
        s.circuitNumber.trim() == v!.trim() && s.id != widget.subscriber?.id);
    return taken ? 'رقم الجوزة مستخدم لمشترك آخر' : null;
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final input = SubscriberInput(
      name: _name.text,
      circuitNumber: _circuit.text,
      ambers: int.parse(_ambers.text.trim()),
      phone: Validators.normalizePhone(_phone.text),
    );
    setState(() => _saving = true);
    try {
      if (_editing) {
        await _ctrl.edit(widget.subscriber!.id, input);
      } else {
        await _ctrl.add(input);
      }
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(_editing ? 'تم حفظ التعديلات' : 'تمت إضافة ${input.name.trim()}');
    } catch (e) {
      showSnack(describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SheetTitle(_editing ? 'تعديل المشترك' : 'مشترك جديد'),
          const FieldLabel('اسم المشترك'),
          TextFormField(
            controller: _name,
            textInputAction: TextInputAction.next,
            maxLength: 100,
            validator: Validators.name,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded), counterText: ''),
          ),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const FieldLabel('رقم الجوزة'),
                TextFormField(
                  controller: _circuit,
                  textInputAction: TextInputAction.next,
                  textDirection: TextDirection.ltr,
                  maxLength: 20,
                  validator: _uniqueCircuit,
                  decoration: const InputDecoration(
                      hintText: 'A-01', prefixIcon: Icon(Icons.tag_rounded), counterText: ''),
                ),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const FieldLabel('عدد الأمبيرات'),
                TextFormField(
                  controller: _ambers,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  validator: Validators.ambers,
                  decoration: const InputDecoration(
                      hintText: '5', prefixIcon: Icon(Icons.bolt_rounded), suffixText: 'أمبير'),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          const FieldLabel('رقم الهاتف (اختياري)'),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            validator: Validators.optionalPhone,
            onFieldSubmitted: (_) => _save(),
            decoration: const InputDecoration(hintText: '07XXXXXXXXX', prefixIcon: Icon(Icons.phone_rounded)),
          ),
          const SizedBox(height: 22),
          LoadingButton(
            label: _editing ? 'حفظ التعديلات' : 'إضافة المشترك',
            icon: Icons.check_rounded,
            loading: _saving,
            onPressed: _save,
          ),
        ]),
      ),
    );
  }
}
