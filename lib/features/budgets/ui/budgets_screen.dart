import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/analytics/analytics_controller.dart';
import '../../../core/widgets/common.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../shell/ui/tab_header.dart';
import '../controllers/budget_controller.dart';
import 'budget_card.dart';
import 'budget_form_sheet.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ctrl = Get.find<BudgetController>();
    final stats = Get.find<AnalyticsController>();
    final auth = Get.find<AuthController>();

    return RefreshIndicator(
      onRefresh: auth.reloadAll,
      child: Obx(() {
        final a = stats.analytics.value;
        final months = a.months.reversed.toList();
        return ListView(padding: const EdgeInsets.only(bottom: 110), children: [
          TabHeader(
            subtitle: 'سعر الأمبير ونسبة التحصيل لكل شهر',
            title: 'الميزانيات الشهرية',
            onAdd: auth.isManager ? () => showBudgetForm() : null,
            addTooltip: 'إضافة ميزانية',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(children: [
              if (ctrl.isOffline.value) const OfflineBanner(),
              if (ctrl.isLoading.value && months.isEmpty)
                const Padding(padding: EdgeInsets.only(top: 120), child: CircularProgressIndicator())
              else if (months.isEmpty)
                EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'لا توجد ميزانيات بعد',
                  subtitle: auth.isManager
                      ? 'أضف ميزانية الشهر بتحديد سعر الأمبير'
                      : 'يضيف مدير المولدة ميزانية كل شهر',
                  actionLabel: auth.isManager ? 'إضافة ميزانية' : null,
                  onAction: auth.isManager ? () => showBudgetForm() : null,
                )
              else
                for (final m in months)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BudgetCard(summary: a.summary(m)),
                  ),
            ]),
          ),
        ]);
      }),
    );
  }
}
