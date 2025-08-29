import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
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
  await initServices();
  runApp(const MyApp());
}

Future<void> initServices() async {
  print('Starting services initialization...');

  // ttry {
  // Register services
  Get.lazyPut<BudgetService>(() => BudgetService());
  Get.lazyPut<WorkerService>(() => WorkerService());
  Get.lazyPut<SubscripersService>(() => SubscripersService());
  Get.lazyPut<RecieptServices>(() => RecieptServices());

  // Initialize services in parallel
  await Future.wait([
    Get.find<BudgetService>().onInit(),

    Get.find<SubscripersService>().onInit(),
    Get.find<WorkerService>().onInit(),
    Get.find<RecieptServices>().onInit(),
  ]);

  print('All services initialized successfully');
  // } catch (e, stackTrace) {
  //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
  //   print(stackTrace);
  //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
  //   // You might want to show an error dialog or handle the error appropriately
  // }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Moalidaty',
      debugShowCheckedModeBanner: false,
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
      appBar: AppBar(title: Text('ادارة المولدة')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(() => WorkersListPage());
              },
              child: Text('عرض قائمة المشغلين', style: TextStyle(fontSize: 20)),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(() => SubscripersListPage());
              },
              child: Text(
                'عرض قائمة المشتركين',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(() => RecieptsListPage());
              },
              child: Text(
                'عرض قائمة الإيصالات',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(() => BudgetsListPage());
              },
              child: Text('عرض قائمة المبالغ', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
