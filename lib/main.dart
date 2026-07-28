import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/haptic_service.dart';
import 'services/onesignal_helper.dart'
    if (dart.library.html) 'services/onesignal_helper_web.dart';
import 'firebase_options.dart';
import 'services/darslar_service.dart';
import 'core/providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/theme_manager.dart';
import 'l10n/locale_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: 'env.txt');
  } catch (e) {
    debugPrint('DotenvLoadError: $e');
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // groups ichidagi eski darslarni darslar collectionga ko'chirish
    await DarslarService().migrateLessonsIfNeeded();

    // OneSignal Setup
    await setupOneSignal();

    // Initialize HapticService
    await HapticService.init();
    // Load saved accent color
    await ThemeManager.loadAccent();
  } catch (e) {
    debugPrint('FirebaseInitError: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider.value(value: LocaleManager.currentLocale),
      ],
      child: const AwaDeApp(),
    ),
  );
}

Future<void> setupOneSignal() async {
  // OneSignal web da ishlamaydi (Firebase Messaging kerak)
  if (kIsWeb) return;

  final appId = dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  if (appId.isEmpty || appId == 'YOUR_APP_ID_HERE') {
    debugPrint('OneSignal APP ID is not provided. Notifications disabled.');
    return;
  }

  OneSignalHelper.setup(appId);

  // Set external user id if user is already logged in
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    OneSignalHelper.login(currentUser.uid);
  }
}

class AwaDeApp extends StatelessWidget {
  const AwaDeApp({super.key});

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
              title: 'AwaDe',
              debugShowCheckedModeBanner: false,
              theme: theme,
              builder: (context, child) {
                final content = ThemeSwitchingArea(child: child!);
                if (!kIsWeb) return content;

                // Web: haqiqiy ekran o'lchamini ol
                final screenSize = MediaQuery.of(context).size;
                final isWide = screenSize.width > 500;

                if (!isWide) return content;

                // Keng ekranda: telefon o'lchamiga cheklab, MediaQuery ni ham override qil
                const phoneWidth = 390.0;
                const phoneHeight = 844.0;

                return Scaffold(
                  backgroundColor: const Color(0xFF0f0f1a),
                  body: Center(
                    child: Container(
                      width: phoneWidth,
                      height: phoneHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(44),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 80,
                            spreadRadius: 20,
                          ),
                          BoxShadow(
                            color: const Color(0xFF5C6BC0).withValues(alpha: 0.15),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(43),
                        child: MediaQuery(
                          // Ichki app ni telefon o'lchamida ko'rsin
                          data: MediaQuery.of(context).copyWith(
                            size: const Size(phoneWidth, phoneHeight),
                            padding: const EdgeInsets.only(top: 44, bottom: 34),
                            viewPadding: const EdgeInsets.only(top: 44, bottom: 34),
                            viewInsets: EdgeInsets.zero,
                          ),
                          child: content,
                        ),
                      ),
                    ),
                  ),
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