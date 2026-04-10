import 'package:get/get.dart';

import 'features/auth/ui/splash_screen.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/subscribers/ui/subscribers_screen.dart';
import 'features/receipts/ui/receipts_screen.dart';
import 'features/budgets/ui/budgets_screen.dart';
import 'features/workers/ui/workers_screen.dart';

abstract class AppRoutes {
  static const splash      = '/';
  static const login       = '/login';
  static const home        = '/home';
  static const subscribers = '/subscribers';
  static const receipts    = '/receipts';
  static const budgets     = '/budgets';
  static const workers     = '/workers';

  // All controllers are pre-registered in main() with fenix:true,
  // so no per-page bindings are needed.
  static final pages = [
    GetPage(name: splash,      page: () => const SplashScreen()),
    GetPage(name: login,       page: () => const LoginScreen()),
    GetPage(name: home,        page: () => const HomeScreen()),
    GetPage(name: subscribers, page: () => const SubscribersScreen()),
    GetPage(name: receipts,    page: () => const ReceiptsScreen()),
    GetPage(name: budgets,     page: () => const BudgetsScreen()),
    GetPage(name: workers,     page: () => const WorkersScreen()),
  ];
}
