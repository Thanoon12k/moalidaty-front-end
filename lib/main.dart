import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/common_widgets/appbar.dart';
import 'package:moalidaty1/common_widgets/loading_indicator.dart';
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/budgets/services/budget_service.dart';
import 'package:moalidaty1/features/budgets/ui/budgets_list.dart';
import 'package:moalidaty1/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty1/features/reciepts/ui/list_reciepts.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/subscripers/ui/subscripersList.dart';
import 'package:moalidaty1/features/workers/services/service_worker.dart';
import 'package:moalidaty1/features/workers/ui/list_workers.dart';
import 'package:moalidaty1/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

Future<void> initServices() async {
  // Register services
  Get.lazyPut<BudgetService>(() => BudgetService());
  Get.lazyPut<SubscribersService>(() => SubscribersService());
  Get.lazyPut<WorkerService>(() => WorkerService());
  Get.lazyPut<ReceiptServices>(() => ReceiptServices());

  // Initialize services sequentially
  await Get.find<BudgetService>().onInit();
  await Get.find<SubscribersService>().onInit();
  await Get.find<WorkerService>().onInit();
  await Get.find<ReceiptServices>().onInit();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalConstants.globalScreenWidth = MediaQuery.of(context).size.width;
    GlobalConstants.globalScreenHeight = MediaQuery.of(context).size.height;

    return GetMaterialApp(
      title: 'Moalidaty',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: initServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: GeneratorLoadingIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error initializing services: ${snapshot.error}'),
              ),
            );
          } else {
            return const HomePage();
          }
        },
      ),
      initialRoute: Routes.home,
      getPages: Routes.pages,
      locale: const Locale('ar', 'IQ'), // اللغة: عربية، الدولة: العراق
      supportedLocales: const [
        Locale('ar', 'IQ'), // يمكنك إضافة لغات أخرى إذا أردت
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        fontFamily: 'Cairo', // اختياري: لتطبيق خط عربي جميل
      ),
      textDirection: TextDirection.rtl, // ← هذا يفرض الاتجاه اليدويًا (اختياري)
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'أدارة المولدة', font_size: 32),

      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Get.to(() => WorkersListPage());
              },
              child: Text('عرض قائمة المشغلين', style: TextStyle(fontSize: 19)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(() => SubscripersListPage());
              },
              child: Text(
                'عرض قائمة المشتركين',
                style: TextStyle(fontSize: 19),
              ),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Get.to(() => RecieptsListPage());
              },
              child: Text(
                'عرض قائمة الإيصالات',
                style: TextStyle(fontSize: 19),
              ),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Get.to(() => BudgetsListPage());
              },
              child: Text('عرض قائمة المبالغ', style: TextStyle(fontSize: 19)),
            ),
          ],
        ),
      ),
    );
  }
}
