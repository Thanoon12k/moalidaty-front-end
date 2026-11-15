import 'package:get/get.dart';

import '../../features/budgets/controllers/budget_controller.dart';
import '../../features/receipts/controllers/receipt_controller.dart';
import '../../features/subscribers/controllers/subscriber_controller.dart';
import '../../features/workers/controllers/worker_controller.dart';
import 'analytics.dart';

/// Recomputes [Analytics] whenever any list changes, so every chart reads
/// one consistent snapshot through `Obx`.
class AnalyticsController extends GetxController {
  final analytics = Rx<Analytics>(Analytics(subscribers: const [], budgets: const [], receipts: const []));

  final _subs = Get.find<SubscriberController>();
  final _budgets = Get.find<BudgetController>();
  final _receipts = Get.find<ReceiptController>();
  final _workers = Get.find<WorkerController>();

  @override
  void onInit() {
    super.onInit();
    everAll([_subs.items, _budgets.items, _receipts.items, _workers.items], (_) => _recompute());
    _recompute();
  }

  void _recompute() {
    analytics.value = Analytics(
      subscribers: List.of(_subs.items),
      budgets: List.of(_budgets.items),
      receipts: List.of(_receipts.items),
      workers: List.of(_workers.items),
    );
  }

  /// The month the dashboard opens on: the current month if it has a budget,
  /// otherwise the latest budget month.
  MonthKey get focusMonth {
    final now = MonthKey.of(DateTime.now());
    final months = analytics.value.months;
    if (months.isEmpty || months.contains(now)) return now;
    return months.last;
  }
}
