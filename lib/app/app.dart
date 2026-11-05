import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/theme/app_theme.dart';

class PoDoApp extends StatelessWidget {
  final String initialRoute;

  const PoDoApp({
    super.key,
    this.initialRoute = AppRoutes.splash,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoDo',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      builder: (context, child) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        final theme = brightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;

        return FTheme(
          data: theme,
          child: FToaster(
            child: FTooltipGroup(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
