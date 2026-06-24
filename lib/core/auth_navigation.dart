import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../screens/admin/admin_main_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/student/student_home_screen.dart';
import '../screens/teacher/teacher_main_screen.dart';
import 'providers/user_provider.dart';

class AuthNavigation {
  static Widget homeScreenForRole(String role) {
    switch (role) {
      case 'admin':
        return const AdminMainScreen();
      case 'teacher':
        return const TeacherMainScreen();
      default:
        return const StudentHomeScreen();
    }
  }

  /// Firebase sessiyasini tiklab, mos bosh ekranni qaytaradi yoki null (login kerak).
  static Future<Widget?> resolveInitialScreen(UserProvider userProvider) async {
    if (kIsWeb) {
      await userProvider.handleGoogleRedirectResult();
    }

    await FirebaseAuth.instance.authStateChanges().first;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    await userProvider.loadUserDataByUid(user.uid);
    return homeScreenForRole(userProvider.role);
  }

  static void replaceWith(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  static void replaceWithLogin(BuildContext context) {
    replaceWith(context, const LoginScreen());
  }
}
