import 'package:flutter/material.dart';

/// Supported locales
enum AppLocale {
  uz('uz', 'UZB', "O'zbek", '🇺🇿'),
  kaa('kaa', 'KKR', 'Qaraqalpaq', '🌍'),
  ru('ru', 'RUS', 'Русский', '🇷🇺'),
  de('de', 'DE', 'Deutsch', '🇩🇪');

  final String code;
  final String label;
  final String nativeName;
  final String flag;

  const AppLocale(this.code, this.label, this.nativeName, this.flag);

  static AppLocale fromCode(String code) {
    return AppLocale.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLocale.uz,
    );
  }
}

/// Global language state — ValueNotifier that all widgets can subscribe to.
class LocaleManager {
  static final ValueNotifier<AppLocale> currentLocale =
      ValueNotifier(AppLocale.uz);

  static void setLocale(AppLocale locale) {
    currentLocale.value = locale;
  }

  static String get code => currentLocale.value.code;
}
