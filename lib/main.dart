import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/loading_indicator.dart';
import 'package:moalidaty/common_widgets/network_error.dart';
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/constants/global_service_manager.dart';
import 'package:moalidaty/features/Account/controllers/account_controller.dart';
import 'package:moalidaty/features/Account/models/account_model.dart';
import 'package:moalidaty/features/Account/ui/account_login.dart';
import 'package:moalidaty/features/workers/controllers/worker_login_controller.dart';
import 'package:moalidaty/features/workers/models/workers_model.dart';

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
      home: const LoadingScreen(),
      getPages: Routes.pages,
      initialRoute: Routes.home,
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GlobalServiceManager().getUserFromPreference(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: GeneratorLoadingIndicator()),
          );
        } else if (snapshot.hasError) {
          return ErrorDisplayWidget(error: snapshot.error);
        } else if (snapshot.data == null) {
       
          return AccountLoginPage();
        } else if (snapshot.data != null) {
          return HomePage();
        } else {
          return Text("unexpected return type from preference");
        }
      },
    );
  }
}
