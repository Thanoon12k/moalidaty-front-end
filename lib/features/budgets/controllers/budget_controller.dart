import '../../../core/data/collection_controller.dart';
import '../models/budget.dart';

class BudgetController extends CollectionController<Budget> {
  @override
  String get cacheName => 'budgets';

  @override
  Future<List<Budget>> fetch() => ds.fetchBudgets();

  @override
  Budget fromRow(Map<String, dynamic> row) => Budget.fromRow(row);

  @override
  Map<String, dynamic> toRow(Budget item) => item.toRow();

  Budget? budgetFor(int year, int month) {
    for (final b in items) {
      if (b.year == year && b.month == month) return b;
    }
    return null;
  }

  /// Newest month first.
  Budget? get latest => items.isEmpty ? null : items.first;

  Future<Budget> add(int year, int month, double amberPrice) async {
    final b = await ds.addBudget(year, month, amberPrice);
    items.add(b);
    _sort();
    return b;
  }

  Future<Budget> updatePrice(int id, double amberPrice) async {
    final b = await ds.updateBudgetPrice(id, amberPrice);
    final i = items.indexWhere((x) => x.id == id);
    if (i >= 0) items[i] = b;
    return b;
  }

  Future<void> delete(int id) async {
    await ds.deleteBudget(id);
    items.removeWhere((b) => b.id == id);
  }

  void _sort() => items.sort((a, b) => b.period.compareTo(a.period));
}
