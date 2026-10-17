import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/analytics/analytics_controller.dart';
import 'core/config/env.dart';
import 'core/data/backend.dart';
import 'core/data/data_source.dart';
import 'core/data/secure_session_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/budgets/controllers/budget_controller.dart';
import 'features/receipts/controllers/receipt_controller.dart';
import 'features/subscribers/controllers/subscriber_controller.dart';
import 'features/workers/controllers/worker_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (Env.hasSupabase) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseKey,
      authOptions: FlutterAuthClientOptions(
        // Phones keep the session in the Keystore / Keychain.
        localStorage: _hasSecureStorage ? const SecureSessionStorage() : null,
      ),
    );
  }

  await registerDependencies();
  runApp(const MoalidatnaApp());
}

bool get _hasSecureStorage =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

/// Registers services and controllers (order matters). Tests pass their own
/// [remote] data source or none to run on the demo data.
Future<void> registerDependencies({DataSource? remote, bool demoOnly = false}) async {
  await Get.putAsync(() => ThemeController().init(), permanent: true);
  Get.put(Backend(remote: remote, demoOnly: demoOnly), permanent: true);
  Get.put(SubscriberController(), permanent: true);
  Get.put(BudgetController(), permanent: true);
  Get.put(ReceiptController(), permanent: true);
  Get.put(WorkerController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(AnalyticsController(), permanent: true);
}

class MoalidatnaApp extends StatelessWidget {
  const MoalidatnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    return GetMaterialApp(
      title: 'مولداتنا',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.mode.value,
      locale: const Locale('ar', 'IQ'),
      fallbackLocale: const Locale('ar', 'IQ'),
      supportedLocales: const [Locale('ar', 'IQ')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      textDirection: TextDirection.rtl,
      defaultTransition: Transition.cupertino,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
