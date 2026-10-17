import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/analytics/analytics_controller.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/controls.dart';
import '../../../core/widgets/feedback.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../receipts/controllers/receipt_controller.dart';
import '../../receipts/ui/receipt_form_sheet.dart';
import '../../receipts/ui/receipt_tile.dart';
import '../../receipts/ui/subscriber_qr.dart';
import '../controllers/subscriber_controller.dart';
import '../models/subscriber.dart';
import 'subscriber_form_sheet.dart';

/// Payment history of one subscriber (styled after the reference "Stock Details").
class SubscriberDetailScreen extends StatefulWidget {
  final int subscriberId;
  const SubscriberDetailScreen({super.key, required this.subscriberId});

  @override
  State<SubscriberDetailScreen> createState() => _SubscriberDetailScreenState();
}

class _SubscriberDetailScreenState extends State<SubscriberDetailScreen> {
  final _subs = Get.find<SubscriberController>();
  final _stats = Get.find<AnalyticsController>();
  final _auth = Get.find<AuthController>();
  int _range = 6; // months shown in the chart (0 = all)

  Future<void> _archive(Subscriber s) async {
    final ok = await confirmAction(
      title: 'إيقاف الاشتراك',
      message: 'سيُخفى "${s.name}" من القوائم مع الاحتفاظ بإيصالاته. متابعة؟',
      confirm: 'إيقاف',
      destructive: true,
    );
    if (!ok) return;
    if (await guard(() => _subs.archive(s.id), success: 'تم إيقاف الاشتراك')) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Obx(() {
      final s = _subs.byId(widget.subscriberId);
      final a = _stats.analytics.value;
      if (s == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: EmptyState(icon: Icons.person_off_outlined, title: 'المشترك غير موجود')),
        );
      }
      final standing = a.standing(s);
      final receipts = a.receiptsOf(s.id).toList()..sort((x, y) => y.period.compareTo(x.period));
      final owedMonths = a.months.where((m) => s.dateSubscribed == null || !s.dateSubscribed!.isAfter(m.end)).toList();
      final byPeriod = {for (final r in receipts) r.period: r.amountPaid};
      final shown = _range == 0 || owedMonths.length <= _range
          ? owedMonths
          : owedMonths.sublist(owedMonths.length - _range);
      final focus = _stats.focusMonth;
      final paidFocus = Get.find<ReceiptController>().isPaid(s.id, focus.year, focus.month);
      final hasFocusBudget = a.budgetFor(focus) != null;
      final avg = receipts.isEmpty ? 0.0 : standing.totalPaid / receipts.length;

      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المشترك'),
          actions: [
            if (_auth.isManager)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (v) => v == 'edit' ? showSubscriberForm(subscriber: s) : _archive(s),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('تعديل البيانات')),
                  PopupMenuItem(value: 'archive', child: Text('إيقاف الاشتراك')),
                ],
              ),
          ],
        ),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 32), children: [
          // ── Identity + headline number ───────────────────────────────────
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                NameAvatar(name: s.name, size: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: p.textPrimary)),
                    Text(
                      ['جوزة ${s.circuitNumber}', '${s.ambers} أمبير', if (s.phone.isNotEmpty) s.phone].join(' • '),
                      style: TextStyle(fontSize: 12, color: p.textMuted),
                    ),
                  ]),
                ),
              ]),
              const SizedBox(height: 16),
              Text('إجمالي المدفوع', style: TextStyle(fontSize: 12, color: p.textSecondary)),
              Text(Fmt.money(standing.totalPaid),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: p.textPrimary)),
              const SizedBox(height: 4),
              Row(children: [
                Pill(
                  text: '${standing.paidMonths} من ${owedMonths.length} أشهر',
                  icon: Icons.check_circle_rounded,
                  color: p.success,
                  background: p.successSoft,
                ),
                const SizedBox(width: 8),
                if (standing.unpaidMonths > 0)
                  Pill(
                    text: '${standing.unpaidMonths} غير مدفوع',
                    icon: Icons.error_outline_rounded,
                    color: p.danger,
                    background: p.dangerSoft,
                  ),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                height: 190,
                child: shown.isEmpty
                    ? Center(child: Text('لا توجد أشهر مسجّلة بعد', style: TextStyle(color: p.textMuted)))
                    : SubscriberHistoryChart(months: [for (final m in shown) (m, byPeriod[m.period])]),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: ChartLegend(
                    alignment: WrapAlignment.start,
                    items: [('مدفوع', p.series[0]), ('غير مدفوع', p.danger)],
                  ),
                ),
                SegmentedToggle<int>(
                  selected: _range,
                  onChanged: (v) => setState(() => _range = v),
                  options: const [(6, '6 أشهر'), (12, 'سنة'), (0, 'الكل')],
                ),
              ]),
              const SizedBox(height: 14),
              Divider(color: p.border),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                StatColumn(
                  value: receipts.isEmpty ? '—' : Fmt.date(receipts.first.dateReceived),
                  label: 'آخر دفعة',
                ),
                StatColumn(value: avg == 0 ? '—' : Fmt.compactMoney(avg), label: 'متوسط الدفعة'),
                StatColumn(value: '${standing.unpaidMonths}', label: 'أشهر متأخرة'),
                StatColumn(
                  value: s.dateSubscribed == null ? '—' : Fmt.date(s.dateSubscribed!),
                  label: 'تاريخ الاشتراك',
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          if (hasFocusBudget)
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: paidFocus ? null : () => showReceiptForm(subscriber: s, month: focus),
                icon: Icon(paidFocus ? Icons.check_circle_rounded : Icons.add_card_rounded),
                label: Text(paidFocus ? 'دفع ${focus.label}' : 'تسجيل دفعة ${focus.label}'),
              ),
            ),

          // ── Month by month ───────────────────────────────────────────────
          if (owedMonths.isNotEmpty) ...[
            const SectionHeader(title: 'الأشهر'),
            AppCard(
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (final m in owedMonths.reversed)
                  byPeriod.containsKey(m.period)
                      ? Pill(text: m.label, icon: Icons.check_rounded, color: p.success, background: p.successSoft)
                      : Pill(text: m.label, icon: Icons.close_rounded, color: p.danger, background: p.dangerSoft),
              ]),
            ),
          ],

          // ── QR ───────────────────────────────────────────────────────────
          const SectionHeader(title: 'رمز QR للمشترك'),
          _QrCard(subscriber: s),

          // ── Receipts ─────────────────────────────────────────────────────
          SectionHeader(title: 'الإيصالات', trailing: Text('${receipts.length}')),
          if (receipts.isEmpty)
            const AppCard(child: EmptyState(icon: Icons.receipt_long_outlined, title: 'لا توجد إيصالات لهذا المشترك'))
          else
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(children: [for (final r in receipts) ReceiptTile(receipt: r, dense: true, showWorker: true)]),
            ),
        ]),
      );
    });
  }
}

