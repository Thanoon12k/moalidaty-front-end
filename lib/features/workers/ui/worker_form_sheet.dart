import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Worker;

import '../../../core/data/app_error.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/feedback.dart';
import '../controllers/worker_controller.dart';
import '../models/worker.dart';

/// Add a worker (with password) or edit [worker]'s name / phone.
Future<void> showWorkerForm({Worker? worker}) => showFormSheet(_WorkerForm(worker: worker));

/// Set a new password for [worker].
Future<void> showWorkerPasswordForm(Worker worker) => showFormSheet(_WorkerPasswordForm(worker: worker));

class _WorkerForm extends StatefulWidget {
  final Worker? worker;
  const _WorkerForm({this.worker});

  @override
  State<_WorkerForm> createState() => _WorkerFormState();
}

class _WorkerFormState extends State<_WorkerForm> {
  final _ctrl = Get.find<WorkerController>();
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.worker?.name);
  late final _phone = TextEditingController(text: widget.worker?.phone);
  final _password = TextEditingController();
  bool _obscure = true;
  bool _saving = false;

  bool get _editing => widget.worker != null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final phone = Validators.normalizePhone(_phone.text);
    setState(() => _saving = true);
    try {
      if (_editing) {
        await _ctrl.edit(widget.worker!.id, _name.text, phone);
      } else {
        await _ctrl.create(_name.text, phone, _password.text);
      }
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(_editing ? 'تم حفظ التعديلات' : 'تمت إضافة العامل — يدخل برقم هاتفه وكلمة المرور');
    } catch (e) {
      showSnack(describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SheetTitle(
              _editing ? 'تعديل بيانات العامل' : 'عامل جديد',
              subtitle: _editing ? null : 'يسجّل العامل دخوله برقم الهاتف وكلمة المرور',
            ),
            const FieldLabel('اسم العامل'),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              validator: Validators.name,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.badge_outlined)),
            ),
            const SizedBox(height: 12),
            const FieldLabel('رقم الهاتف'),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textInputAction: _editing ? TextInputAction.done : TextInputAction.next,
              validator: Validators.phone,
              decoration: const InputDecoration(hintText: '07XXXXXXXXX', prefixIcon: Icon(Icons.phone_iphone_rounded)),
            ),
            if (!_editing) ...[
              const SizedBox(height: 12),
              const FieldLabel('كلمة المرور'),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                validator: Validators.password,
                onFieldSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  hintText: '6 أحرف على الأقل',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'إظهار' : 'إخفاء',
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            LoadingButton(
              label: _editing ? 'حفظ التعديلات' : 'إضافة العامل',
              icon: Icons.check_rounded,
              loading: _saving,
              onPressed: _save,
            ),
          ]),
        ),
      );
}

class _WorkerPasswordForm extends StatefulWidget {
  final Worker worker;
  const _WorkerPasswordForm({required this.worker});

  @override
  State<_WorkerPasswordForm> createState() => _WorkerPasswordFormState();
}

class _WorkerPasswordFormState extends State<_WorkerPasswordForm> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await Get.find<WorkerController>().setPassword(widget.worker.id, _password.text);
      if (!mounted) return;
      Navigator.pop(context);
      showSnack('تم تغيير كلمة مرور ${widget.worker.name}');
    } catch (e) {
      showSnack(describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SheetTitle('كلمة مرور جديدة', subtitle: widget.worker.name),
            TextFormField(
              controller: _password,
              autofocus: true,
              validator: Validators.password,
              onFieldSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                hintText: '6 أحرف على الأقل',
                prefixIcon: Icon(Icons.lock_reset_rounded),
              ),
            ),
            const SizedBox(height: 20),
            LoadingButton(label: 'حفظ', icon: Icons.check_rounded, loading: _saving, onPressed: _save),
          ]),
        ),
      );
}
