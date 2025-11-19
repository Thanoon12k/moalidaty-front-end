import 'package:get/get.dart';
import 'package:moalidaty/features/Account/ui/account_info.dart';
import 'package:moalidaty/features/Account/ui/account_login.dart';
import 'package:moalidaty/features/budgets/ui/budgets_list.dart';
import 'package:moalidaty/features/reciepts/ui/list_reciepts.dart';
import 'package:moalidaty/features/subscripers/ui/subscripers_list.dart';
import 'package:moalidaty/features/workers/ui/list_workers.dart';
import 'package:moalidaty/home.dart';

final class Routes {
  static const String home = '/';
  static const String workerList = '/worker-list';
  static const String subscripersList = '/supscripers-list';
  static const String recieptsList = '/reciepts-list';
  static const String budgetsList = '/budgets-list';
  static const String accountInfo = '/account-page';
  static const String login = '/login';

  static List<GetPage> get pages => [
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: workerList, page: () => WorkersListPage()),
    GetPage(name: subscripersList, page: () => SubscripersListPage()),
    GetPage(name: recieptsList, page: () => RecieptsListPage()),
    GetPage(name: budgetsList, page: () => BudgetsListPage()),
    GetPage(name: accountInfo, page: () => AccountInfoPage()),
    GetPage(name: login, page: () => AccountLoginPage()),
  ];
}