class _QrCard extends StatelessWidget {
  final Subscriber subscriber;
  const _QrCard({required this.subscriber});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final data = subscriberQrData(subscriber.id, subscriber.generatorId);
    Widget qr(double size) => Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: QrImageView(
            data: data,
            size: size,
            padding: EdgeInsets.zero,
            eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: AppPalette.light.primary),
            dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square, color: Color(0xFF181B2C)),
          ),
        );

    return AppCard(
      onTap: () => showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(subscriber.name, textAlign: TextAlign.center),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            qr(220),
            const SizedBox(height: 12),
            Text('جوزة ${subscriber.circuitNumber} • ${subscriber.ambers} أمبير'),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('إغلاق'))],
        ),
      ),
      child: Row(children: [
        qr(84),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('امسح الرمز لتسجيل دفعة سريعة',
                style: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary)),
            const SizedBox(height: 4),
            Text('يُطبع الرمز على كل إيصال، فيكفي مسحه في الشهر التالي',
                style: TextStyle(fontSize: 12, color: p.textSecondary)),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.zoom_in_rounded, size: 16, color: p.primary),
              const SizedBox(width: 4),
              Text('اضغط للتكبير', style: TextStyle(fontSize: 12, color: p.primary, fontWeight: FontWeight.w700)),
            ]),
          ]),
        ),
      ]),
    );
  }
}
