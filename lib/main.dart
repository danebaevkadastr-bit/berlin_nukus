import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/haptic_service.dart';
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
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('DotenvLoadError: $e');
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseService().removeMockData();
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
      child: const BerlinNukusApp(),
    ),
  );
}

Future<void> setupOneSignal() async {
  // Remove this method to stop OneSignal Debugging 
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  final appId = dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  if (appId.isEmpty || appId == 'YOUR_APP_ID_HERE') {
    debugPrint('OneSignal APP ID is not provided. Notifications disabled.');
    return;
  }

  OneSignal.initialize(appId);

  // Prompts the user for push notification permission (iOS / Android 13+)
  OneSignal.Notifications.requestPermission(true);

  // Set external user id if user is already logged in
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    OneSignal.login(currentUser.uid);
  }

  // Handle notification opened
  OneSignal.Notifications.addClickListener((event) {
    debugPrint('NOTIFICATION CLICKED: ${event.notification.additionalData}');
  });
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