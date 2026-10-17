import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/analytics/analytics_controller.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/controls.dart';
import '../../subscribers/ui/subscriber_detail_screen.dart';

/// Reports: collection trend, this month's gauge, paid vs unpaid, collectors.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _stats = Get.find<AnalyticsController>();
  int _range = 6; // months, 0 = all

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير والإحصائيات')),
      body: Obx(() {
        final a = _stats.analytics.value;
        final all = a.monthly();
        if (all.isEmpty) {
          return const Center(
            child: EmptyState(
              icon: Icons.insights_rounded,
              title: 'لا توجد بيانات كافية بعد',
              subtitle: 'تظهر التقارير بعد إضافة ميزانية وتسجيل الإيصالات',
            ),
          );
        }
        final data = _range == 0 || all.length <= _range ? all : all.sublist(all.length - _range);
        final focus = _stats.focusMonth;
        final current = a.summary(focus);
        final change = a.changeVsPrevious(focus, asOf: DateTime.now());
        final rangeTotal = data.fold(0.0, (s, m) => s + m.collected);
        final rangeExpected = data.fold(0.0, (s, m) => s + m.expected);

        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 32), children: [
          // ── Headline + trend ─────────────────────────────────────────────
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('إجمالي التحصيل — ${_rangeLabel()}', style: TextStyle(fontSize: 12, color: p.textSecondary)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(Fmt.money(rangeTotal),
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: p.textPrimary)),
              ),
              const SizedBox(height: 4),
              Row(children: [
                if (change != null) ...[
                  Pill(
                    text: '${change >= 0 ? '+' : ''}${(change * 100).toStringAsFixed(1)}%',
                    icon: change >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: change >= 0 ? p.success : p.danger,
                    background: change >= 0 ? p.successSoft : p.dangerSoft,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text('${focus.label}: ${Fmt.money(current.collected)}',
                      overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: p.textMuted)),
                ),
              ]),
              const SizedBox(height: 18),
              SizedBox(height: 210, child: TrendChart(data: data)),
              const SizedBox(height: 12),
              ChartLegend(items: [('المحصّل', p.series[0]), ('المتوقع', p.textMuted)]),
              const SizedBox(height: 12),
              SegmentedToggle<int>(
                expand: true,
                selected: _range,
                onChanged: (v) => setState(() => _range = v),
                options: const [(3, '3 أشهر'), (6, '6 أشهر'), (12, 'سنة'), (0, 'الكل')],
              ),
            ]),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(
                child: _Tile(
                  icon: Icons.donut_large_rounded,
                  color: p.primary,
                  background: p.primarySoft,
                  title: 'نسبة التحصيل',
                  value: Fmt.percent(rangeExpected <= 0 ? 0 : (rangeTotal / rangeExpected).clamp(0, 1)),
                  caption: _rangeLabel(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Tile(
                  icon: Icons.price_change_rounded,
                  color: p.orange,
                  background: p.orangeSoft,
                  title: 'متوسط سعر الأمبير',
                  value: Fmt.money(data.fold(0.0, (s, m) => s + m.amberPrice) / data.length),
                  caption: _rangeLabel(),
                ),
              ),
            ]),
          ),

          // ── This month gauge + collectors ────────────────────────────────
          SectionHeader(title: 'تحصيل ${focus.label}'),
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(children: [
              Center(
                child: SemiGauge(
                  value: current.rate,
                  center: Column(mainAxisSize: MainAxisSize.min, children: [
                    IconTile(icon: Icons.account_balance_wallet_rounded, color: p.primary, background: p.primarySoft, size: 34),
                    const SizedBox(height: 4),
                    Text(Fmt.compactMoney(current.collected),
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: p.textPrimary)),
                    Text('${Fmt.percent(current.rate)} من المتوقع',
                        style: TextStyle(fontSize: 11, color: p.textSecondary)),
                  ]),
                ),
              ),
              const SizedBox(height: 10),
              for (final c in a.collectors(focus))
                _CollectorRow(share: c, total: current.collected),
              if (a.collectors(focus).isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('لم تُسجّل إيصالات لهذا الشهر بعد', style: TextStyle(color: p.textMuted)),
                ),
            ]),
          ),

          // ── Paid vs unpaid ───────────────────────────────────────────────
          const SectionHeader(title: 'الدافعون وغير الدافعين'),
          AppCard(
            padding: const EdgeInsets.fromLTRB(12, 18, 16, 12),
            child: Column(children: [
              SizedBox(height: 200, child: PaidUnpaidBars(data: data)),
              const SizedBox(height: 10),
              ChartLegend(items: [('دفعوا', p.success), ('لم يدفعوا', p.danger)]),
            ]),
          ),

          // ── Collectors share (all time) ──────────────────────────────────
          ..._collectorsDonut(a, p),

          // ── Best / late subscribers ──────────────────────────────────────
          const SectionHeader(title: 'الأعلى دفعاً'),
          _StandingList(items: a.topPayers(), positive: true),
          if (a.mostLate().isNotEmpty) ...[
            const SectionHeader(title: 'الأكثر تأخراً'),
            _StandingList(items: a.mostLate(), positive: false),
          ],
        ]);
      }),
    );
  }

  String _rangeLabel() => switch (_range) {
        3 => 'آخر 3 أشهر',
        6 => 'آخر 6 أشهر',
        12 => 'آخر سنة',
        _ => 'كل الفترة',
      };

  List<Widget> _collectorsDonut(Analytics a, AppPalette p) {
    final shares = a.collectors();
    if (shares.isEmpty) return const [];
    // At most 3 named slices (validated colour order), the rest folded into "أخرى".
    final named = shares.take(3).toList();
    final rest = shares.skip(3).fold(0.0, (s, c) => s + c.amount);
    final slices = [
      for (var i = 0; i < named.length; i++)
        DonutSlice(named[i].name, named[i].amount, p.series[i], Fmt.compactMoney(named[i].amount)),
      if (rest > 0) DonutSlice('أخرى', rest, p.textMuted, Fmt.compactMoney(rest)),
    ];
    return [
      const SectionHeader(title: 'توزيع التحصيل على المحصّلين'),
      AppCard(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
        child: Column(children: [
          DonutChart(
            slices: slices,
            center: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(Fmt.compactMoney(a.totalCollected),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.textPrimary)),
              Text('${a.receipts.length} إيصال', style: TextStyle(fontSize: 11.5, color: p.textSecondary)),
            ]),
          ),
          const SizedBox(height: 16),
          ChartLegend(items: [for (final s in slices) ('${s.label} • ${s.valueLabel}', s.color)]),
        ]),
      ),
    ];
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String value;
  final String caption;

  const _Tile({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconTile(icon: icon, color: color, background: background, size: 36),
        const SizedBox(height: 10),
        Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: p.textPrimary)),
        Text(caption, style: TextStyle(fontSize: 10.5, color: p.textMuted)),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: p.textPrimary)),
        ),
      ]),
    );
  }
}

