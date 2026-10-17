import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../controllers/auth_controller.dart';
import 'app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate only once the navigator exists (the old code navigated from
    // AuthController.onInit, which could run before the app was built).
    WidgetsBinding.instance.addPostFrameCallback((_) => Get.find<AuthController>().bootstrap());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: p.heroGradient,
          ),
        ),
        child: SafeArea(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const AppLogo(size: 96),
            const SizedBox(height: 22),
            const Text('مولداتنا',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 6),
            Text('نظام إدارة اشتراكات المولدات',
                style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.85))),
            const SizedBox(height: 56),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
            ),
          ]),
        ),
      ),
    );
  }
}
