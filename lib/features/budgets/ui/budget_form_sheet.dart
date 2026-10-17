import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/app_error.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/feedback.dart';
import '../controllers/budget_controller.dart';
import '../models/budget.dart';

/// Add a monthly budget, or edit the amber price of [budget].
Future<void> showBudgetForm({Budget? budget}) => showFormSheet(_BudgetForm(budget: budget));

class _BudgetForm extends StatefulWidget {
  final Budget? budget;
  const _BudgetForm({this.budget});

  @override
  State<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<_BudgetForm> {
  final _ctrl = Get.find<BudgetController>();
  final _form = GlobalKey<FormState>();
  late final _price = TextEditingController(text: widget.budget?.amberPrice.toStringAsFixed(0) ?? _suggestedPrice());
  late int _year;
  late int _month;
  bool _saving = false;

  bool get _editing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = widget.budget?.year ?? now.year;
    _month = widget.budget?.month ?? now.month;
    // Default to the first month that has no budget yet.
    if (!_editing) {
      while (_ctrl.budgetFor(_year, _month) != null) {
        final next = DateTime(_year, _month + 1);
        _year = next.year;
        _month = next.month;
      }
    }
  }

  String _suggestedPrice() => _ctrl.latest?.amberPrice.toStringAsFixed(0) ?? '';

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final price = double.parse(_price.text.replaceAll(',', '').trim());
    setState(() => _saving = true);
    try {
      if (_editing) {
        await _ctrl.updatePrice(widget.budget!.id, price);
      } else {
        await _ctrl.add(_year, _month, price);
      }
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(_editing ? 'تم تعديل سعر الأمبير' : 'تمت إضافة ميزانية ${Fmt.monthName(_month)} $_year');
    } catch (e) {
      showSnack(describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final years = [for (var y = DateTime.now().year - 2; y <= DateTime.now().year + 1; y++) y];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SheetTitle(
            _editing ? 'تعديل ميزانية ${widget.budget!.label}' : 'ميزانية شهرية جديدة',
            subtitle: 'سعر الأمبير الواحد لهذا الشهر — يُحسب منه مبلغ كل إيصال',
          ),
          if (!_editing) ...[
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const FieldLabel('الشهر'),
                  DropdownButtonFormField<int>(
                    initialValue: _month,
                    items: [
                      for (var m = 1; m <= 12; m++) DropdownMenuItem(value: m, child: Text(Fmt.monthName(m))),
                    ],
                    onChanged: (v) => setState(() => _month = v!),
                  ),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const FieldLabel('السنة'),
                  DropdownButtonFormField<int>(
                    initialValue: years.contains(_year) ? _year : years.last,
                    items: [for (final y in years) DropdownMenuItem(value: y, child: Text('$y'))],
                    onChanged: (v) => setState(() => _year = v!),
                  ),
                ]),
              ),
            ]),
            if (_ctrl.budgetFor(_year, _month) != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('توجد ميزانية لهذا الشهر مسبقاً',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ),
            const SizedBox(height: 14),
          ],
          const FieldLabel('سعر الأمبير'),
          TextFormField(
            controller: _price,
            autofocus: _editing,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.ltr,
            validator: Validators.price,
            decoration: const InputDecoration(
              hintText: '13000',
              suffixText: Fmt.currency,
              prefixIcon: Icon(Icons.bolt_rounded),
            ),
          ),
          const SizedBox(height: 22),
          LoadingButton(
            label: _editing ? 'حفظ التعديل' : 'إضافة الميزانية',
            icon: Icons.check_rounded,
            loading: _saving,
            onPressed: !_editing && _ctrl.budgetFor(_year, _month) != null ? null : _save,
          ),
        ]),
      ),
    );
  }
}
