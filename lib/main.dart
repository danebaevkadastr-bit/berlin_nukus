import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/darslar_service.dart';
import 'core/providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/theme_manager.dart';
import 'l10n/locale_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Seed initial mock data if database is empty
    await FirebaseService().seedInitialData();
    // groups ichidagi eski darslarni darslar collectionga ko'chirish
    await DarslarService().migrateLessonsIfNeeded();
  } catch (e) {
    debugPrint('FirebaseInitError: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider.value(value: LocaleManager.currentLocale),
      ],
      child: const BerlinNukusApp(),
    ),
  );
}

class BerlinNukusApp extends StatelessWidget {
  const BerlinNukusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild entire app when locale changes
    return ValueListenableBuilder<AppLocale>(
      valueListenable: LocaleManager.currentLocale,
      builder: (context, _, __) {
        return ThemeProvider(
          initTheme: ThemeManager.themeMode.value == ThemeMode.dark
              ? ThemeManager.darkTheme
              : ThemeManager.lightTheme,
          builder: (context, theme) {
            return MaterialApp(
              title: 'Berlin-Nukus',
              debugShowCheckedModeBanner: false,
              theme: theme,
              builder: (context, child) {
                return ThemeSwitchingArea(
                  child: child!,
                );
              },
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}