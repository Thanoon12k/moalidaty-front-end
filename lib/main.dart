import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/storage/secure_storage.dart';
import 'core/network/api_client.dart';
import 'core/theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/subscribers/controllers/subscriber_controller.dart';
import 'features/receipts/controllers/receipt_controller.dart';
import 'features/budgets/controllers/budget_controller.dart';
import 'features/workers/controllers/worker_controller.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Core services (order matters) ──
  Get.put(SecureStorage());
  Get.put(ApiClient());

  // ── Feature controllers — registered globally so Get.find never throws ──
  // Using fenix:true means GetX auto-recreates them if the page is disposed
  Get.put(AuthController(), permanent: true);
  Get.lazyPut<SubscriberController>(() => SubscriberController(), fenix: true);
  Get.lazyPut<ReceiptController>(() => ReceiptController(), fenix: true);
  Get.lazyPut<BudgetController>(() => BudgetController(), fenix: true);
  Get.lazyPut<WorkerController>(() => WorkerController(), fenix: true);

  runApp(const MoalidatnaApp());
}

class MoalidatnaApp extends StatelessWidget {
  const MoalidatnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'مولداتنا',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar', 'IQ'),
      supportedLocales: const [Locale('ar', 'IQ')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      textDirection: TextDirection.rtl,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
