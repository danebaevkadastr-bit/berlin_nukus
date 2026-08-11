import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'providers/user_provider.dart';

class AuthNavigation {
  /// Firebase sessiyasini tiklab, rol ni qaytaradi yoki null (login kerak).
  static Future<String?> resolveInitialRole(UserProvider userProvider) async {
    if (kIsWeb) {
      await userProvider.handleGoogleRedirectResult();
    }

    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      try {
        user = await FirebaseAuth.instance
            .authStateChanges()
            .firstWhere((u) => u != null)
            .timeout(const Duration(milliseconds: 1200));
      } catch (_) {
        user = FirebaseAuth.instance.currentUser;
      }
    }
    if (user == null) return null;

    await userProvider.loadUserDataByUid(user.uid);
    return userProvider.role;
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
}
