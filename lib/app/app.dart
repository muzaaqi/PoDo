import 'package:flutter/foundation.dart' show kIsWeb;
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

        Widget content = child ?? const SizedBox.shrink();
        if (kIsWeb) {
          content = Container(
            color: const Color(0xFFF1F5F9),
            alignment: Alignment.center,
            child: ClipRect(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        }

        return FTheme(
          data: theme,
          child: FToaster(
            child: FTooltipGroup(
              child: content,
            ),
          ),
        );
      },
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
