import 'package:flutter/material.dart';

/// Supported locales
enum AppLocale {
  uz('uz', 'UZB', "O'zbek", null, '🇺🇿'),
  kaa('kaa', 'KKR', 'Qaraqalpaq', 'assets/images/image.png', null),
  ru('ru', 'RUS', 'Русский', null, '🇷🇺'),
  de('de', 'DE', 'Deutsch', null, '🇩🇪');

  final String code;
  final String label;
  final String nativeName;
  final String? imagePath;
  final String? flagEmoji;

  const AppLocale(this.code, this.label, this.nativeName, this.imagePath, this.flagEmoji);

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
