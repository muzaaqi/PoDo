import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Semantic token that defines paired background, foreground, border, and card colors
/// for both Light and Dark modes.
class ColorToken {
  final Color background;
  final Color foreground;
  final Color border;
  final Color card;

  const ColorToken({
    required this.background,
    required this.foreground,
    required this.border,
    required this.card,
  });
}

/// Application color palette that provides theme-aware (Light/Dark) playful tokens.
class AppColors {
  final Brightness brightness;

  final ColorToken amber;
  final ColorToken violet;
  final ColorToken emerald;
  final ColorToken sky;
  final ColorToken coral;

  const AppColors._({
    required this.brightness,
    required this.amber,
    required this.violet,
    required this.emerald,
    required this.sky,
    required this.coral,
  });

  bool get isDark => brightness == Brightness.dark;

  static const light = AppColors._(
    brightness: Brightness.light,
    amber: ColorToken(
      background: Color(0xFFFEF3C7),
      foreground: Color(0xFFD97706),
      border: Color(0xFFFDE68A),
      card: Color(0xFFFFFDF5),
    ),
    violet: ColorToken(
      background: Color(0xFFEDE9FE),
      foreground: Color(0xFF7C3AED),
      border: Color(0xFFDDD6FE),
      card: Color(0xFFFAF5FF),
    ),
    emerald: ColorToken(
      background: Color(0xFFD1FAE5),
      foreground: Color(0xFF059669),
      border: Color(0xFFA7F3D0),
      card: Color(0xFFF0FDF4),
    ),
    sky: ColorToken(
      background: Color(0xFFE0F2FE),
      foreground: Color(0xFF0284C7),
      border: Color(0xFFBAE6FD),
      card: Color(0xFFF0F9FF),
    ),
    coral: ColorToken(
      background: Color(0xFFFEE2E2),
      foreground: Color(0xFFDC2626),
      border: Color(0xFFFECACA),
      card: Color(0xFFFFF1F2),
    ),
  );

  static const dark = AppColors._(
    brightness: Brightness.dark,
    amber: ColorToken(
      background: Color(0xFF3B1E08),
      foreground: Color(0xFFFBBF24),
      border: Color(0xFF78350F),
      card: Color(0xFF1C160F),
    ),
    violet: ColorToken(
      background: Color(0xFF26104D),
      foreground: Color(0xFFA78BFA),
      border: Color(0xFF5B21B6),
      card: Color(0xFF171324),
    ),
    emerald: ColorToken(
      background: Color(0xFF063A2D),
      foreground: Color(0xFF34D399),
      border: Color(0xFF065F46),
      card: Color(0xFF0D1D16),
    ),
    sky: ColorToken(
      background: Color(0xFF08263D),
      foreground: Color(0xFF38BDF8),
      border: Color(0xFF0369A1),
      card: Color(0xFF0D1822),
    ),
    coral: ColorToken(
      background: Color(0xFF3D0916),
      foreground: Color(0xFFF87171),
      border: Color(0xFF881337),
      card: Color(0xFF200C12),
    ),
  );

  /// Resolves the playful tokens based on the current theme brightness.
  static AppColors of(BuildContext context) {
    final brightness = context.theme.colors.brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}

/// Extension on [BuildContext] to access [AppColors] ergonomically,
/// similar to Tailwind CSS theme variants.
extension AppColorsExtension on BuildContext {
  AppColors get appColors => AppColors.of(this);
}
