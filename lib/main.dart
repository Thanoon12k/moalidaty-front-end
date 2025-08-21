import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/features/reciepts/ui/list_reciepts.dart';
import 'package:moalidaty1/features/subscripers/ui/subscripersList.dart';
import 'package:moalidaty1/features/workers/ui/list_workers.dart';
import 'package:moalidaty1/routes/routes.dart';

void main() => runApp(
  GetMaterialApp(
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
  ),
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ادارة المولدة')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Get.to(() => WorkersListPage());
            },
            child: Text('عرض قائمة المشغلين'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.to(() => SubscripersListPage());
            },
            child: Text('عرض قائمة المشتركين'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.to(() => RecieptsListPage());
            },
            child: Text('عرض قائمة الإيصالات'),
          ),
        ],
      ),
    );
  }
}