class _CollectorRow extends StatelessWidget {
  final CollectorShare share;
  final double total;
  const _CollectorRow({required this.share, required this.total});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ratio = total <= 0 ? 0.0 : share.amount / total;
    final manager = share.workerId == null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        IconTile(
          icon: manager ? Icons.storefront_rounded : Icons.engineering_rounded,
          color: manager ? p.purple : p.orange,
          background: manager ? p.purpleSoft : p.orangeSoft,
          size: 40,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(share.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: p.textPrimary)),
              ),
              Text(Fmt.money(share.amount),
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: p.textPrimary)),
            ]),
            Row(children: [
              Text('${share.receipts} إيصال', style: TextStyle(fontSize: 10.5, color: p.textMuted)),
              const Spacer(),
              Text('${Fmt.percent(ratio)} من التحصيل', style: TextStyle(fontSize: 10.5, color: p.textMuted)),
            ]),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                color: p.primary,
                backgroundColor: p.surfaceAlt,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _StandingList extends StatelessWidget {
  final List<SubscriberStanding> items;
  final bool positive;
  const _StandingList({required this.items, required this.positive});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = positive ? p.success : p.danger;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) Divider(color: p.border, height: 1),
          InkWell(
            onTap: () => Get.to(() => SubscriberDetailScreen(subscriberId: items[i].subscriber.id)),
            child: Container(
              decoration: BoxDecoration(
                border: BorderDirectional(start: BorderSide(color: accent, width: 3)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(items[i].subscriber.name,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: p.textPrimary)),
                    Text('جوزة ${items[i].subscriber.circuitNumber} • ${items[i].subscriber.ambers} أمبير',
                        style: TextStyle(fontSize: 11, color: p.textMuted)),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(Fmt.money(items[i].totalPaid),
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: p.textPrimary)),
                  Text(
                    positive ? '${items[i].paidMonths} شهر مدفوع' : '${items[i].unpaidMonths} شهر غير مدفوع',
                    style: TextStyle(fontSize: 11, color: accent, fontWeight: FontWeight.w700),
                  ),
                ]),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}
