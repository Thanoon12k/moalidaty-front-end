import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _auth = Get.find<AuthController>();

  // Account login fields
  final _genNameCtrl = TextEditingController();
  final _passCtrl    = TextEditingController();

  // Worker login fields
  final _wPhoneCtrl  = TextEditingController();
  final _wPassCtrl   = TextEditingController();

  // Register fields
  final _regNameCtrl  = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regPassCtrl  = TextEditingController();

  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _genNameCtrl.dispose();
    _passCtrl.dispose();
    _wPhoneCtrl.dispose();
    _wPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.electrical_services_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'مولداتنا',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'نظام إدارة اشتراكات المولدة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // ── Card ───────────────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    // Tab bar
                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabs,
                        indicator: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppTheme.textMid,
                        labelStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'المدير'),
                          Tab(text: 'العامل'),
                          Tab(text: 'حساب جديد'),
                        ],
                      ),
                    ),

                    // Tab views
                    Expanded(
                      child: TabBarView(
                        controller: _tabs,
                        children: [
                          _AccountLoginTab(
                            genNameCtrl: _genNameCtrl,
                            passCtrl: _passCtrl,
                            obscure: _obscurePass,
                            onToggleObscure: () =>
                                setState(() => _obscurePass = !_obscurePass),
                            auth: _auth,
                          ),
                          _WorkerLoginTab(
                            phoneCtrl: _wPhoneCtrl,
                            passCtrl: _wPassCtrl,
                            obscure: _obscurePass,
                            onToggleObscure: () =>
                                setState(() => _obscurePass = !_obscurePass),
                            auth: _auth,
                          ),
                          _RegisterTab(
                            nameCtrl: _regNameCtrl,
                            phoneCtrl: _regPhoneCtrl,
                            passCtrl: _regPassCtrl,
                            auth: _auth,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Account login tab ────────────────────────────────────────────────────────

class _AccountLoginTab extends StatelessWidget {
  final TextEditingController genNameCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final AuthController auth;

  const _AccountLoginTab({
    required this.genNameCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Text(
            'تسجيل دخول المدير',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'أدخل اسم المولدة وكلمة المرور',
            style: TextStyle(fontFamily: 'Cairo', color: AppTheme.textMid),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          TextField(
            controller: genNameCtrl,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'اسم المولدة',
              prefixIcon: Icon(Icons.electrical_services_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passCtrl,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggleObscure,
              ),
            ),
          ),

          const SizedBox(height: 8),
          Obx(() {
            if (auth.errorMessage.isNotEmpty && auth.isLoading.isFalse) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  auth.errorMessage.value,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.red.shade700,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 24),
          Obx(() => ElevatedButton(
            onPressed: auth.isLoading.value
                ? null
                : () => auth.loginAsAccount(
                      generatorName: genNameCtrl.text,
                      password: passCtrl.text,
                    ),
            child: auth.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('دخول'),
          )),
        ],
      ),
    );
  }
}

// ─── Worker login tab ─────────────────────────────────────────────────────────

class _WorkerLoginTab extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final AuthController auth;

  const _WorkerLoginTab({
    required this.phoneCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Text(
            'تسجيل دخول العامل',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'أدخل رقم هاتفك وكلمة المرور',
            style: TextStyle(fontFamily: 'Cairo', color: AppTheme.textMid),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: Icon(Icons.phone),
              hintText: '07XXXXXXXXX',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passCtrl,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggleObscure,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (auth.errorMessage.isNotEmpty && auth.isLoading.isFalse) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  auth.errorMessage.value,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.red.shade700,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 24),
          Obx(() => ElevatedButton(
            onPressed: auth.isLoading.value
                ? null
                : () => auth.loginAsWorker(
                      phone: phoneCtrl.text,
                      password: passCtrl.text,
                    ),
            child: auth.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('دخول'),
          )),
        ],
      ),
    );
  }
}

// ─── Register tab ────────────────────────────────────────────────────────────

class _RegisterTab extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passCtrl;
  final AuthController auth;

  const _RegisterTab({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.passCtrl,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Text(
            'تسجيل مولدة جديدة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'اسم المولدة + رقم الهاتف = بيانات الدخول',
            style: TextStyle(fontFamily: 'Cairo', color: AppTheme.textMid),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          TextField(
            controller: nameCtrl,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'اسم المولدة',
              prefixIcon: Icon(Icons.electrical_services_rounded),
              hintText: 'مثال: مولدة الحي',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: Icon(Icons.phone),
              hintText: '07XXXXXXXXX',
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (auth.errorMessage.isNotEmpty && auth.isLoading.isFalse) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  auth.errorMessage.value,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.red.shade700,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 24),
          Obx(() => ElevatedButton(
            onPressed: auth.isLoading.value
                ? null
                : () => auth.register(
                      generatorName: nameCtrl.text,
                      phone: phoneCtrl.text,
                      password: passCtrl.text,
                    ),
            child: auth.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('إنشاء الحساب'),
          )),
        ],
      ),
    );
  }
}
