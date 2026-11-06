import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Semantic token that defines paired solid background and crisp foreground
/// for authentic, borderless opaque pastel surfaces in both Light and Dark modes.
class ColorToken {
  final Color background;
  final Color foreground;

  const ColorToken({
    required this.background,
    required this.foreground,
  });
}

/// Application color palette providing authentic, solid matte pastel tokens.
/// Adapts cleanly between Light and Dark mode without borders, opacity, or transparency.
class AppColors {
  final Brightness brightness;

  final Color brandPrimary;
  final Color brandPrimaryForeground;
  final Color canvas;

  final ColorToken indigo;
  final ColorToken amber;
  final ColorToken violet;
  final ColorToken emerald;
  final ColorToken sky;
  final ColorToken coral;

  const AppColors._({
    required this.brightness,
    required this.brandPrimary,
    required this.brandPrimaryForeground,
    required this.canvas,
    required this.indigo,
    required this.amber,
    required this.violet,
    required this.emerald,
    required this.sky,
    required this.coral,
  });

  bool get isDark => brightness == Brightness.dark;

  static const light = AppColors._(
    brightness: Brightness.light,
    brandPrimary: Color(0xFF4338CA),
    brandPrimaryForeground: Color(0xFFFFFFFF),
    canvas: Color(0xFFF8FAFC),
    indigo: ColorToken(
      background: Color(0xFFC7D2FE),
      foreground: Color(0xFF18181B),
    ),
    amber: ColorToken(
      background: Color(0xFFFDE68A),
      foreground: Color(0xFF18181B),
    ),
    violet: ColorToken(
      background: Color(0xFFDDD6FE),
      foreground: Color(0xFF18181B),
    ),
    emerald: ColorToken(
      background: Color(0xFFA7F3D0),
      foreground: Color(0xFF18181B),
    ),
    sky: ColorToken(
      background: Color(0xFFBAE6FD),
      foreground: Color(0xFF18181B),
    ),
    coral: ColorToken(
      background: Color(0xFFFECDD3),
      foreground: Color(0xFF18181B),
    ),
  );

  static const dark = AppColors._(
    brightness: Brightness.dark,
    brandPrimary: Color(0xFF6366F1),
    brandPrimaryForeground: Color(0xFF0F172A),
    canvas: Color(0xFF090A0F),
    indigo: ColorToken(
      background: Color(0xFF23254B),
      foreground: Color(0xFFC7D2FE),
    ),
    amber: ColorToken(
      background: Color(0xFF382C14),
      foreground: Color(0xFFFDE68A),
    ),
    violet: ColorToken(
      background: Color(0xFF2E2442),
      foreground: Color(0xFFDDD6FE),
    ),
    emerald: ColorToken(
      background: Color(0xFF1B382B),
      foreground: Color(0xFFA7F3D0),
    ),
    sky: ColorToken(
      background: Color(0xFF193247),
      foreground: Color(0xFFBAE6FD),
    ),
    coral: ColorToken(
      background: Color(0xFF3B1E26),
      foreground: Color(0xFFFECDD3),
    ),
  );

  /// Resolves the pastel tokens based on the current theme brightness.
  static AppColors of(BuildContext context) {
    final brightness = context.theme.colors.brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}

/// Extension on [BuildContext] for clean access to [AppColors].
extension AppColorsExtension on BuildContext {
  AppColors get appColors => AppColors.of(this);
}
