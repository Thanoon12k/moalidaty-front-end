import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/list_generators.dart';
import 'package:moalidaty/common_widgets/loading_indicator.dart';
import 'package:moalidaty/common_widgets/network_error.dart';
import 'package:moalidaty/constants/global_service_manager.dart';
import 'package:moalidaty/features/Managers/ui/login.dart';
import 'package:moalidaty/features/budgets/services/budget_service.dart';
import 'package:moalidaty/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty/features/workers/controllers/worker_controller.dart';
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
    return LoginPage(); // TODO remove this  lineafter finish development
    return FutureBuilder(
      future: GlobalServiceManager().initAllServices().timeout(const Duration(seconds: 10)),
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


