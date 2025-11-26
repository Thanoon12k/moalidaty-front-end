import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/loading_indicator.dart';
import 'package:moalidaty/common_widgets/network_error.dart';
import 'package:moalidaty/constants/global_service_manager.dart';
import 'package:moalidaty/features/Account/ui/account_login.dart';

import 'package:moalidaty/home.dart';
import 'package:moalidaty/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs;
  });
  Get.put(GlobalServiceManager());
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Moalidaty',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'IQ'),
      supportedLocales: const [Locale('ar', 'IQ')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(fontFamily: 'Cairo'),
      textDirection: TextDirection.rtl,
      getPages: Routes.pages,
      initialRoute: Routes.splashScreen,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // ignore: no_leading_underscores_for_local_identifiers
    final _global_manager = Get.find<GlobalServiceManager>();
    final user = await _global_manager.getUserFromPreference();
    await Future.delayed(const Duration(seconds: 5));
    if (user != null) {
      await _global_manager.refershApplicationData();
      Get.offNamed(Routes.home);
    } else {
      Get.offNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: GeneratorLoadingIndicator()));
  }
}
