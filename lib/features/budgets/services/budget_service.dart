import 'package:get/get.dart';
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/budgets/models/budgets_model.dart';
import 'package:moalidaty1/features/budgets/api/budget_api.dart';

class BudgetService extends GetxService {
  final RxList<Budget> list_budgets = <Budget>[].obs;
  final budgetApi = BudgetAPI();

  @override
  Future<void> onInit() async {
    super.onInit();
    await getBudgets();
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

    list_budgets.assignAll(fetchedBudgets);

  }

  Future<void> addBudget(Budget budget) async {
    final createdBudget = await budgetApi.createBudget(budget);
    list_budgets.add(createdBudget);
   
  }

  Future<void> updateBudget(int id, Budget budget) async {
    final updatedBudget = await budgetApi.updateBudget(id, budget);
    final index = list_budgets.indexWhere((b) => b.id == id);
    if (index != -1) {
      list_budgets[index] = updatedBudget;
    }
   
  }

  Future<void> removeBudget(int id) async {
    await budgetApi.deleteBudget(id);
    final index = list_budgets.indexWhere((b) => b.id == id);
    if (index != -1) {
      list_budgets.removeAt(index);
    }
   
  }

  Budget? getBudgetById(int id) {
    return list_budgets.firstWhere((b) => b.id == id);

  }

  Budget? getBudgetByYearMonth(String yearMonth) {
    return list_budgets.firstWhere((b) => b.year_month == yearMonth);

  }

  List<Budget> getBudgetsByYear(int year) {
    return list_budgets.where((b) => b.year == year).toList();
  }

}
