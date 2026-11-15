import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:moalidatna/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Runs the whole app on the demo data (no Supabase configured in tests).
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);

  /// Lets page transitions and the demo backend's latency finish (the
  /// spinners never settle, so pumpAndSettle can't be used).
  Future<void> frames(WidgetTester tester, [int n = 10]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  Future<void> boot(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await registerDependencies(demoOnly: true);
    await tester.pumpWidget(const MoalidatnaApp());
    await tester.pump(); // splash → bootstrap
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('starts on the login screen when no session exists', (tester) async {
    await boot(tester);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('مدير المولدة'), findsOneWidget);
  });

  testWidgets('demo manager reaches the dashboard and every tab', (tester) async {
    await boot(tester);
    await tester.tap(find.textContaining('جرّب التطبيق كمدير'));
    await frames(tester);
    expect(find.text('مولدة الكرخ'), findsWidgets);
    expect(find.text('المحصّل'), findsWidgets);
    expect(find.text('آخر الإيصالات'), findsOneWidget);

    await tester.tap(find.text('المشتركون').last);
    await frames(tester, 6);
    expect(find.text('أحمد علي محمد'), findsWidgets);

    await tester.tap(find.text('الإيصالات').last);
    await frames(tester, 6);
    expect(find.text('كل الأشهر'), findsOneWidget);

    await tester.tap(find.text('الميزانيات').last);
    await frames(tester, 6);
    expect(find.text('الميزانيات الشهرية'), findsOneWidget);
  });

  testWidgets('demo worker cannot see manager-only actions', (tester) async {
    await boot(tester);
    await tester.tap(find.text('عامل الجباية'));
    await tester.pump();
    await tester.tap(find.textContaining('جرّب التطبيق كعامل'));
    await frames(tester);
    expect(find.text('خالد محمد الجبوري'), findsWidgets);
    // Workers get "reports" instead of "add budget" in the quick actions.
    expect(find.text('ميزانية'), findsNothing);
    expect(find.text('التقارير'), findsOneWidget);
  });
}
