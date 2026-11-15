import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/controls.dart';
import '../../../core/widgets/feedback.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/ui/profile_screen.dart';
import '../../receipts/controllers/receipt_controller.dart';
import '../../receipts/ui/pending_receipts_screen.dart';
import '../../stats/ui/stats_screen.dart';
import '../../workers/ui/workers_screen.dart';

/// Side menu opened from the ☰ button of every tab header.
class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final auth = Get.find<AuthController>();
    final receipts = Get.find<ReceiptController>();
    final theme = Get.find<ThemeController>();

    void open(Widget page) {
      Navigator.pop(context);
      Get.to(() => page);
    }

    return Drawer(
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Obx(() {
          final profile = auth.profile.value;
          return ListView(padding: const EdgeInsets.all(16), children: [
            // ── Profile card ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: p.heroGradient, begin: Alignment.topRight, end: Alignment.bottomLeft),
              ),
              child: Row(children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(profile?.isManager ?? true ? Icons.bolt_rounded : Icons.engineering_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(profile?.displayName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    Text(
                      profile == null ? '' : '${profile.roleLabel}${profile.isWorker ? ' • ${profile.generatorName}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                    ),
                  ]),
                ),
              ]),
            ),
            if (auth.isDemo) ...[
              const SizedBox(height: 10),
              Pill(
                text: 'وضع تجريبي — البيانات لا تُحفظ',
                icon: Icons.science_outlined,
                color: p.warning,
                background: p.warningSoft,
              ),
            ],
            const SizedBox(height: 16),

            _MenuTile(
              icon: Icons.insights_rounded,
              color: p.primary,
              background: p.primarySoft,
              title: 'التقارير والإحصائيات',
              onTap: () => open(const StatsScreen()),
            ),
            if (auth.isManager)
              _MenuTile(
                icon: Icons.engineering_rounded,
                color: p.success,
                background: p.successSoft,
                title: 'العمال',
                onTap: () => open(const WorkersScreen()),
              ),
            _MenuTile(
              icon: Icons.cloud_upload_rounded,
              color: p.orange,
              background: p.orangeSoft,
              title: 'قائمة الانتظار',
              badge: receipts.pending.length,
              onTap: () => open(const PendingReceiptsScreen()),
            ),
            _MenuTile(
              icon: Icons.manage_accounts_rounded,
              color: p.purple,
              background: p.purpleSoft,
              title: 'الحساب والإعدادات',
              onTap: () => open(const ProfileScreen()),
            ),

            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
              child: Text('المظهر', style: TextStyle(color: p.textSecondary, fontWeight: FontWeight.w700)),
            ),
            SegmentedToggle<ThemeMode>(
              expand: true,
              selected: theme.mode.value,
              options: const [(ThemeMode.light, 'فاتح'), (ThemeMode.dark, 'داكن'), (ThemeMode.system, 'تلقائي')],
              onChanged: theme.setMode,
            ),

            const SizedBox(height: 24),
            _MenuTile(
              icon: Icons.logout_rounded,
              color: p.danger,
              background: p.dangerSoft,
              title: 'تسجيل الخروج',
              onTap: () async {
                Navigator.pop(context);
                final pending = receipts.pending.length;
                final ok = await confirmAction(
                  title: 'تسجيل الخروج',
                  message: pending > 0
                      ? 'لديك $pending إيصال بانتظار الإرسال، سيُرسل عند تسجيل الدخول مجدداً. هل تريد الخروج؟'
                      : 'هل تريد تسجيل الخروج من التطبيق؟',
                  confirm: 'خروج',
                  destructive: true,
                );
                if (ok) await auth.logout();
              },
            ),
          ]);
        }),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final VoidCallback onTap;
  final int badge;

  const _MenuTile({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        onTap: onTap,
        child: Row(children: [
          IconTile(icon: icon, color: color, background: background, size: 38),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary))),
          if (badge > 0) Pill(text: '$badge', color: Colors.white, background: p.danger),
          Icon(Icons.chevron_left_rounded, color: p.textMuted),
        ]),
      ),
    );
  }
}
