import 'package:get/get.dart';
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/budgets/models/budgets_model.dart';
import 'package:moalidaty1/features/budgets/api/budget_api.dart';

class BudgetService extends GetxService {
  final RxList<Budget> list_budgets = <Budget>[].obs;
  final budgetRepository = BudgetAPI();

  @override
  Future<void> onInit() async {
    super.onInit();
    await getBudgets();
  }

  Future<void> getBudgets() async {
    final fetchedBudgets = await budgetRepository.fetchBudgets();
    // Sort by year (descending), then by month (descending)
    fetchedBudgets.sort((a, b) {
      if (b.year != a.year) {
        return b.year.compareTo(a.year);
      }
      return b.month.compareTo(a.month);
    });

    list_budgets.assignAll(fetchedBudgets);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   // You might want to show a snackbar or handle error UI here
    // }
  }

  Future<void> addBudget(Budget budget) async {
    // ttry {
    final createdBudget = await budgetRepository.createBudget(budget);
    list_budgets.add(createdBudget);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Future<void> updateBudget(int id, Budget budget) async {
    // ttry {
    final updatedBudget = await budgetRepository.updateBudget(id, budget);
    final index = list_budgets.indexWhere((b) => b.id == id);
    if (index != -1) {
      list_budgets[index] = updatedBudget;
    }
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Future<void> removeBudget(int id) async {
    // ttry {
    await budgetRepository.deleteBudget(id);
    final index = list_budgets.indexWhere((b) => b.id == id);
    if (index != -1) {
      list_budgets.removeAt(index);
    }
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Budget? getBudgetById(int id) {
    // ttry {
    return list_budgets.firstWhere((b) => b.id == id);
    // } catch (e, stackTrace) {

    //   rethrow;
    //   return null;
    // }
  }

  Budget? getBudgetByYearMonth(String yearMonth) {
    // ttry {
    return list_budgets.firstWhere((b) => b.year_month == yearMonth);
    // } catch (e, stackTrace) {

    //   rethrow;
    //   return null;
    // }
  }

  List<Budget> getBudgetsByYear(int year) {
    return list_budgets.where((b) => b.year == year).toList();
  }
}
