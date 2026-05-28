import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

// ── Accent color presets ──────────────────────────────────────────────────────

class AccentPreset {
  final String id;
  final String nameUz;
  final Color color;
  final Color shadow;

  const AccentPreset({
    required this.id,
    required this.nameUz,
    required this.color,
    required this.shadow,
  });
}

const List<AccentPreset> accentPresets = [
  AccentPreset(id: 'green',  nameUz: 'Yashil',     color: AppColors.duoGreen,  shadow: AppColors.duoGreenShadow),
  AccentPreset(id: 'blue',   nameUz: 'Ko\'k',       color: AppColors.duoBlue,   shadow: AppColors.duoBlueShadow),
  AccentPreset(id: 'orange', nameUz: 'To\'q sariq', color: AppColors.duoOrange, shadow: AppColors.duoOrangeShadow),
  AccentPreset(id: 'purple', nameUz: 'Binafsha',    color: AppColors.duoPurple, shadow: AppColors.duoPurpleShadow),
  AccentPreset(id: 'red',    nameUz: 'Qizil',       color: AppColors.duoRed,    shadow: AppColors.duoRedShadow),
];

// ── ThemeManager ──────────────────────────────────────────────────────────────

/// Global theme state — ValueNotifier that all widgets can subscribe to.
class ThemeManager {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.light);

  // Accent color notifier — default green
  static final ValueNotifier<AccentPreset> accentNotifier =
      ValueNotifier(accentPresets.first);

  static bool get isDark => themeMode.value == ThemeMode.dark;

  /// Current accent color (shorthand)
  static Color get accent => accentNotifier.value.color;

  /// Current accent shadow (shorthand)
  static Color get accentShadow => accentNotifier.value.shadow;

  // ── Persistence ────────────────────────────────────────────────────────────

  static const _accentKey = 'accent_preset_id';

  static Future<void> loadAccent() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_accentKey) ?? 'green';
    final preset = accentPresets.firstWhere(
      (p) => p.id == id,
      orElse: () => accentPresets.first,
    );
    accentNotifier.value = preset;
  }

  static Future<void> setAccent(AccentPreset preset) async {
    accentNotifier.value = preset;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accentKey, preset.id);
  }

  // ── Theme toggle ───────────────────────────────────────────────────────────

  static void toggleTheme(bool isDarkMode) {
    themeMode.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.outfitTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.skyBlue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF0F4FF),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.outfitTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.skyBlue,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
  );

  // ── Adaptive colors ────────────────────────────────────────────────────────

  static Color scaffoldBg(BuildContext context) {
    final bright = Theme.of(context).brightness;
    return bright == Brightness.dark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF0F4FF);
  }

  static Color cardColor(BuildContext context) {
    final bright = Theme.of(context).brightness;
    return bright == Brightness.dark ? const Color(0xFF1E293B) : Colors.white;
  }

  static Color textColor(BuildContext context) {
    final bright = Theme.of(context).brightness;
    return bright == Brightness.dark
        ? Colors.white
        : const Color(0xFF2D3142);
  }

  static Color subTextColor(BuildContext context) {
    final bright = Theme.of(context).brightness;
    return bright == Brightness.dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF9E9E9E);
  }

  static Color iconBgColor(BuildContext context, Color lightColor) {
    final bright = Theme.of(context).brightness;
    return bright == Brightness.dark
        ? const Color(0xFF334155)
        : lightColor;
  }

  static List<BoxShadow> cardShadow(BuildContext context,
      [Color? lightShadowColor]) {
    final bright = Theme.of(context).brightness;
    if (bright == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 12,
          offset: const Offset(2, 4),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: lightShadowColor ??
              const Color(0xFF5C6BC0).withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(3, 6),
        ),
      ];
    }
  }
}
