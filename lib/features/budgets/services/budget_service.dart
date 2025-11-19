import 'package:get/get.dart';
import 'package:moalidaty/features/budgets/models/budgets_model.dart';
import 'package:moalidaty/features/budgets/api/budget_api.dart';

class BudgetService extends GetxService {
  final RxList<Budget> BudgetList = <Budget>[].obs;
  final RxList<Budget> filtered_budgets = <Budget>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool showSearch = false.obs;
  final RxString currentFilter = ''.obs;
  final RxString currentSort = 'date_desc'.obs;

  final budgetApi = BudgetAPI();

  @override
  Future<void> onInit() async {
    super.onInit();
    await getBudgets();
    // Initialize filtered budgets with all budgets
    filtered_budgets.assignAll(BudgetList);
  }

  Future<void> getBudgets() async {
    final fetchedBudgets = await budgetApi.fetchBudgets();
    // Sort by year (descending), then by month (descending)
    fetchedBudgets.sort((a, b) {
      if (b.year != a.year) {
        return b.year.compareTo(a.year);
      }
      return b.month.compareTo(a.month);
    });

    BudgetList.assignAll(fetchedBudgets);
    filtered_budgets.assignAll(fetchedBudgets);
  }

  // Search functionality
  void searchBudgets(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filtered_budgets.assignAll(BudgetList);
    } else {
      final results = BudgetList.where((budget) {
        return budget.budget_uuid.toLowerCase().contains(query.toLowerCase()) ||
            budget.year.toString().contains(query) ||
            budget.month.toString().contains(query) ||
            budget.amber_price.toString().contains(query);
      }).toList();
      filtered_budgets.assignAll(results);
    }
  }

  // Filter by year
  void filterByYear(int? year) {
    if (year == null) {
      filtered_budgets.assignAll(BudgetList);
      currentFilter.value = '';
    } else {
      final results = BudgetList.where(
        (budget) => budget.year == year,
      ).toList();
      filtered_budgets.assignAll(results);
      currentFilter.value = 'year_$year';
    }
  }

  // Filter by month
  void filterByMonth(int? month) {
    if (month == null) {
      filtered_budgets.assignAll(BudgetList);
      currentFilter.value = '';
    } else {
      final results = BudgetList.where(
        (budget) => budget.month == month,
      ).toList();
      filtered_budgets.assignAll(results);
      currentFilter.value = 'month_$month';
    }
  }

  // Filter by payment status
  void filterByPaymentStatus(String status) {
    switch (status) {
      case 'paid':
        final results = BudgetList.where(
          (budget) =>
              budget.getPaidSubsObjects().isNotEmpty &&
              budget.getUnpaidSubsObjects().isEmpty,
        ).toList();
        filtered_budgets.assignAll(results);
        currentFilter.value = 'status_paid';
        break;
      case 'unpaid':
        final results = BudgetList.where(
          (budget) => budget.getUnpaidSubsObjects().isNotEmpty,
        ).toList();
        filtered_budgets.assignAll(results);
        currentFilter.value = 'status_unpaid';
        break;
      case 'mixed':
        final results = BudgetList.where(
          (budget) =>
              budget.getPaidSubsObjects().isNotEmpty &&
              budget.getUnpaidSubsObjects().isNotEmpty,
        ).toList();
        filtered_budgets.assignAll(results);
        currentFilter.value = 'status_mixed';
        break;
      default:
        filtered_budgets.assignAll(BudgetList);
        currentFilter.value = '';
    }
  }

  // Sort budgets
  void sortBudgets(String sortBy) {
    currentSort.value = sortBy;
    final sortedList = List<Budget>.from(filtered_budgets);

    switch (sortBy) {
      case 'date_desc':
        sortedList.sort((a, b) {
          if (b.year != a.year) return b.year.compareTo(a.year);
          return b.month.compareTo(a.month);
        });
        break;
      case 'date_asc':
        sortedList.sort((a, b) {
          if (a.year != b.year) return a.year.compareTo(b.year);
          return a.month.compareTo(b.month);
        });
        break;
      case 'amount_desc':
        sortedList.sort((a, b) {
          final aTotal = _calculateBudgetTotal(a);
          final bTotal = _calculateBudgetTotal(b);
          return bTotal.compareTo(aTotal);
        });
        break;
      case 'amount_asc':
        sortedList.sort((a, b) {
          final aTotal = _calculateBudgetTotal(a);
          final bTotal = _calculateBudgetTotal(b);
          return aTotal.compareTo(bTotal);
        });
        break;
      case 'subscribers_desc':
        sortedList.sort((a, b) {
          final aCount = a.paid_subs.length + a.unpaid_subs.length;
          final bCount = b.paid_subs.length + b.unpaid_subs.length;
          return bCount.compareTo(aCount);
        });
        break;
      case 'subscribers_asc':
        sortedList.sort((a, b) {
          final aCount = a.paid_subs.length + a.unpaid_subs.length;
          final bCount = b.paid_subs.length + b.unpaid_subs.length;
          return aCount.compareTo(bCount);
        });
        break;
    }

    filtered_budgets.assignAll(sortedList);
  }

  // Calculate total budget amount
  double _calculateBudgetTotal(Budget budget) {
    final allSubs = budget.getPaidSubsObjects() + budget.getUnpaidSubsObjects();
    return allSubs.fold(
      0.0,
      (sum, sub) => sum + (sub.amber * budget.amber_price),
    );
  }

  // Get budgets grouped by year
  Map<int, List<Budget>> getBudgetsGroupedByYear() {
    Map<int, List<Budget>> grouped = {};
    for (var budget in filtered_budgets) {
      grouped.putIfAbsent(budget.year, () => []).add(budget);
    }
    return grouped;
  }

  // Get budgets grouped by month
  Map<int, List<Budget>> getBudgetsGroupedByMonth() {
    Map<int, List<Budget>> grouped = {};
    for (var budget in filtered_budgets) {
      grouped.putIfAbsent(budget.month, () => []).add(budget);
    }
    return grouped;
  }

  // Get statistics
  Map<String, dynamic> getBudgetStatistics() {
    if (filtered_budgets.isEmpty) {
      return {
        'total_budgets': 0,
        'total_amount': 0.0,
        'total_subscribers': 0,
        'paid_subscribers': 0,
        'unpaid_subscribers': 0,
        'average_amber_price': 0.0,
      };
    }

    double totalAmount = 0.0;
    int totalSubscribers = 0;
    int paidSubscribers = 0;
    int unpaidSubscribers = 0;
    double totalAmberPrice = 0.0;

    for (var budget in filtered_budgets) {
      final paidSubs = budget.getPaidSubsObjects();
      final unpaidSubs = budget.getUnpaidSubsObjects();

      totalSubscribers += paidSubs.length + unpaidSubs.length;
      paidSubscribers += paidSubs.length;
      unpaidSubscribers += unpaidSubs.length;
      totalAmberPrice += budget.amber_price;

      totalAmount += paidSubs.fold(
        0.0,
        (sum, sub) => sum + (sub.amber * budget.amber_price),
      );
      totalAmount += unpaidSubs.fold(
        0.0,
        (sum, sub) => sum + (sub.amber * budget.amber_price),
      );
    }

    return {
      'total_budgets': filtered_budgets.length,
      'total_amount': totalAmount,
      'total_subscribers': totalSubscribers,
      'paid_subscribers': paidSubscribers,
      'unpaid_subscribers': unpaidSubscribers,
      'average_amber_price': totalAmberPrice / filtered_budgets.length,
    };
  }

  // Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    currentFilter.value = '';
    currentSort.value = 'date_desc';
    filtered_budgets.assignAll(BudgetList);
  }

  Future<void> addBudget(Budget budget) async {
    final createdBudget = await budgetApi.createBudget(budget);
    BudgetList.add(createdBudget);
    filtered_budgets.add(createdBudget);
  }

  Future<void> updateBudget(int id, Budget budget) async {
    final updatedBudget = await budgetApi.updateBudget(id, budget);
    final index = BudgetList.indexWhere((b) => b.id == id);
    if (index != -1) {
      BudgetList[index] = updatedBudget;
      final filterIndex = filtered_budgets.indexWhere((b) => b.id == id);
      if (filterIndex != -1) {
        filtered_budgets[filterIndex] = updatedBudget;
      }
    }
  }

  Future<bool> removeBudget(Budget budget) async {
    if (await budgetApi.destroyBudget(budget.id)) {
      BudgetList.remove(budget);
      filtered_budgets.remove(budget);
      return true;
    }
    return false;
  }

  Budget? getBudgetById(int id) {
    return BudgetList.firstWhere((b) => b.id == id);
  }

  Budget? getBudgetByYearMonth(String yearMonth) {
    return BudgetList.firstWhere((b) => b.budget_uuid == yearMonth);
  }

  List<Budget> getBudgetsByYear(int year) {
    return BudgetList.where((b) => b.year == year).toList();
  }

  List<Budget> getBudgetsByMonth(int month) {
    return BudgetList.where((b) => b.month == month).toList();
  }

  List<Budget> getBudgetsByYearAndMonth(int year, int month) {
    return BudgetList.where((b) => b.year == year && b.month == month).toList();
  }
}
