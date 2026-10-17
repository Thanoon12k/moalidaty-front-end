import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/data/app_error.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/controls.dart';
import '../../../core/widgets/feedback.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../budgets/controllers/budget_controller.dart';
import '../../budgets/models/budget.dart';
import '../../budgets/ui/budget_form_sheet.dart';
import '../../subscribers/controllers/subscriber_controller.dart';
import '../../subscribers/models/subscriber.dart';
import '../../workers/controllers/worker_controller.dart';
import '../controllers/receipt_controller.dart';
import '../models/receipt.dart';
import 'qr_scanner_screen.dart';
import 'receipt_detail_sheet.dart';

/// Opens the "new receipt" sheet, optionally for a given subscriber / month.
Future<void> showReceiptForm({Subscriber? subscriber, MonthKey? month}) =>
    showFormSheet(_ReceiptForm(subscriber: subscriber, month: month));

class _ReceiptForm extends StatefulWidget {
  final Subscriber? subscriber;
  final MonthKey? month;
  const _ReceiptForm({this.subscriber, this.month});

  @override
  State<_ReceiptForm> createState() => _ReceiptFormState();
}

class _ReceiptFormState extends State<_ReceiptForm> {
  final _receipts = Get.find<ReceiptController>();
  final _budgets = Get.find<BudgetController>();
  final _workers = Get.find<WorkerController>();
  final _auth = Get.find<AuthController>();
  final _notes = TextEditingController();
  final _amount = TextEditingController();

  Subscriber? _subscriber;
  Budget? _budget;
  int? _workerId; // null = collected by the manager
  bool _customAmount = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _subscriber = widget.subscriber;
    final months = _budgets.items;
    final wanted = widget.month ?? MonthKey.of(DateTime.now());
    _budget = _budgets.budgetFor(wanted.year, wanted.month) ?? (months.isEmpty ? null : months.first);
    _workerId = _auth.profile.value?.workerId;
  }

  @override
  void dispose() {
    _notes.dispose();
    _amount.dispose();
    super.dispose();
  }

  double get _computed => (_budget?.amberPrice ?? 0) * (_subscriber?.ambers ?? 0);

  double get _total {
    if (!_customAmount) return _computed;
    return double.tryParse(_amount.text.replaceAll(',', '').trim()) ?? 0;
  }

  bool get _alreadyPaid =>
      _subscriber != null && _budget != null && _receipts.isPaid(_subscriber!.id, _budget!.year, _budget!.month);

  Future<void> _pickSubscriber() async {
    final s = await showSubscriberPicker(month: _budget == null ? null : MonthKey(_budget!.year, _budget!.month));
    if (s != null) setState(() => _subscriber = s);
  }

  Future<void> _scan() async {
    final id = await scanSubscriberQr();
    if (id == null) return;
    final s = Get.find<SubscriberController>().byId(id);
    if (s == null) {
      showSnack('المشترك غير موجود في هذه المولدة', error: true);
      return;
    }
    setState(() => _subscriber = s);
  }

  Future<void> _save() async {
    final s = _subscriber, b = _budget;
    if (s == null || b == null) return;
    if (_customAmount && Validators.amount(_amount.text) != null) {
      showSnack('أدخل مبلغاً صحيحاً', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final (outcome, receipt) = await _receipts.add(
        ReceiptInput(
          subscriberId: s.id,
          workerId: _workerId,
          year: b.year,
          month: b.month,
          amberPrice: b.amberPrice,
          amountPaid: _total,
          notes: _notes.text,
        ),
        s,
      );
      if (!mounted) return;
      Navigator.pop(context);
      if (outcome == SaveOutcome.queued) {
        showSnack('لا يوجد اتصال — حُفظ الإيصال في قائمة الانتظار وسيُرسل تلقائياً',
            icon: Icons.cloud_upload_rounded);
      } else {
        showSnack('تم تسجيل إيصال ${s.name}');
        if (receipt != null) showReceiptDetail(receipt);
      }
    } catch (e) {
      showSnack(describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final months = _budgets.items.take(6).toList();
    final isManager = _auth.isManager;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SheetTitle('إيصال جديد', subtitle: 'اختر المشترك والشهر ثم سجّل المبلغ المستلم'),

        if (months.isEmpty) ...[
          EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'لا توجد ميزانية بعد',
            subtitle: isManager ? 'حدد سعر الأمبير للشهر أولاً' : 'اطلب من مدير المولدة إضافة ميزانية الشهر',
            actionLabel: isManager ? 'إضافة ميزانية' : null,
            onAction: isManager
                ? () {
                    Navigator.pop(context);
                    showBudgetForm();
                  }
                : null,
          ),
        ] else ...[
          // ── Subscriber ──────────────────────────────────────────────────
          const FieldLabel('المشترك'),
          Row(children: [
            Expanded(
              child: AppCard(
                color: p.surfaceAlt,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                onTap: _pickSubscriber,
                child: Row(children: [
                  if (_subscriber == null)
                    IconTile(icon: Icons.person_search_rounded, color: p.primary, background: p.primarySoft, size: 40)
                  else
                    NameAvatar(name: _subscriber!.name, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _subscriber == null
                        ? Text('اختر المشترك', style: TextStyle(color: p.textSecondary, fontWeight: FontWeight.w600))
                        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(_subscriber!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary)),
                            Text('جوزة ${_subscriber!.circuitNumber} • ${_subscriber!.ambers} أمبير',
                                style: TextStyle(fontSize: 11.5, color: p.textMuted)),
                          ]),
                  ),
                  Icon(Icons.unfold_more_rounded, color: p.textMuted),
                ]),
              ),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: 'مسح رمز QR',
              child: Material(
                color: p.primarySoft,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _scan,
                  child: SizedBox(width: 60, height: 60, child: Icon(Icons.qr_code_scanner_rounded, color: p.primary)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),

          // ── Month ───────────────────────────────────────────────────────
          const FieldLabel('الشهر'),
          ChoiceChips<int>(
            selected: _budget?.id,
            onSelected: (id) => setState(() => _budget = months.firstWhere((b) => b.id == id)),
            options: [for (final b in months) (b.id, b.label)],
          ),
          const SizedBox(height: 18),

          // ── Amount ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              Text('المبلغ المستلم', style: TextStyle(fontSize: 12.5, color: p.textSecondary)),
              const SizedBox(height: 4),
              if (_customAmount)
                TextField(
                  controller: _amount,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: p.textPrimary),
                  decoration: InputDecoration(
                    fillColor: p.surface,
                    suffixText: Fmt.currency,
                    isDense: true,
                  ),
                )
              else
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(Fmt.money(_computed),
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: p.textPrimary)),
                ),
              const SizedBox(height: 6),
              if (_subscriber != null && _budget != null)
                Text('${_subscriber!.ambers} أمبير × ${Fmt.money(_budget!.amberPrice)}',
                    style: TextStyle(fontSize: 12, color: p.textMuted)),
              TextButton.icon(
                onPressed: () => setState(() {
                  _customAmount = !_customAmount;
                  _amount.text = _computed > 0 ? _computed.toStringAsFixed(0) : '';
                }),
                icon: Icon(_customAmount ? Icons.calculate_rounded : Icons.edit_rounded, size: 16),
                label: Text(_customAmount ? 'استخدام المبلغ المحسوب' : 'تعديل المبلغ (دفع جزئي أو خصم)'),
              ),
            ]),
          ),

          if (_alreadyPaid) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: p.warningSoft, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, color: p.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('هذا المشترك دفع ${_budget!.label} مسبقاً',
                      style: TextStyle(color: p.textPrimary, fontSize: 12.5)),
                ),
              ]),
            ),
          ],

          // ── Collector (manager only; a worker always collects as himself) ─
          if (isManager && _workers.active.isNotEmpty) ...[
            const SizedBox(height: 14),
            const FieldLabel('المحصّل'),
            DropdownButtonFormField<int?>(
              initialValue: _workerId,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.badge_outlined)),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('المدير (أنا)')),
                for (final w in _workers.active) DropdownMenuItem<int?>(value: w.id, child: Text(w.name)),
              ],
              onChanged: (v) => setState(() => _workerId = v),
            ),
          ],

          const SizedBox(height: 14),
          const FieldLabel('ملاحظات (اختياري)'),
          TextField(
            controller: _notes,
            maxLength: 500,
            maxLines: 2,
            minLines: 1,
            decoration: const InputDecoration(hintText: 'مثال: تم الدفع نقداً', counterText: ''),
          ),
          const SizedBox(height: 18),
          LoadingButton(
            label: 'تسجيل الإيصال',
            icon: Icons.check_rounded,
            loading: _saving,
            onPressed: (_subscriber == null || _budget == null || _alreadyPaid || _total <= 0) ? null : _save,
          ),
        ],
      ]),
    );
  }
}

