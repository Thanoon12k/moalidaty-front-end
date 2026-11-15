import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Worker;

import '../../../core/analytics/analytics.dart';
import '../../../core/analytics/analytics_controller.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../controllers/worker_controller.dart';
import '../models/worker.dart';
import 'worker_form_sheet.dart';

class WorkersScreen extends StatelessWidget {
  const WorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ctrl = Get.find<WorkerController>();
    final stats = Get.find<AnalyticsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('العمال'),
        actions: [
          IconButton(
            tooltip: 'إضافة عامل',
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => showWorkerForm(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ctrl.load,
        child: Obx(() {
          final a = stats.analytics.value;
          final month = stats.focusMonth;
          final shares = {for (final c in a.collectors(month)) c.workerId: c};
          final monthTotal = a.summary(month).collected;
          final active = ctrl.items.where((w) => w.isActive).toList();
          final stopped = ctrl.items.where((w) => !w.isActive).toList();

          if (ctrl.isLoading.value && ctrl.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.items.isEmpty) {
            return ListView(children: [
              EmptyState(
                icon: Icons.engineering_outlined,
                title: 'لا يوجد عمال بعد',
                subtitle: 'أضف عمال الجباية ليسجّلوا الإيصالات من هواتفهم',
                actionLabel: 'إضافة عامل',
                onAction: () => showWorkerForm(),
              ),
            ]);
          }
          return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 32), children: [
            if (ctrl.isOffline.value) const OfflineBanner(),
            AppCard(
              child: Row(children: [
                IconTile(icon: Icons.groups_2_rounded, color: p.success, background: p.successSoft),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${active.length} عامل نشط',
                        style: TextStyle(fontWeight: FontWeight.w800, color: p.textPrimary, fontSize: 15)),
                    Text('تحصيل ${month.label}: ${Fmt.money(monthTotal)}',
                        style: TextStyle(fontSize: 12, color: p.textSecondary)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 4),
            for (final w in active) _WorkerCard(worker: w, share: shares[w.id], monthTotal: monthTotal, month: month),
            if (stopped.isNotEmpty) ...[
              const SectionHeader(title: 'موقوفون'),
              for (final w in stopped) _WorkerCard(worker: w, share: null, monthTotal: monthTotal, month: month),
            ],
          ]);
        }),
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final Worker worker;
  final CollectorShare? share;
  final double monthTotal;
  final MonthKey month;

  const _WorkerCard({required this.worker, required this.share, required this.monthTotal, required this.month});

  Future<void> _toggleActive() async {
    final stop = worker.isActive;
    final ok = await confirmAction(
      title: stop ? 'إيقاف العامل' : 'إعادة تفعيل العامل',
      message: stop
          ? 'لن يتمكن ${worker.name} من تسجيل الدخول، وتبقى إيصالاته محفوظة.'
          : 'سيتمكن ${worker.name} من تسجيل الدخول مجدداً.',
      confirm: stop ? 'إيقاف' : 'تفعيل',
      destructive: stop,
    );
    if (ok) {
      await guard(() => Get.find<WorkerController>().setActive(worker.id, !stop),
          success: stop ? 'تم إيقاف العامل' : 'تم تفعيل العامل');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ratio = monthTotal <= 0 || share == null ? 0.0 : share!.amount / monthTotal;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Opacity(
        opacity: worker.isActive ? 1 : 0.6,
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Column(children: [
            Row(children: [
              NameAvatar(name: worker.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(worker.name, style: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary)),
                  Text(worker.phone, textDirection: TextDirection.ltr, style: TextStyle(fontSize: 12, color: p.textMuted)),
                ]),
              ),
              if (!worker.isActive) Pill(text: 'موقوف', color: p.danger, background: p.dangerSoft),
              PopupMenuButton<String>(
                tooltip: 'خيارات',
                icon: Icon(Icons.more_vert_rounded, color: p.textMuted),
                onSelected: (v) => switch (v) {
                  'edit' => showWorkerForm(worker: worker),
                  'password' => showWorkerPasswordForm(worker),
                  _ => _toggleActive(),
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('تعديل البيانات')),
                  const PopupMenuItem(value: 'password', child: Text('تغيير كلمة المرور')),
                  PopupMenuItem(value: 'active', child: Text(worker.isActive ? 'إيقاف العامل' : 'إعادة التفعيل')),
                ],
              ),
            ]),
            if (worker.isActive) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: Row(children: [
                  Text('${share?.receipts ?? 0} إيصال • ${Fmt.compactMoney(share?.amount ?? 0)}',
                      style: TextStyle(fontSize: 11.5, color: p.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        color: p.primary,
                        backgroundColor: p.surfaceAlt,
                        semanticsLabel: 'حصة العامل من تحصيل ${month.label}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(Fmt.percent(ratio), style: TextStyle(fontSize: 11, color: p.textMuted)),
                ]),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
