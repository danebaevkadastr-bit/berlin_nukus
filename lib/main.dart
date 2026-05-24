import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    // Firebase Messaging setup
    await setupFirebaseMessaging();
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

Future<void> setupFirebaseMessaging() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request notification permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  debugPrint('Notification permission: ${settings.authorizationStatus}');

  // Create notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel',
    'Default Channel',
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

  final InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('Notification response: ${response.payload}');
    },
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Get FCM token
  final token = await messaging.getToken();
  debugPrint('FCM Token: $token');

  // Save token to Firestore
  await saveFcmTokenToFirestore(token);

  // Listen for token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    debugPrint('FCM Token refreshed: $newToken');
    saveFcmTokenToFirestore(newToken);
  });

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint('Message also contained a notification: ${message.notification}');

      flutterLocalNotificationsPlugin.show(
        id: message.notification.hashCode,
        title: message.notification?.title,
        body: message.notification?.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            importance: Importance.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });

  // Background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
}

Future<void> saveFcmTokenToFirestore(String? token) async {
  if (token == null) return;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'fcmToken': token});
    debugPrint('FCM token saved to Firestore for user: ${user.uid}');
  } catch (e) {
    debugPrint('Error saving FCM token to Firestore: $e');
  }
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