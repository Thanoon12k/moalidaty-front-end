import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/analytics/analytics_controller.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/controls.dart';
import '../../../core/widgets/feedback.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../receipts/controllers/receipt_controller.dart';
import '../../shell/ui/tab_header.dart';
import '../controllers/subscriber_controller.dart';
import '../models/subscriber.dart';
import 'subscriber_detail_screen.dart';
import 'subscriber_form_sheet.dart';

enum _Filter { all, paid, unpaid }

class SubscribersScreen extends StatefulWidget {
  const SubscribersScreen({super.key});

  @override
  State<SubscribersScreen> createState() => _SubscribersScreenState();
}

class _SubscribersScreenState extends State<SubscribersScreen> with AutomaticKeepAliveClientMixin {
  final _ctrl = Get.find<SubscriberController>();
  final _receipts = Get.find<ReceiptController>();
  final _stats = Get.find<AnalyticsController>();
  final _auth = Get.find<AuthController>();
  final _search = TextEditingController();
  _Filter _filter = _Filter.all;

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
    return RefreshIndicator(
      onRefresh: _auth.reloadAll,
      child: Obx(() {
        final a = _stats.analytics.value;
        final month = _stats.focusMonth;
        final hasBudget = a.budgetFor(month) != null;
        bool paid(Subscriber s) => _receipts.isPaid(s.id, month.year, month.month);
        final q = _search.text.trim();
        final list = _ctrl.items.where((s) {
          if (q.isNotEmpty && !s.name.contains(q) && !s.circuitNumber.contains(q) && !s.phone.contains(q)) {
            return false;
          }
          return switch (_filter) {
            _Filter.all => true,
            _Filter.paid => paid(s),
            _Filter.unpaid => !paid(s),
          };
        }).toList();

        return CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: TabHeader(
              title: 'المشتركون',
              subtitle: '${_ctrl.items.length} مشترك • ${a.totalAmbers} أمبير',
              onAdd: () => showSubscriberForm(),
              addTooltip: 'إضافة مشترك',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.list(children: [
              if (_ctrl.isOffline.value) const OfflineBanner(),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'بحث بالاسم أو رقم الجوزة أو الهاتف',
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
              if (hasBudget) ...[
                const SizedBox(height: 12),
                SegmentedToggle<_Filter>(
                  expand: true,
                  selected: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                  options: [
                    (_Filter.all, 'الكل'),
                    (_Filter.paid, 'دفعوا ${month.shortLabel}'),
                    (_Filter.unpaid, 'لم يدفعوا'),
                  ],
                ),
              ],
              const SizedBox(height: 12),
            ]),
          ),
          if (_ctrl.isLoading.value && _ctrl.items.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()))
          else if (list.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.people_outline_rounded,
                title: _ctrl.items.isEmpty ? 'لا يوجد مشتركون بعد' : 'لا توجد نتائج',
                subtitle: _ctrl.items.isEmpty ? 'أضف أول مشترك للبدء' : null,
                actionLabel: _ctrl.items.isEmpty ? 'إضافة مشترك' : null,
                onAction: _ctrl.items.isEmpty ? () => showSubscriberForm() : null,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _SubscriberCard(
                  subscriber: list[i],
                  status: hasBudget ? paid(list[i]) : null,
                  canManage: _auth.isManager,
                ),
              ),
            ),
        ]);
      }),
    );
  }
}

class _SubscriberCard extends StatelessWidget {
  final Subscriber subscriber;
  final bool? status; // paid this month? null = no budget yet
  final bool canManage;

  const _SubscriberCard({required this.subscriber, required this.status, required this.canManage});

  Future<void> _archive() async {
    final ok = await confirmAction(
      title: 'إيقاف الاشتراك',
      message: 'سيُخفى "${subscriber.name}" من القوائم مع الاحتفاظ بإيصالاته السابقة. متابعة؟',
      confirm: 'إيقاف',
      destructive: true,
    );
    if (ok) {
      await guard(() => Get.find<SubscriberController>().archive(subscriber.id), success: 'تم إيقاف الاشتراك');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = subscriber;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      onTap: () => Get.to(() => SubscriberDetailScreen(subscriberId: s.id)),
      child: Row(children: [
        NameAvatar(name: s.name),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: p.textPrimary)),
            const SizedBox(height: 4),
            Wrap(spacing: 6, runSpacing: 4, children: [
              Pill(text: s.circuitNumber, icon: Icons.tag_rounded, color: p.primary, background: p.primarySoft),
              Pill(text: '${s.ambers} أمبير', icon: Icons.bolt_rounded, color: p.orange, background: p.orangeSoft),
            ]),
          ]),
        ),
        if (status != null)
          status!
              ? Pill(text: 'دفع', icon: Icons.check_rounded, color: p.success, background: p.successSoft)
              : Pill(text: 'لم يدفع', icon: Icons.schedule_rounded, color: p.danger, background: p.dangerSoft),
        if (canManage)
          PopupMenuButton<String>(
            tooltip: 'خيارات',
            icon: Icon(Icons.more_vert_rounded, color: p.textMuted),
            onSelected: (v) => v == 'edit' ? showSubscriberForm(subscriber: s) : _archive(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('تعديل')),
              PopupMenuItem(value: 'archive', child: Text('إيقاف الاشتراك')),
            ],
          )
        else
          const SizedBox(width: 8),
      ]),
    );
  }
}
