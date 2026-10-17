import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/analytics/analytics_controller.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/controls.dart';
import '../../../core/widgets/feedback.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../receipts/ui/receipt_form_sheet.dart';
import '../../receipts/ui/receipt_tile.dart';
import '../../subscribers/ui/subscriber_detail_screen.dart';
import '../controllers/budget_controller.dart';
import 'budget_card.dart';
import 'budget_form_sheet.dart';

/// One month: collected vs expected, who paid and who still owes.
class BudgetDetailScreen extends StatefulWidget {
  final MonthKey month;
  const BudgetDetailScreen({super.key, required this.month});

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  final _stats = Get.find<AnalyticsController>();
  final _auth = Get.find<AuthController>();
  late MonthKey _month = widget.month;
  bool _showUnpaid = true;

  // Fixed dark header, as in the reference "Budget Detail" screen.
  static const _night = Color(0xFF141726);

  Future<void> _delete() async {
    final budget = _stats.analytics.value.budgetFor(_month);
    if (budget == null) return;
    final ok = await confirmAction(
      title: 'حذف الميزانية',
      message: 'ستُحذف ميزانية ${budget.label}. الإيصالات المسجّلة لهذا الشهر لن تُحذف.',
      confirm: 'حذف',
      destructive: true,
    );
    if (!ok) return;
    final done = await guard(() => Get.find<BudgetController>().delete(budget.id), success: 'تم حذف الميزانية');
    if (done) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Obx(() {
      final a = _stats.analytics.value;
      final months = a.months;
      final i = months.indexOf(_month);
      final s = a.summary(_month);
      final budget = a.budgetFor(_month);
      final (color, _, message, icon) = collectionStatus(p, s);
      final unpaid = a.unpaidIn(_month);
      final paid = a.receiptsIn(_month);

      return Scaffold(
        backgroundColor: p.background,
        body: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: _night,
            foregroundColor: Colors.white,
            title: Text('ميزانية ${_month.label}', style: const TextStyle(color: Colors.white)),
            actions: [
              if (_auth.isManager && budget != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  onSelected: (v) => v == 'edit' ? showBudgetForm(budget: budget) : _delete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('تعديل سعر الأمبير')),
                    PopupMenuItem(value: 'delete', child: Text('حذف الميزانية')),
                  ],
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              color: _night,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 26),
              child: Column(children: [
                Text(Fmt.money(s.collected),
                    style: TextStyle(color: p.fab, fontSize: 32, fontWeight: FontWeight.w800)),
                Text('تم تحصيله من أصل ${Fmt.money(s.expected)}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12.5)),
                const SizedBox(height: 18),
                Row(children: [
                  _NavArrow(
                    icon: Icons.chevron_right_rounded,
                    tooltip: 'الشهر السابق',
                    onTap: i > 0 ? () => setState(() => _month = months[i - 1]) : null,
                  ),
                  Expanded(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _HeaderPill(value: Fmt.compactMoney(s.collected), label: 'المحصّل'),
                      const SizedBox(width: 10),
                      _HeaderPill(value: Fmt.compactMoney(s.remaining), label: 'المتبقي'),
                    ]),
                  ),
                  _NavArrow(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'الشهر التالي',
                    onTap: i >= 0 && i < months.length - 1 ? () => setState(() => _month = months[i + 1]) : null,
                  ),
                ]),
                const SizedBox(height: 18),
                _TodayBar(month: _month, rate: s.rate, color: color),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text('$message • ${Fmt.money(s.amberPrice)} للأمبير',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                  ),
                ]),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList.list(children: [
              SegmentedToggle<bool>(
                expand: true,
                selected: _showUnpaid,
                options: [(true, 'لم يدفعوا (${unpaid.length})'), (false, 'دفعوا (${paid.length})')],
                onChanged: (v) => setState(() => _showUnpaid = v),
              ),
              const SizedBox(height: 12),
              if (_showUnpaid && unpaid.isEmpty)
                const AppCard(child: EmptyState(icon: Icons.celebration_rounded, title: 'دفع جميع المشتركين 🎉'))
              else if (!_showUnpaid && paid.isEmpty)
                const AppCard(child: EmptyState(icon: Icons.receipt_long_outlined, title: 'لا توجد إيصالات لهذا الشهر'))
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(children: [
                    if (_showUnpaid)
                      for (final sub in unpaid)
                        ListTile(
                          onTap: () => Get.to(() => SubscriberDetailScreen(subscriberId: sub.id)),
                          leading: NameAvatar(name: sub.name, size: 40),
                          title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(
                              'جوزة ${sub.circuitNumber} • المستحق ${Fmt.money(sub.ambers * s.amberPrice)}'),
                          trailing: TextButton(
                            onPressed: () => showReceiptForm(subscriber: sub, month: _month),
                            child: const Text('تسجيل دفع'),
                          ),
                        )
                    else
                      for (final r in paid) ReceiptTile(receipt: r, showWorker: true),
                  ]),
                ),
            ]),
          ),
        ]),
      );
    });
  }
}

class _HeaderPill extends StatelessWidget {
  final String value;
  final String label;
  const _HeaderPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10.5)),
        ]),
      );
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  const _NavArrow({required this.icon, required this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: onTap == null ? Colors.white24 : Colors.white),
      );
}

/// Collection progress with a "today" marker for the running month.
class _TodayBar extends StatelessWidget {
  final MonthKey month;
  final double rate;
  final Color color;
  const _TodayBar({required this.month, required this.rate, required this.color});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final current = MonthKey.of(now) == month;
    final dayShare = current ? now.day / month.days : null;
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      return Column(children: [
        SizedBox(
          height: 34,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: PercentBar(value: rate, color: color),
              ),
            ),
            if (dayShare != null)
              PositionedDirectional(
                start: (w * dayShare - 18).clamp(0, w - 36),
                top: 0,
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: const Text('اليوم',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF141726))),
                  ),
                  Container(width: 2, height: 20, color: Colors.white),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('1 ${month.shortLabel}', style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 10.5)),
          if (current)
            Text('مضى ${now.day} من ${month.days} يوماً',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 10.5)),
          Text('${month.days} ${month.shortLabel}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 10.5)),
        ]),
      ]);
    });
  }
}
