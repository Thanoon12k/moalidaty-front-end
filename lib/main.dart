import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/loading_indicator.dart';
import 'package:moalidaty/common_widgets/network_error.dart';
import 'package:moalidaty/features/budgets/services/budget_service.dart';
import 'package:moalidaty/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty/features/workers/services/service_worker.dart';
import 'package:moalidaty/home.dart';
import 'package:moalidaty/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

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
      home: const StartupScreen(),
      getPages: Routes.pages,
      initialRoute: Routes.home,
    );
  }
}

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initServices().timeout(const Duration(seconds: 10)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: GeneratorLoadingIndicator()),
          );
        } else if (snapshot.hasError) {
          return ErrorDisplayWidget(error: snapshot.error);
        } else {
          return const HomePage();
        }
      },
    );
  }
}

Future<void> initServices() async {
  Get.lazyPut<BudgetService>(() => BudgetService());
  Get.lazyPut<SubscribersService>(() => SubscribersService());
  Get.lazyPut<WorkerService>(() => WorkerService());
  Get.lazyPut<ReceiptServices>(() => ReceiptServices());

  await Get.find<BudgetService>().onInit();
  await Get.find<SubscribersService>().onInit();
  await Get.find<WorkerService>().onInit();
  await Get.find<ReceiptServices>().onInit();
}
