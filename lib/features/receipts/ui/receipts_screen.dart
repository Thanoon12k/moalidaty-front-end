import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/analytics/analytics_controller.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/controls.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../shell/ui/tab_header.dart';
import '../controllers/receipt_controller.dart';
import '../models/receipt.dart';
import 'pending_receipts_screen.dart';
import 'receipt_tile.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> with AutomaticKeepAliveClientMixin {
  final _ctrl = Get.find<ReceiptController>();
  final _stats = Get.find<AnalyticsController>();
  final _search = TextEditingController();
  int? _period; // null = all months
  bool _mineOnly = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = context.palette;
    final auth = Get.find<AuthController>();
    return RefreshIndicator(
      onRefresh: auth.reloadAll,
      child: Obx(() {
        final a = _stats.analytics.value;
        final profile = auth.profile.value;
        final q = _search.text.trim();
        final list = a.receipts.where((r) {
          if (_period != null && r.period != _period) return false;
          if (_mineOnly && profile?.workerId != null && r.workerId != profile!.workerId) return false;
          if (q.isNotEmpty && !r.subscriberName.contains(q) && !r.subscriberCircuit.contains(q)) return false;
          return true;
        }).toList();
        final total = list.fold(0.0, (s, r) => s + r.amountPaid);
        final groups = _groupByDay(list);

        return CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: TabHeader(title: 'الإيصالات', subtitle: '${a.receipts.length} إيصال مسجّل'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.list(children: [
              if (_ctrl.isOffline.value) const OfflineBanner(),
              if (_ctrl.pending.isNotEmpty) _PendingBanner(count: _ctrl.pending.length),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'بحث باسم المشترك أو رقم الجوزة',
                  prefixIcon: const Icon(Icons.search_rounded),
                  fillColor: p.surface,
                  suffixIcon: q.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'مسح',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => setState(_search.clear),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              ChoiceChips<int?>(
                selected: _period,
                onSelected: (v) => setState(() => _period = v),
                options: [
                  (null, 'كل الأشهر'),
                  for (final m in a.months.reversed) (m.period, m.label),
                ],
              ),
              if (profile?.isWorker ?? false) ...[
                const SizedBox(height: 10),
                SegmentedToggle<bool>(
                  expand: true,
                  selected: _mineOnly,
                  options: const [(false, 'كل الإيصالات'), (true, 'إيصالاتي')],
                  onChanged: (v) => setState(() => _mineOnly = v),
                ),
              ],
              const SizedBox(height: 12),
              _SummaryStrip(count: list.length, total: total, period: _period),
              const SizedBox(height: 4),
            ]),
          ),
          if (_ctrl.isLoading.value && a.receipts.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()))
          else if (list.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: a.receipts.isEmpty ? 'لا توجد إيصالات بعد' : 'لا توجد نتائج',
                subtitle: a.receipts.isEmpty ? 'اضغط زر + لتسجيل أول دفعة' : 'جرّب بحثاً أو شهراً آخر',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
              sliver: SliverList.builder(
                itemCount: groups.length,
                itemBuilder: (_, i) {
                  final (day, items) = groups[i];
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                      child: Row(children: [
                        Text(Fmt.longDate(day),
                            style: TextStyle(fontWeight: FontWeight.w700, color: p.textSecondary, fontSize: 12.5)),
                        const Spacer(),
                        Text(Fmt.money(items.fold(0.0, (s, r) => s + r.amountPaid)),
                            style: TextStyle(fontSize: 12, color: p.textMuted)),
                      ]),
                    ),
                    AppCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(children: [
                        for (var j = 0; j < items.length; j++) ...[
                          if (j > 0) Divider(indent: 70, endIndent: 14, color: p.border),
                          ReceiptTile(receipt: items[j], showWorker: true),
                        ],
                      ]),
                    ),
                  ]);
                },
              ),
            ),
        ]);
      }),
    );
  }

  List<(DateTime, List<Receipt>)> _groupByDay(List<Receipt> list) {
    final out = <(DateTime, List<Receipt>)>[];
    for (final r in list) {
      final d = DateTime(r.dateReceived.year, r.dateReceived.month, r.dateReceived.day);
      if (out.isEmpty || out.last.$1 != d) out.add((d, []));
      out.last.$2.add(r);
    }
    return out;
  }
}

class _SummaryStrip extends StatelessWidget {
  final int count;
  final double total;
  final int? period;
  const _SummaryStrip({required this.count, required this.total, required this.period});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        IconTile(icon: Icons.payments_rounded, color: p.success, background: p.successSoft, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(period == null ? 'إجمالي التحصيل' : 'تحصيل ${MonthKey.fromPeriod(period!).label}',
                style: TextStyle(fontSize: 12, color: p.textSecondary)),
            Text(Fmt.money(total), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: p.textPrimary)),
          ]),
        ),
        Pill(text: '$count إيصال', color: p.primary, background: p.primarySoft),
      ]),
    );
  }
}

class _PendingBanner extends StatelessWidget {
  final int count;
  const _PendingBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        color: p.orangeSoft,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        onTap: () => Get.to(() => const PendingReceiptsScreen()),
        child: Row(children: [
          Icon(Icons.cloud_upload_rounded, color: p.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$count إيصال بانتظار الإرسال عند توفر الإنترنت',
                style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w600, fontSize: 12.5)),
          ),
          Icon(Icons.chevron_left_rounded, color: p.textMuted),
        ]),
      ),
    );
  }
}
