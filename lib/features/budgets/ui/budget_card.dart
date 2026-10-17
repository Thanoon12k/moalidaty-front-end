import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/controls.dart';
import 'budget_detail_screen.dart';

/// Status colour + sentence for a collection rate (never colour alone).
(Color, Color, String, IconData) collectionStatus(AppPalette p, MonthSummary s) {
  if (s.dueCount > 0 && s.unpaidCount == 0) {
    return (p.success, p.successSoft, 'أحسنت! دفع جميع المشتركين', Icons.verified_rounded);
  }
  if (s.rate >= 0.8) return (p.success, p.successSoft, 'أحسنت! التحصيل يسير بشكل جيد', Icons.thumb_up_alt_rounded);
  if (s.rate >= 0.5) return (p.warning, p.warningSoft, 'تابع ${s.unpaidCount} مشترك لم يدفعوا', Icons.schedule_rounded);
  return (p.danger, p.dangerSoft, 'التحصيل منخفض — ${s.unpaidCount} لم يدفعوا', Icons.error_outline_rounded);
}

/// "Monthly budget" card: month, price, collected of expected, progress.
class BudgetCard extends StatelessWidget {
  final MonthSummary summary;
  final bool compact;

  const BudgetCard({super.key, required this.summary, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = summary;
    final (color, soft, message, icon) = collectionStatus(p, s);
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Get.to(() => BudgetDetailScreen(month: s.key)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          IconTile(icon: Icons.calendar_month_rounded, color: p.primary, background: p.primarySoft, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.key.label, style: TextStyle(fontWeight: FontWeight.w800, color: p.textPrimary, fontSize: 14.5)),
              Text('${Fmt.money(s.amberPrice)} / أمبير', style: TextStyle(fontSize: 11.5, color: p.textMuted)),
            ]),
          ),
          Icon(Icons.chevron_left_rounded, color: p.textMuted),
        ]),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: compact ? Fmt.compactMoney(s.collected) : Fmt.money(s.collected),
              style: TextStyle(fontWeight: FontWeight.w800, color: p.textPrimary, fontSize: 14),
            ),
            TextSpan(
              text: '  من أصل ${compact ? Fmt.compactMoney(s.expected) : Fmt.money(s.expected)}',
              style: TextStyle(color: p.textMuted, fontSize: 11.5),
            ),
          ]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        PercentBar(value: s.rate, color: color),
        const SizedBox(height: 10),
        Row(children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Expanded(
            child: Text(message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: p.textSecondary)),
          ),
        ]),
        if (!compact) ...[
          const SizedBox(height: 10),
          Divider(color: p.border),
          const SizedBox(height: 8),
          Row(children: [
            Text('1 ${s.key.shortLabel}', style: TextStyle(fontSize: 11, color: p.textMuted)),
            Expanded(
              child: Text('${s.paidCount} دفعوا • ${s.unpaidCount} لم يدفعوا',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: p.textSecondary, fontWeight: FontWeight.w600)),
            ),
            Text('${s.key.days} ${s.key.shortLabel}', style: TextStyle(fontSize: 11, color: p.textMuted)),
          ]),
        ],
      ]),
    );
  }
}
