import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/app.dart';
import 'package:podo/core/theme/app_theme_controller.dart';

void main() {
  tearDown(() {
    AppThemeController.instance.value = ThemeMode.system;
  });

  testWidgets('PoDoApp builds and provides FTheme and FToaster', (WidgetTester tester) async {
    await tester.pumpWidget(const PoDoApp());
    await tester.pumpAndSettle();

    expect(find.byType(FTheme), findsWidgets);
    expect(find.byType(FToaster), findsOneWidget);
  });

  testWidgets('PoDoApp updates FTheme dynamically when AppThemeController changes', (WidgetTester tester) async {
    AppThemeController.instance.value = ThemeMode.light;
    await tester.pumpWidget(const PoDoApp());
    await tester.pumpAndSettle();

    final fThemeLight = tester.widget<FTheme>(find.byType(FTheme).first);
    expect(fThemeLight.data.colors.brightness, Brightness.light);

    AppThemeController.instance.toggleTheme(true);
    await tester.pumpAndSettle();

    final fThemeDark = tester.widget<FTheme>(find.byType(FTheme).first);
    expect(fThemeDark.data.colors.brightness, Brightness.dark);
  });
}
