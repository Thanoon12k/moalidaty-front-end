import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../core/theme.dart';
import '../subscribers/ui/subscribers_screen.dart';
import '../receipts/ui/receipts_screen.dart';
import '../budgets/ui/budgets_screen.dart';
import '../workers/ui/workers_screen.dart';
import '../subscribers/controllers/subscriber_controller.dart';
import '../receipts/controllers/receipt_controller.dart';
import '../budgets/controllers/budget_controller.dart';
import '../workers/controllers/worker_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _screens = const [
    SubscribersScreen(),
    ReceiptsScreen(),
    BudgetsScreen(),
    WorkersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final subCtrl = Get.find<SubscriberController>();
    final recCtrl = Get.find<ReceiptController>();
    final budCtrl = Get.find<BudgetController>();
    final worCtrl = Get.find<WorkerController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          'مولدة ${auth.generatorName}',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث البيانات',
            onPressed: () {
              subCtrl.load();
              recCtrl.load();
              budCtrl.load();
              worCtrl.load();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'logout') {
                Get.dialog(_LogoutDialog());
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Summary header ─────────────────────────────────────────────────────
      body: Column(
        children: [
          _SummaryBanner(
            subCtrl: subCtrl,
            recCtrl: recCtrl,
            budCtrl: budCtrl,
            worCtrl: worCtrl,
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),

      // ── Bottom navigation ─────────────────────────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        elevation: 4,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'المشتركون',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'الإيصالات',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'الميزانية',
          ),
          NavigationDestination(
            icon: Icon(Icons.engineering_outlined),
            selectedIcon: Icon(Icons.engineering),
            label: 'العمال',
          ),
        ],
      ),

      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => Get.find<ReceiptController>().showAddSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('إيصال جديد', style: TextStyle(fontFamily: 'Cairo')),
            )
          : null,
    );
  }
}

// ─── Summary banner (4 stat chips) ───────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  final SubscriberController subCtrl;
  final ReceiptController recCtrl;
  final BudgetController budCtrl;
  final WorkerController worCtrl;

  const _SummaryBanner({
    required this.subCtrl,
    required this.recCtrl,
    required this.budCtrl,
    required this.worCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Obx(() => Row(
        children: [
          _chip(Icons.people, '${subCtrl.items.length}', 'مشترك'),
          _chip(Icons.receipt_long, '${recCtrl.items.length}', 'إيصال'),
          _chip(Icons.account_balance_wallet, '${budCtrl.items.length}', 'شهر'),
          _chip(Icons.engineering, '${worCtrl.items.length}', 'عامل'),
        ],
      )),
    );
  }

  Widget _chip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Logout confirm dialog ────────────────────────────────────────────────────

class _LogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'تسجيل الخروج',
        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'هل تريد تسجيل الخروج من التطبيق؟',
        style: TextStyle(fontFamily: 'Cairo'),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Get.find<AuthController>().logout(),
          child: const Text('خروج', style: TextStyle(fontFamily: 'Cairo')),
        ),
      ],
    );
  }
}
