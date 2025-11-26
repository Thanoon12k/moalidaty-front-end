import 'package:get/get.dart';
import 'package:moalidaty/features/Account/ui/account_info.dart';
import 'package:moalidaty/features/Account/ui/account_login.dart';
import 'package:moalidaty/features/budgets/ui/budgets_list.dart';
import 'package:moalidaty/features/reciepts/ui/list_reciepts.dart';
import 'package:moalidaty/features/subscripers/ui/subscripers_list.dart';
import 'package:moalidaty/features/workers/ui/list_workers.dart';
import 'package:moalidaty/home.dart';
import 'package:moalidaty/main.dart';
import 'package:moalidaty/routes/home_bindings.dart';
import 'package:moalidaty/routes/login_bindings.dart';

final class Routes {
  static const String splashScreen = '/splash-screen';
  static const String home = '/home';
  static const String workerList = '/worker-list';
  static const String subscripersList = '/supscripers-list';
  static const String recieptsList = '/reciepts-list';
  static const String budgetsList = '/budgets-list';
  static const String accountInfo = '/account-page';
  static const String login = '/login';

  static List<GetPage> get pages => [
    GetPage(
      name: splashScreen,
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => HomePage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: workerList,
      page: () => WorkersListPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: subscripersList,
      page: () => SubscripersListPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: recieptsList,
      page: () => RecieptsListPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: budgetsList,
      page: () => BudgetsListPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: accountInfo,
      page: () => AccountInfoPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => AccountLoginPage(),
      transition: Transition.fadeIn,
      binding: LoginBinding(),
    ),
  ];
}
