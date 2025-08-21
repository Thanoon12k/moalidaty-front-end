import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moalidaty1/common_widgets/appbar.dart';

void main() {
  group('AppBar Widget Tests', () {
    testWidgets('should render appbar with title', (WidgetTester tester) async {
      // Arrange
      const title = 'Test App Bar';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: title),
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should render appbar with default title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(),
          ),
        ),
      );

      // Assert
      expect(find.text('ادارة المولدة'), findsOneWidget);
    });

    testWidgets('should have correct styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: 'Styled App Bar'),
          ),
        ),
      );

      // Assert
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, isNotNull);
      expect(appBar.elevation, isNotNull);
      expect(appBar.centerTitle, isTrue);
    });

    testWidgets('should handle long title text', (WidgetTester tester) async {
      // Arrange
      const longTitle = 'This is a very long title that might overflow the app bar width and should be handled gracefully';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: longTitle),
          ),
        ),
      );

      // Assert
      expect(find.text(longTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle empty title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: ''),
          ),
        ),
      );

      // Assert
      expect(find.text(''), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle special characters in title', (WidgetTester tester) async {
      // Arrange
      const specialTitle = 'Title with special chars: !@#\$%^&*()_+-=[]{}|;:,.<>?';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: specialTitle),
          ),
        ),
      );

      // Assert
      expect(find.text(specialTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle Arabic text in title', (WidgetTester tester) async {
      // Arrange
      const arabicTitle = 'عنوان باللغة العربية';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: arabicTitle),
          ),
        ),
      );

      // Assert
      expect(find.text(arabicTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle numeric title', (WidgetTester tester) async {
      // Arrange
      const numericTitle = '12345';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: numericTitle),
          ),
        ),
      );

      // Assert
      expect(find.text(numericTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle mixed content title', (WidgetTester tester) async {
      // Arrange
      const mixedTitle = 'Mixed: 123 + Arabic العربية + Special !@#';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: mixedTitle),
          ),
        ),
      );

      // Assert
      expect(find.text(mixedTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should maintain app bar height', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(title: 'Height Test'),
          ),
        ),
      );

      // Assert
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.toolbarHeight, isNotNull);
      expect(appBar.toolbarHeight, greaterThan(0));
    });

    testWidgets('should handle theme changes', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            appBar: CustomAppBar(title: 'Theme Test'),
          ),
        ),
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Theme Test'), findsOneWidget);
    });
  });
}
