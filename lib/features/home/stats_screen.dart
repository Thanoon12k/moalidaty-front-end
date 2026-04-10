import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../budgets/controllers/budget_controller.dart';
import '../receipts/controllers/receipt_controller.dart';
import '../subscribers/controllers/subscriber_controller.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const _months = [
    '', 'يناير', 'فبراير', 'مارس', 'إبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  @override
  Widget build(BuildContext context) {
    final budCtrl = Get.find<BudgetController>();
    final recCtrl = Get.find<ReceiptController>();
    final subCtrl = Get.find<SubscriberController>();

    return Obx(() {
      final budgets   = budCtrl.items;
      final receipts  = recCtrl.items;
      final totalSubs = subCtrl.items.where((s) => s.isActive).length;

      // Revenue per month
      final revenueByMonth = <String, double>{};
      for (final r in receipts) {
        final key = '${r.year}/${r.month.toString().padLeft(2, '0')}';
        revenueByMonth[key] = (revenueByMonth[key] ?? 0) + r.amountPaid;
      }

      // Collection rate per budget month
      final collectionData = <_MonthStat>[];
      for (final b in budgets) {
        final paid = receipts.where(
            (r) => r.year == b.year && r.month == b.month).length;
        collectionData.add(_MonthStat(
          label: '${_months[b.month]} ${b.year}',
          paid: paid,
          unpaid: (totalSubs - paid).clamp(0, totalSubs),
        ));
      }

      // Bar data entries
      final barGroups = <BarChartGroupData>[];
      final sortedKeys = revenueByMonth.keys.toList()..sort();
      for (int i = 0; i < sortedKeys.length; i++) {
        barGroups.add(BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: revenueByMonth[sortedKeys[i]]!,
              color: AppTheme.primary,
              width: 20,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ));
      }

      final fmt = NumberFormat('#,##0', 'en');

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header ─────────────────────────────────────────────────────
          const Text(
            'إحصائيات المولدة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${budgets.length} شهر | ${receipts.length} إيصال | $totalSubs مشترك نشط',
            style: const TextStyle(
                fontFamily: 'Cairo', color: AppTheme.textMid, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // ── Revenue bar chart ───────────────────────────────────────────
          if (barGroups.isNotEmpty) ...[
            _SectionTitle(title: 'الإيرادات الشهرية (د.ع)'),
            const SizedBox(height: 8),
            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= sortedKeys.length) {
                            return const SizedBox.shrink();
                          }
                          final parts = sortedKeys[i].split('/');
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _months[int.parse(parts[1])],
                              style: const TextStyle(
                                  fontFamily: 'Cairo', fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        getTitlesWidget: (v, _) => Text(
                          '${fmt.format(v ~/ 1000)}k',
                          style: const TextStyle(fontSize: 9),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Collection rate per month ───────────────────────────────────
          if (collectionData.isNotEmpty) ...[
            _SectionTitle(title: 'نسبة التحصيل لكل شهر'),
            const SizedBox(height: 8),
            ...collectionData.map((stat) => _CollectionBar(stat: stat,
                total: totalSubs == 0 ? 1 : totalSubs)),
            const SizedBox(height: 24),
          ],

          // ── Summary cards ───────────────────────────────────────────────
          _SectionTitle(title: 'ملخص'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                icon: Icons.monetization_on_rounded,
                label: 'إجمالي الإيرادات',
                value: '${fmt.format(revenueByMonth.values.fold(0.0, (a, b) => a + b).toInt())} د.ع',
                color: Colors.green,
              ),
              _StatCard(
                icon: Icons.receipt_long,
                label: 'إجمالي الإيصالات',
                value: '${receipts.length}',
                color: AppTheme.primary,
              ),
              _StatCard(
                icon: Icons.people,
                label: 'المشتركون النشطون',
                value: '$totalSubs',
                color: Colors.orange,
              ),
              _StatCard(
                icon: Icons.calendar_month,
                label: 'أشهر مسجلة',
                value: '${budgets.length}',
                color: Colors.purple,
              ),
            ],
          ),
        ],
      );
    });
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

class _MonthStat {
  final String label;
  final int paid;
  final int unpaid;
  const _MonthStat({required this.label, required this.paid, required this.unpaid});
}

class _CollectionBar extends StatelessWidget {
  final _MonthStat stat;
  final int total;
  const _CollectionBar({required this.stat, required this.total});

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0.0 : stat.paid / total;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.label.replaceAll('\n', ' '),
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
              Text(
                '${stat.paid} / $total',
                style: const TextStyle(
                    fontFamily: 'Cairo', color: AppTheme.textMid, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: rate,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              rate >= 0.8 ? Colors.green : rate >= 0.5 ? Colors.orange : Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(rate * 100).toStringAsFixed(0)}% تم التحصيل',
            style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 11, color: AppTheme.textMid),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - 44) / 2;
    return Container(
      width: w,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 12, color: AppTheme.textMid),
          ),
        ],
      ),
    );
  }
}
