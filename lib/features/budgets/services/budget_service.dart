import 'package:get/get.dart';
import 'package:moalidaty1/features/budgets/models/model.dart';
import 'package:moalidaty1/features/budgets/repositories/repository.dart';

class BudgetService extends GetxService {
  final RxList<Budget> budgets = <Budget>[].obs;
  final budgetRepository = BudgetRepository();

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchBudgets();
  }

  Future<void> fetchBudgets() async {
    try {
      final fetchedBudgets = await budgetRepository.fetchBudgets();
      print('Fetched ${fetchedBudgets.length} budgets');
      print('Budgets: $fetchedBudgets');
      budgets.assignAll(fetchedBudgets);
    } catch (e) {
      print('Error fetching budgets: $e');
      // You might want to show a snackbar or handle error UI here
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      final createdBudget = await budgetRepository.createBudget(budget);
      budgets.add(createdBudget);
    } catch (e) {
      print('Error adding budget: $e');
      rethrow;
    }
  }

  Future<void> updateBudget(int id, Budget budget) async {
    try {
      final updatedBudget = await budgetRepository.updateBudget(id, budget);
      final index = budgets.indexWhere((b) => b.id == id);
      if (index != -1) {
        budgets[index] = updatedBudget;
      }
    } catch (e) {
      print('Error updating budget: $e');
      rethrow;
    }
  }

  Future<void> removeBudget(int id) async {
    try {
      await budgetRepository.deleteBudget(id);
      final index = budgets.indexWhere((b) => b.id == id);
      if (index != -1) {
        budgets.removeAt(index);
      }
    } catch (e) {
      print('Error removing budget: $e');
      rethrow;
    }
  }

  Budget? getBudgetById(int id) {
    try {
      return budgets.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  Budget? getBudgetByYearMonth(String yearMonth) {
    try {
      return budgets.firstWhere((b) => b.year_month == yearMonth);
    } catch (e) {
      return null;
    }
  }

  List<Budget> getBudgetsByYear(int year) {
    return budgets.where((b) => b.year == year).toList();
  }
}
