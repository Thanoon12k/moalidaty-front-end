import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/backend.dart';
import '../../../core/data/data_source.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/controls.dart';
import '../../../core/widgets/feedback.dart';
import '../controllers/auth_controller.dart';
import 'app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = Get.find<AuthController>();
  final _hasServer = Get.find<Backend>().hasRemote;
  final _form = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  LoginKind _kind = LoginKind.account;
  bool _obscure = true;

  bool get _isManager => _kind == LoginKind.account;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_form.currentState?.validate() ?? false)) return;
    final id = _isManager ? _identifier.text.trim() : Validators.normalizePhone(_identifier.text);
    _auth.signIn(_kind, id, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      body: SingleChildScrollView(
        child: Column(children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 36, 24, 56),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: p.heroGradient,
              ),
            ),
            child: Column(children: [
              const AppLogo(size: 76),
              const SizedBox(height: 16),
              const Text('مولداتنا',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 4),
              Text('نظام إدارة اشتراكات المولدات',
                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
            ]),
          ),

          // ── Card ─────────────────────────────────────────────────────────
          Transform.translate(
            offset: const Offset(0, -28),
            child: Container(
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 12),
              child: Form(
                key: _form,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('تسجيل الدخول',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: p.textPrimary)),
                  const SizedBox(height: 18),
                  SegmentedToggle<LoginKind>(
                    expand: true,
                    selected: _kind,
                    options: const [(LoginKind.account, 'مدير المولدة'), (LoginKind.worker, 'عامل الجباية')],
                    onChanged: (k) => setState(() {
                      _kind = k;
                      _identifier.clear();
                      _auth.errorMessage.value = '';
                    }),
                  ),
                  const SizedBox(height: 22),

                  if (!_hasServer) ...[
                    _Notice(
                      icon: Icons.cloud_off_rounded,
                      color: p.warning,
                      background: p.warningSoft,
                      text: 'التطبيق غير مربوط بخادم Supabase بعد. يمكنك تجربته بالبيانات التجريبية بالأسفل.',
                    ),
                    const SizedBox(height: 16),
                  ],

                  FieldLabel(_isManager ? 'اسم المولدة' : 'رقم الهاتف'),
                  TextFormField(
                    controller: _identifier,
                    enabled: _hasServer,
                    textInputAction: TextInputAction.next,
                    keyboardType: _isManager ? TextInputType.text : TextInputType.phone,
                    textDirection: _isManager ? TextDirection.rtl : TextDirection.ltr,
                    validator: _isManager ? Validators.required : Validators.phone,
                    decoration: InputDecoration(
                      hintText: _isManager ? 'مثال: مولدة الكرخ' : '07XXXXXXXXX',
                      prefixIcon: Icon(_isManager ? Icons.bolt_rounded : Icons.phone_iphone_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const FieldLabel('كلمة المرور'),
                  TextFormField(
                    controller: _password,
                    enabled: _hasServer,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: Validators.required,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _obscure ? 'إظهار' : 'إخفاء',
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),

                  Obx(() => _auth.errorMessage.isEmpty
                      ? const SizedBox(height: 18)
                      : Padding(
                          padding: const EdgeInsets.only(top: 14, bottom: 4),
                          child: _Notice(
                            icon: Icons.error_outline_rounded,
                            color: p.danger,
                            background: p.dangerSoft,
                            text: _auth.errorMessage.value,
                          ),
                        )),

                  const SizedBox(height: 8),
                  Obx(() => LoadingButton(
                        label: 'دخول',
                        icon: Icons.login_rounded,
                        loading: _auth.isLoading.value,
                        onPressed: _hasServer ? _submit : null,
                      )),
                  const SizedBox(height: 14),
                  Obx(() => OutlinedButton.icon(
                        onPressed: _auth.isLoading.value ? null : () => _auth.startDemo(_kind),
                        icon: const Icon(Icons.play_circle_outline_rounded),
                        label: Text(_isManager ? 'جرّب التطبيق كمدير (بيانات تجريبية)' : 'جرّب التطبيق كعامل (بيانات تجريبية)'),
                      )),
                  const SizedBox(height: 22),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.verified_user_rounded, size: 18, color: p.success),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _isManager
                            ? 'حسابات المولدات تُنشأ من قبل الإدارة فقط'
                            : 'يحصل العامل على حسابه من مدير المولدة',
                        style: TextStyle(fontSize: 12, color: p.textSecondary),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String text;

  const _Notice({required this.icon, required this.color, required this.background, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: context.palette.textPrimary, fontSize: 12.5, height: 1.5)),
          ),
        ]),
      );
}
