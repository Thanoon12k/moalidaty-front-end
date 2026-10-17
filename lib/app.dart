import 'package:get/get.dart';

import 'features/auth/ui/login_screen.dart';
import 'features/auth/ui/splash_screen.dart';
import 'features/shell/ui/home_shell.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';

  // Controllers are registered once in registerDependencies(); detail screens
  // are opened with Get.to().
  static final pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen(), transition: Transition.fadeIn),
    GetPage(name: home, page: () => const HomeShell(), transition: Transition.fadeIn),
  ];
}
