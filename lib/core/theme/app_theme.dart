import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppTheme {
  const AppTheme._();

  static FThemeData get lightTheme => FThemeData(
        touch: true,
        debugLabel: 'PoDo Light Touch',
        colors: FColors.neutralLight.copyWith(
          primary: const Color(0xFF4338CA),
          primaryForeground: const Color(0xFFFFFFFF),
          background: const Color(0xFFF8FAFC),
          card: const Color(0xFFFFFFFF),
          border: const Color(0xFFE2E8F0),
        ),
      );

  static FThemeData get darkTheme => FThemeData(
        touch: true,
        debugLabel: 'PoDo Dark Touch',
        colors: FColors.neutralDark.copyWith(
          primary: const Color(0xFF6366F1),
          primaryForeground: const Color(0xFF0F172A),
          background: const Color(0xFF090A0F),
          card: const Color(0xFF13151D),
          border: const Color(0xFF1E2230),
        ),
      );
}

