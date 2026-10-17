import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../budgets/ui/budgets_screen.dart';
import '../../dashboard/ui/dashboard_screen.dart';
import '../../receipts/ui/receipt_form_sheet.dart';
import '../../receipts/ui/receipts_screen.dart';
import '../../subscribers/ui/subscribers_screen.dart';
import 'app_menu.dart';

/// Selected tab, shared so any screen can switch tabs ("عرض الكل").
class ShellController extends GetxController {
  final index = 0.obs;
  final pages = PageController();

  void goTo(int i) {
    index.value = i;
    if (pages.hasClients) {
      pages.animateToPage(i, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  @override
  void onClose() {
    pages.dispose();
    super.onClose();
  }
}

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static final scaffoldKey = GlobalKey<ScaffoldState>();

  static void openMenu() => scaffoldKey.currentState?.openEndDrawer();

  @override
  Widget build(BuildContext context) {
    final shell = Get.put(ShellController());
    final p = context.palette;

    return Scaffold(
      key: scaffoldKey,
      extendBody: true,
      endDrawer: const AppMenu(),
      // Swipe left / right between the four sections.
      body: PageView(
        controller: shell.pages,
        onPageChanged: (i) => shell.index.value = i,
        children: const [
          DashboardScreen(),
          SubscribersScreen(),
          ReceiptsScreen(),
          BudgetsScreen(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Tooltip(
        message: 'إيصال جديد',
        child: SizedBox(
          width: 58,
          height: 58,
          child: FloatingActionButton(
            heroTag: 'shell_fab',
            elevation: 3,
            backgroundColor: p.fab,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: () => showReceiptForm(),
            child: const Icon(Icons.add_rounded, size: 32),
          ),
        ),
      ),
      bottomNavigationBar: Obx(() => _BottomBar(index: shell.index.value, onTap: shell.goTo)),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget item(int i, IconData icon, IconData active, String label) {
      final on = i == index;
      return Expanded(
        child: Semantics(
          selected: on,
          button: true,
          label: label,
          child: InkResponse(
            onTap: () => onTap(i),
            radius: 32,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(on ? active : icon, color: on ? p.primary : p.textMuted, size: 24),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                    color: on ? p.primary : p.textMuted,
                  )),
            ]),
          ),
        ),
      );
    }

    return BottomAppBar(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shadowColor: p.shadow,
      shape: const CircularNotchedRectangle(),
      notchMargin: 7,
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(children: [
        item(0, Icons.space_dashboard_outlined, Icons.space_dashboard_rounded, 'الرئيسية'),
        item(1, Icons.people_outline_rounded, Icons.people_rounded, 'المشتركون'),
        const SizedBox(width: 64),
        item(2, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'الإيصالات'),
        item(3, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'الميزانيات'),
      ]),
    );
  }
}
