import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
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
}
