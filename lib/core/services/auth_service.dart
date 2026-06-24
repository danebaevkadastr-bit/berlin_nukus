import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/onesignal_helper.dart'
    if (dart.library.html) '../../services/onesignal_helper_web.dart';

class AuthService {
  /// To'liq chiqish: OneSignal, Google Sign-In va Firebase Auth sessiyalarini
  /// tozalaydi. Admin/o'qituvchi ekranlari ham shu metoddan foydalanadi,
  /// shuning uchun talaba (UserProvider.logout) bilan bir xil to'liq tozalash.
  Future<void> signOut() async {
    // OneSignal'dan chiqish — boshqa foydalanuvchiga notification ketmasligi uchun
    OneSignalHelper.logout();

    // Google Sign-In sessiyasini ham tozalash (web'da kerak emas)
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {
        // Google bilan kirilmagan bo'lsa — e'tiborsiz qoldiramiz
      }
    }

    await FirebaseAuth.instance.signOut();
  }
}
