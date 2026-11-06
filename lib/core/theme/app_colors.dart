import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Semantic token that defines paired background, foreground, and card colors
/// for soft matte pastel surfaces in both Light and Dark modes.
class ColorToken {
  final Color background;
  final Color foreground;
  final Color card;

  const ColorToken({
    required this.background,
    required this.foreground,
    required this.card,
  });
}

/// Application color palette providing quiet, authentic matte pastel tokens.
/// Adapts cleanly between Light and Dark mode without neon or opacity artifacts.
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
      foreground: Color(0xFF92400E),
      card: Color(0xFFFFFDF5),
    ),
    violet: ColorToken(
      background: Color(0xFFEDE9FE),
      foreground: Color(0xFF5B21B6),
      card: Color(0xFFFAF5FF),
    ),
    emerald: ColorToken(
      background: Color(0xFFDCFCE7),
      foreground: Color(0xFF166534),
      card: Color(0xFFF0FDF4),
    ),
    sky: ColorToken(
      background: Color(0xFFE0F2FE),
      foreground: Color(0xFF075985),
      card: Color(0xFFF0F9FF),
    ),
    coral: ColorToken(
      background: Color(0xFFFFE4E6),
      foreground: Color(0xFF9F1239),
      card: Color(0xFFFFF1F2),
    ),
  );

  static const dark = AppColors._(
    brightness: Brightness.dark,
    amber: ColorToken(
      background: Color(0xFF2E2417),
      foreground: Color(0xFFFDE68A),
      card: Color(0xFF1F1B14),
    ),
    violet: ColorToken(
      background: Color(0xFF251E33),
      foreground: Color(0xFFDDD6FE),
      card: Color(0xFF1A1624),
    ),
    emerald: ColorToken(
      background: Color(0xFF182A22),
      foreground: Color(0xFFA7F3D0),
      card: Color(0xFF14211B),
    ),
    sky: ColorToken(
      background: Color(0xFF162432),
      foreground: Color(0xFFBAE6FD),
      card: Color(0xFF121B24),
    ),
    coral: ColorToken(
      background: Color(0xFF30181E),
      foreground: Color(0xFFFECDD3),
      card: Color(0xFF221317),
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
