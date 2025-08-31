import 'package:get/get.dart';
import 'package:moalidaty1/features/budgets/ui/budgets_list.dart';
import 'package:moalidaty1/features/reciepts/ui/list_reciepts.dart';
import 'package:moalidaty1/features/subscripers/ui/subscripers_list.dart';
import 'package:moalidaty1/features/workers/ui/list_workers.dart';
import 'package:moalidaty1/home.dart';

final class Routes {
  static const String home = '/';
  static const String workerList = '/worker-list';
  static const String subscripersList = '/supscripers-list';
  static const String recieptsList = '/reciepts-list';
  static const String budgetsList = '/budgets-list';

  static List<GetPage> get pages => [
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: workerList, page: () => WorkersListPage()),
    GetPage(name: subscripersList, page: () => SubscripersListPage()),
    GetPage(name: recieptsList, page: () => RecieptsListPage()),
    GetPage(name: budgetsList, page: () => BudgetsListPage()),
  ];
}
