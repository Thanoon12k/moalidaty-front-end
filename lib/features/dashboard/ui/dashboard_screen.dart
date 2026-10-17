import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/analytics/analytics_controller.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/common.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../budgets/controllers/budget_controller.dart';
import '../../budgets/ui/budget_card.dart';
import '../../budgets/ui/budget_form_sheet.dart';
import '../../receipts/controllers/receipt_controller.dart';
import '../../receipts/ui/qr_scanner_screen.dart';
import '../../receipts/ui/receipt_form_sheet.dart';
import '../../receipts/ui/receipt_tile.dart';
import '../../shell/ui/home_shell.dart';
import '../../shell/ui/tab_header.dart';
import '../../stats/ui/stats_screen.dart';
import '../../subscribers/controllers/subscriber_controller.dart';
import '../../subscribers/ui/subscriber_form_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  final _auth = Get.find<AuthController>();
  final _stats = Get.find<AnalyticsController>();
  final _receipts = Get.find<ReceiptController>();
  final _subs = Get.find<SubscriberController>();
  final _budgets = Get.find<BudgetController>();

  MonthKey? _month;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = context.palette;
    return RefreshIndicator(
      onRefresh: _auth.reloadAll,
      child: Obx(() {
        final a = _stats.analytics.value;
        final profile = _auth.profile.value;
        final month = _month ?? _stats.focusMonth;
        final loading = _receipts.isLoading.value || _subs.isLoading.value || _budgets.isLoading.value;
        final offline = _receipts.isOffline.value || _subs.isOffline.value;
        final firstLoad = loading && a.receipts.isEmpty && a.subscribers.isEmpty;

        return ListView(
          padding: const EdgeInsets.only(bottom: 110),
          children: [
            TabHeader(
              leading: NameAvatar(name: profile?.displayName ?? '', size: 46),
              subtitle: '${Fmt.greeting(DateTime.now())}، مرحباً بعودتك',
              title: profile?.displayName ?? '',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (offline) const OfflineBanner(),
                  if (firstLoad)
                    const Padding(
                      padding: EdgeInsets.only(top: 120),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    const SizedBox(height: 6),
                    _BalanceCard(analytics: a, month: month, onPickMonth: () => _pickMonth(a, month)),
                    const SizedBox(height: 18),
                    _QuickActions(isManager: _auth.isManager),
                    const SizedBox(height: 4),
                    _MiniCards(analytics: a, month: month),
                    ..._recentReceipts(a),
                    ..._budgetsStrip(a),
                    ..._unpaid(a, month),
                    ..._distribution(a, p),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _pickMonth(Analytics a, MonthKey current) async {
    final months = a.months.reversed.toList();
    if (months.isEmpty) return;
    final picked = await showModalBottomSheet<MonthKey>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            for (final m in months)
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                selected: m == current,
                leading: const Icon(Icons.calendar_month_rounded),
                title: Text(m.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Text(Fmt.compactMoney(a.summary(m).collected)),
                onTap: () => Navigator.pop(ctx, m),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _month = picked);
  }

  List<Widget> _recentReceipts(Analytics a) {
    final recent = a.receipts.take(5).toList();
    return [
      SectionHeader(
        title: 'آخر الإيصالات',
        action: recent.isEmpty ? null : 'عرض الكل',
        onAction: () => Get.find<ShellController>().goTo(2),
      ),
      if (recent.isEmpty)
        const AppCard(
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'لا توجد إيصالات بعد',
            subtitle: 'اضغط زر + لتسجيل أول دفعة',
          ),
        )
      else
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(children: [for (final r in recent) ReceiptTile(receipt: r, dense: true)]),
        ),
    ];
  }

  List<Widget> _budgetsStrip(Analytics a) {
    final months = a.months.reversed.take(6).toList();
    return [
      SectionHeader(
        title: 'الميزانيات الشهرية',
        action: months.isEmpty ? null : 'عرض الكل',
        onAction: () => Get.find<ShellController>().goTo(3),
      ),
      if (months.isEmpty)
        AppCard(
          child: EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'لا توجد ميزانية بعد',
            subtitle: 'حدد سعر الأمبير للشهر لبدء الجباية',
            actionLabel: _auth.isManager ? 'إضافة ميزانية' : null,
            onAction: _auth.isManager ? () => showBudgetForm() : null,
          ),
        )
      else
        _HorizontalStrip(
          children: [
            for (final m in months) SizedBox(width: 250, child: BudgetCard(summary: a.summary(m), compact: true)),
          ],
        ),
    ];
  }

  List<Widget> _unpaid(Analytics a, MonthKey month) {
    if (a.budgetFor(month) == null) return const [];
    final unpaid = a.unpaidIn(month).where((s) => !_receipts.isPaid(s.id, month.year, month.month)).toList();
    final price = a.budgetFor(month)!.amberPrice;
    return [
      SectionHeader(
        title: 'لم يدفعوا بعد — ${month.shortLabel}',
        trailing: Padding(
          padding: const EdgeInsetsDirectional.only(end: 6),
          child: Text('${unpaid.length}', style: TextStyle(color: context.palette.textSecondary)),
        ),
      ),
      if (unpaid.isEmpty)
        AppCard(
          child: Row(
            children: [
              IconTile(
                icon: Icons.celebration_rounded,
                color: context.palette.success,
                background: context.palette.successSoft,
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('أحسنت! دفع جميع المشتركين لهذا الشهر')),
            ],
          ),
        )
      else
        _HorizontalStrip(
          children: [
            for (final s in unpaid)
              () {
                final p = context.palette;
                return SizedBox(
                  width: 158,
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NameAvatar(name: s.name, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          s.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary),
                        ),
                        Text(
                          '${s.circuitNumber} • ${s.ambers} أمبير',
                          style: TextStyle(fontSize: 11, color: p.textMuted),
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'المستحق ',
                                style: TextStyle(fontSize: 11, color: p.textMuted),
                              ),
                              TextSpan(
                                text: Fmt.money(price * s.ambers),
                                style: TextStyle(fontSize: 11, color: p.danger, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 32),
                              padding: EdgeInsets.zero,
                              textStyle: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                            ),
                            onPressed: () => showReceiptForm(subscriber: s, month: month),
                            child: const Text('تسجيل دفع'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }(),
          ],
        ),
    ];
  }

  List<Widget> _distribution(Analytics a, AppPalette p) {
    final buckets = a.amberBuckets();
    final count = buckets.fold(0, (s, b) => s + b.subscribers);
    if (count == 0) return const [];
    return [
      const SectionHeader(title: 'توزيع الاشتراكات حسب الأمبير'),
      AppCard(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
        child: Column(
          children: [
            DonutChart(
              slices: [
                for (var i = 0; i < buckets.length; i++)
                  DonutSlice(
                    buckets[i].label,
                    buckets[i].subscribers.toDouble(),
                    p.ordinal[i],
                    '${buckets[i].subscribers} مشترك',
                  ),
              ],
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${a.totalAmbers}',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: p.textPrimary, height: 1.1),
                  ),
                  Text('أمبير • $count مشترك', style: TextStyle(fontSize: 11.5, color: p.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ChartLegend(
              items: [
                for (var i = 0; i < buckets.length; i++)
                  ('${buckets[i].label} (${buckets[i].subscribers})', p.ordinal[i]),
              ],
            ),
          ],
        ),
      ),
    ];
  }
}

// ─── Balance card ───────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final Analytics analytics;
  final MonthKey month;
  final VoidCallback onPickMonth;

  const _BalanceCard({required this.analytics, required this.month, required this.onPickMonth});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = analytics.summary(month);
    final now = DateTime.now();
    final daily = analytics.dailyCumulative(month, until: now);
    final change = analytics.changeVsPrevious(month, asOf: now);
    // Always at least two points so the line has a shape at the 1st of a month.
    final values = daily.length >= 2 ? daily : [0.0, ...daily, if (daily.isEmpty) 0.0];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: p.heroGradient),
        boxShadow: [
          BoxShadow(color: p.heroGradient[1].withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('المحصّل', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                    const Spacer(),
                    Material(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: onPickMonth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                month.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: Fmt.number(s.collected),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: ' ${Fmt.currency}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (change != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              change >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${change >= 0 ? '+' : ''}${(change * 100).toStringAsFixed(1)}%',
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    if (change != null) const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        change == null
                            ? 'من أصل ${Fmt.money(s.expected)} متوقع'
                            : MonthKey.of(now) == month
                            ? 'مقارنة بنفس الفترة من الشهر السابق'
                            : 'مقارنة بالشهر السابق',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 118,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: HeroLineChart(
                values: values,
                accent: p.heroGradient[1],
                labelAt: (i) => '${(i + 1).clamp(1, month.days)} ${month.shortLabel}',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                _figure(context, 'المحصّل', Fmt.compactMoney(s.collected), p.success, Icons.arrow_upward_rounded),
                _divider(p),
                _figure(context, 'المتبقي', Fmt.compactMoney(s.remaining), p.danger, Icons.arrow_downward_rounded),
                _divider(p),
                _figure(context, 'دفعوا', '${s.paidCount}/${s.dueCount}', p.primary, Icons.people_alt_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(AppPalette p) => Container(width: 1, height: 30, color: p.border);

  Widget _figure(BuildContext context, String label, String value, Color color, IconData icon) {
    final p = context.palette;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.5, color: p.textMuted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: p.textPrimary),
                ),
              ),
              const SizedBox(width: 2),
              Icon(icon, size: 14, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick actions ──────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final bool isManager;
  const _QuickActions({required this.isManager});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget action(IconData icon, String label, Color color, Color bg, VoidCallback onTap) => Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              IconTile(icon: icon, color: color, background: bg, size: 52),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: p.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );

    return Row(
      children: [
        action(Icons.receipt_long_rounded, 'إيصال جديد', p.primary, p.primarySoft, () => showReceiptForm()),
        action(Icons.qr_code_scanner_rounded, 'مسح QR', p.purple, p.purpleSoft, () async {
          final id = await scanSubscriberQr();
          if (id == null) return;
          final sub = Get.find<SubscriberController>().byId(id);
          showReceiptForm(subscriber: sub);
        }),
        action(Icons.person_add_alt_1_rounded, 'مشترك جديد', p.success, p.successSoft, () => showSubscriberForm()),
        if (isManager)
          action(Icons.add_chart_rounded, 'ميزانية', p.orange, p.orangeSoft, () => showBudgetForm())
        else
          action(Icons.insights_rounded, 'التقارير', p.orange, p.orangeSoft, () => Get.to(() => const StatsScreen())),
      ],
    );
  }
}

// ─── Mini cards ─────────────────────────────────────────────────────────────

class _MiniCards extends StatelessWidget {
  final Analytics analytics;
  final MonthKey month;
  const _MiniCards({required this.analytics, required this.month});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = analytics.summary(month);
    final prevPrice = analytics.budgetFor(month.previous)?.amberPrice;
    final priceChange = prevPrice == null || prevPrice == 0 ? null : (s.amberPrice - prevPrice) / prevPrice;
    final monthly = analytics.monthly();
    final active = analytics.subscribers.where((x) => x.isActive).length;

    Widget card({
      required IconData icon,
      required Color color,
      required Color bg,
      required String title,
      required String subtitle,
      required String value,
      Widget? footer,
    }) => Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(icon: icon, color: color, background: bg, size: 36),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary, fontSize: 13.5),
            ),
            Text(subtitle, style: TextStyle(fontSize: 10.5, color: p.textMuted)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(fontWeight: FontWeight.w800, color: p.textPrimary, fontSize: 17),
              ),
            ),
            if (footer != null) ...[const SizedBox(height: 6), footer],
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            card(
              icon: Icons.groups_rounded,
              color: p.primary,
              bg: p.primarySoft,
              title: 'المشتركون',
              subtitle: 'النشطون حالياً',
              value: '$active',
              footer: Pill(
                text: '${analytics.totalAmbers} أمبير',
                color: p.primary,
                background: p.primarySoft,
                icon: Icons.bolt_rounded,
              ),
            ),
            const SizedBox(width: 12),
            card(
              icon: Icons.price_change_rounded,
              color: p.orange,
              bg: p.orangeSoft,
              title: 'سعر الأمبير',
              subtitle: month.label,
              value: s.amberPrice > 0 ? Fmt.money(s.amberPrice) : '—',
              footer: monthly.length >= 2
                  ? SizedBox(
                      height: 26,
                      child: Row(
                        children: [
                          Expanded(
                            child: Sparkline(values: monthly.map((m) => m.amberPrice).toList(), color: p.orange),
                          ),
                          if (priceChange != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${priceChange >= 0 ? '+' : ''}${(priceChange * 100).toStringAsFixed(0)}%',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: p.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontally scrolling row whose height follows its tallest card
/// (fixed heights clip text with Cairo's tall line height).
class _HorizontalStrip extends StatelessWidget {
  final List<Widget> children;
  const _HorizontalStrip({required this.children});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    clipBehavior: Clip.none,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: 12), children[i]],
        ],
      ),
    ),
  );
}