/// Searchable list of subscribers; marks who already paid [month].
Future<Subscriber?> showSubscriberPicker({MonthKey? month}) =>
    showFormSheet<Subscriber>(_SubscriberPicker(month: month));

class _SubscriberPicker extends StatefulWidget {
  final MonthKey? month;
  const _SubscriberPicker({this.month});

  @override
  State<_SubscriberPicker> createState() => _SubscriberPickerState();
}

class _SubscriberPickerState extends State<_SubscriberPicker> {
  final _subs = Get.find<SubscriberController>();
  final _receipts = Get.find<ReceiptController>();
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final m = widget.month;
    final list = _subs.items
        .where((s) => _q.isEmpty || s.name.contains(_q) || s.circuitNumber.contains(_q) || s.phone.contains(_q))
        .toList()
      // Unpaid first: they are the ones being collected.
      ..sort((a, b) {
        if (m == null) return 0;
        final pa = _receipts.isPaid(a.id, m.year, m.month) ? 1 : 0;
        final pb = _receipts.isPaid(b.id, m.year, m.month) ? 1 : 0;
        return pa - pb;
      });

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(children: [
        const SheetTitle('اختر المشترك'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _q = v.trim()),
            decoration: const InputDecoration(
              hintText: 'بحث بالاسم أو رقم الجوزة أو الهاتف',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(icon: Icons.person_search_rounded, title: 'لا يوجد مشترك مطابق')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final s = list[i];
                    final paid = m != null && _receipts.isPaid(s.id, m.year, m.month);
                    return ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      leading: NameAvatar(name: s.name, size: 40),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('جوزة ${s.circuitNumber} • ${s.ambers} أمبير'),
                      trailing: paid
                          ? Pill(text: 'دفع', icon: Icons.check_rounded, color: p.success, background: p.successSoft)
                          : Pill(text: 'لم يدفع', color: p.danger, background: p.dangerSoft),
                      onTap: () => Navigator.pop(context, s),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
