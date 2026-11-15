import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/env.dart';
import '../../../core/data/app_error.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/controls.dart';
import '../../../core/widgets/feedback.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../receipts/controllers/receipt_controller.dart';
import '../../receipts/ui/pending_receipts_screen.dart';

/// Account section: who is signed in, password, appearance, sign out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final auth = Get.find<AuthController>();
    final theme = Get.find<ThemeController>();
    final receipts = Get.find<ReceiptController>();

    return Scaffold(
      appBar: AppBar(title: const Text('الحساب والإعدادات')),
      body: Obx(() {
        final profile = auth.profile.value;
        if (profile == null) return const SizedBox.shrink();
        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 32), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(colors: p.heroGradient, begin: Alignment.topRight, end: Alignment.bottomLeft),
            ),
            child: Column(children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                child: Icon(profile.isManager ? Icons.bolt_rounded : Icons.engineering_rounded,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 10),
              Text(profile.displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(profile.roleLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          const SectionHeader(title: 'معلومات الحساب'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: [
              _InfoRow(icon: Icons.bolt_rounded, label: 'المولدة', value: profile.generatorName),
              _InfoRow(icon: Icons.phone_rounded, label: 'رقم الهاتف', value: profile.phone, ltr: true),
              _InfoRow(icon: Icons.verified_user_outlined, label: 'الصلاحية', value: profile.roleLabel),
              _InfoRow(
                icon: Icons.cloud_outlined,
                label: 'الخادم',
                value: auth.isDemo ? 'وضع تجريبي (بدون خادم)' : 'Supabase',
              ),
            ]),
          ),
          const SectionHeader(title: 'الأمان'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: [
              ListTile(
                leading: IconTile(icon: Icons.password_rounded, color: p.primary, background: p.primarySoft, size: 38),
                title: const Text('تغيير كلمة المرور', style: TextStyle(fontWeight: FontWeight.w700)),
                trailing: Icon(Icons.chevron_left_rounded, color: p.textMuted),
                onTap: () => showFormSheet(const _ChangePasswordForm()),
              ),
              ListTile(
                leading: IconTile(icon: Icons.cloud_upload_rounded, color: p.orange, background: p.orangeSoft, size: 38),
                title: const Text('قائمة الانتظار', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${receipts.pending.length} إيصال بانتظار الإرسال'),
                trailing: Icon(Icons.chevron_left_rounded, color: p.textMuted),
                onTap: () => Get.to(() => const PendingReceiptsScreen()),
              ),
            ]),
          ),
          const SectionHeader(title: 'المظهر'),
          SegmentedToggle<ThemeMode>(
            expand: true,
            selected: theme.mode.value,
            options: const [(ThemeMode.light, 'فاتح'), (ThemeMode.dark, 'داكن'), (ThemeMode.system, 'تلقائي')],
            onChanged: theme.setMode,
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: p.danger, side: BorderSide(color: p.dangerSoft)),
            onPressed: () async {
              final ok = await confirmAction(
                title: 'تسجيل الخروج',
                message: 'هل تريد تسجيل الخروج من التطبيق؟',
                confirm: 'خروج',
                destructive: true,
              );
              if (ok) await auth.logout();
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('تسجيل الخروج'),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'مولداتنا • الإصدار 3.0.0${Env.hasSupabase ? '' : ' • غير مربوط بخادم'}',
              style: TextStyle(fontSize: 11.5, color: p.textMuted),
            ),
          ),
        ]);
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool ltr;
  const _InfoRow({required this.icon, required this.label, required this.value, this.ltr = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(children: [
        Icon(icon, size: 20, color: p.textMuted),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: p.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value.isEmpty ? '—' : value,
              textAlign: TextAlign.end,
              textDirection: ltr ? TextDirection.ltr : null,
              style: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary)),
        ),
      ]),
    );
  }
}

class _ChangePasswordForm extends StatefulWidget {
  const _ChangePasswordForm();

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await Get.find<AuthController>().changePassword(_password.text);
      if (!mounted) return;
      Navigator.pop(context);
      showSnack('تم تغيير كلمة المرور');
    } catch (e) {
      showSnack(describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SheetTitle('تغيير كلمة المرور'),
            const FieldLabel('كلمة المرور الجديدة'),
            TextFormField(
              controller: _password,
              obscureText: true,
              validator: Validators.password,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline_rounded)),
            ),
            const SizedBox(height: 12),
            const FieldLabel('تأكيد كلمة المرور'),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              validator: (v) => v != _password.text ? 'كلمتا المرور غير متطابقتين' : null,
              onFieldSubmitted: (_) => _save(),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_reset_rounded)),
            ),
            const SizedBox(height: 22),
            LoadingButton(label: 'حفظ', icon: Icons.check_rounded, loading: _saving, onPressed: _save),
          ]),
        ),
      );
}
