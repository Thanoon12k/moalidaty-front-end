import 'package:get/get.dart';
import 'package:moalidaty1/features/budgets/models/budgets_model.dart';
import 'package:moalidaty1/features/budgets/repositories/repository.dart';

class BudgetService extends GetxService {
  final RxList<Budget> list_budgets = <Budget>[].obs;
  final budgetRepository = BudgetRepository();

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchBudgets();
  }

  Future<void> fetchBudgets() async {
    // ttry {
    final fetchedBudgets = await budgetRepository.fetchBudgets();
    print('Fetched ${fetchedBudgets.length} budgets');
    print('Budgets: $fetchedBudgets');
    list_budgets.assignAll(fetchedBudgets);
    // } catch (e, stackTrace) {
    //   print('Error is: (( $e ))');
    //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
    //   print(stackTrace);
    //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
    //   rethrow;
    //   print('Error fetching budgets: $e');
    //   // You might want to show a snackbar or handle error UI here
    // }
  }

  Future<void> addBudget(Budget budget) async {
    // ttry {
    final createdBudget = await budgetRepository.createBudget(budget);
    list_budgets.add(createdBudget);
    // } catch (e, stackTrace) {
    //   print('Error is: (( $e ))');
    //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
    //   print(stackTrace);
    //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
    //   rethrow;
    //   print('Error adding budget: $e');
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
    //   print('Error is: (( $e ))');
    //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
    //   print(stackTrace);
    //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
    //   rethrow;
    //   print('Error updating budget: $e');
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
    //   print('Error is: (( $e ))');
    //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
    //   print(stackTrace);
    //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
    //   rethrow;
    //   print('Error removing budget: $e');
    //   rethrow;
    // }
  }

  Budget? getBudgetById(int id) {
    // ttry {
    return list_budgets.firstWhere((b) => b.id == id);
    // } catch (e, stackTrace) {
    //   print('Error is: (( $e ))');
    //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
    //   print(stackTrace);
    //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
    //   rethrow;
    //   return null;
    // }
  }

  Budget? getBudgetByYearMonth(String yearMonth) {
    // ttry {
    return list_budgets.firstWhere((b) => b.year_month == yearMonth);
    // } catch (e, stackTrace) {
    //   print('Error is: (( $e ))');
    //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
    //   print(stackTrace);
    //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
    //   rethrow;
    //   return null;
    // }
  }

  List<Budget> getBudgetsByYear(int year) {
    return list_budgets.where((b) => b.year == year).toList();
  }
}
