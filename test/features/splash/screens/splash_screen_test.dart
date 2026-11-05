import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/splash/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders PoDo logo and branding texts', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => FTheme(
          data: AppTheme.lightTheme,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const SplashScreen(autoNavigate: false),
      ),
    );

    expect(find.text('PoDo'), findsOneWidget);
    expect(find.text('Portal Dosen'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('SplashScreen navigates to login route after duration when autoNavigate is true', (WidgetTester tester) async {
    bool navigatedToLogin = false;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => FTheme(
          data: AppTheme.lightTheme,
          child: child ?? const SizedBox.shrink(),
        ),
        routes: {
          '/': (context) => const SplashScreen(duration: Duration(milliseconds: 1500)),
          AppRoutes.login: (context) {
            navigatedToLogin = true;
            return const Scaffold(body: Text('Login Screen'));
          },
        },
      ),
    );

    expect(navigatedToLogin, isFalse);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(navigatedToLogin, isTrue);
  });
}
