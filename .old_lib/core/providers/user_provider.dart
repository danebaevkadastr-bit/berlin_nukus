import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/cloudinary_service.dart';
import '../../services/firebase_service.dart';
import '../../services/onesignal_helper.dart'
    if (dart.library.html) '../../services/onesignal_helper_web.dart';
import '../../utils/image_picker_helper.dart';

class UserProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  User? _firebaseUser;
  String _name = 'Mehmon';
  String _email = '';
  String _role = 'student';
  String _phone = '';
  bool _isLoading = false;
  StreamSubscription<DocumentSnapshot>? _userDocSub;

  UserProvider() {
    // Listen to Firebase Authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _email = user.email ?? '';
        loadUserDataByUid(user.uid);
      } else {
        _userDocSub?.cancel();
        _userDocSub = null;
        _name = 'Mehmon';
        _email = '';
        _role = 'student';
        _phone = '';
        _avatarUrl = '';
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _userDocSub?.cancel();
    super.dispose();
  }

  // Getters
  User? get firebaseUser => _firebaseUser;
  String get name => _name;
  String get email => _email;
  String get role => _role;
  String get phone => _phone;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  String get avatarUrl => _avatarUrl;
  String get uid => _firebaseUser?.uid ?? '';
  String _avatarUrl = '';

  /// Real-time stream orqali foydalanuvchi profilini va rolini yuklash hamda kuzatish
  Future<void> loadUserDataByUid(String uid) async {
    _isLoading = true;
    _userDocSub?.cancel();

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        _name = data['fullName'] ?? data['name'] ?? _firebaseUser?.displayName ?? 'User';
        _role = (data['role'] as String?)?.toLowerCase().trim() ?? 'student';
        _phone = data['phone'] ?? '';
        _avatarUrl = data['avatarUrl'] ?? '';
      } else {
        _name = _firebaseUser?.displayName ?? 'Foydalanuvchi';
        _role = 'student';
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Keyingi jonli o'zgarishlar uchun stream tinglovchisini ulaymiz
    _userDocSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data() ?? {};
        _name = data['fullName'] ?? data['name'] ?? _firebaseUser?.displayName ?? 'User';
        _role = (data['role'] as String?)?.toLowerCase().trim() ?? 'student';
        _phone = data['phone'] ?? '';
        _avatarUrl = data['avatarUrl'] ?? '';
        notifyListeners();
      }
    }, onError: (e) {
      debugPrint('Error listening to user profile: $e');
    });
  }

  /// Profil rasmini Cloudinary ga yuklab Firestore va lokal holatni yangilaydi.
  Future<String?> pickAndUploadAvatar(BuildContext context) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return null;

    final picked = await ImagePickerHelper.pickImage(context);
    if (picked == null) return null;

    _isLoading = true;
    notifyListeners();
    try {
      // Eski keshni tozalash
      if (_avatarUrl.isNotEmpty) {
        try {
          await CachedNetworkImage.evictFromCache(_avatarUrl);
        } catch (_) {}
      }
      final url = await CloudinaryService.uploadXFile(
        file: picked,
        folder: 'profiles/$uid',
      );
      await FirebaseService().updateUserProfile(uid, avatarUrl: url);
      _avatarUrl = url;
      notifyListeners();
      return url;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update profile (fullName, phone) in Firestore and refresh local state
  Future<void> updateProfile({String? fullName, String? phone}) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return;
    final updates = <String, dynamic>{};
    if (fullName != null && fullName.isNotEmpty) updates['fullName'] = fullName;
    if (phone != null && phone.isNotEmpty) updates['phone'] = phone;
    if (updates.isEmpty) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update(updates);
    if (fullName != null && fullName.isNotEmpty) _name = fullName;
    if (phone != null && phone.isNotEmpty) _phone = phone;
    notifyListeners();
  }

  /// Sign in with Firebase Auth.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // OneSignal ga foydalanuvchini ro'yxatdan o'tkazish (background notification uchun)
      if (credential.user != null) {
        OneSignalHelper.login(credential.user!.uid);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user in Firebase Auth and create their Firestore user profile document
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String role = 'student',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      // Update basic display name in Firebase Auth
      await userCredential.user!.updateDisplayName(fullName);

      // Create new profile record in Cloud Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _name = fullName;
      _email = email;
      _role = role;
      _phone = phone;
      
      // OneSignal ga foydalanuvchini ro'yxatdan o'tkazish (background notification uchun)
      OneSignalHelper.login(uid);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Google orqali kirish
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final UserCredential userCredential;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        try {
          userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        } on FirebaseAuthException catch (e) {
          final code = e.code.replaceFirst('auth/', '');
          if (code == 'popup-blocked' || code == 'cancelled-popup-request') {
            await FirebaseAuth.instance.signInWithRedirect(googleProvider);
            return;
          }
          rethrow;
        }
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return;
        }

        final googleAuth = await googleUser.authentication;
        if (googleAuth.idToken == null) {
          throw FirebaseAuthException(
            code: 'invalid-credential',
            message: 'Google idToken olinmadi. Firebase Console da SHA-1 qo\'shilganini tekshiring.',
          );
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user!;
      final uid = user.uid;
      _firebaseUser = user;
      _email = user.email ?? '';

      // Firestore da profil mavjudligini tekshirish
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'fullName': user.displayName ?? 'Foydalanuvchi',
          'email': user.email ?? '',
          'phone': '',
          'role': 'student',
          'avatarUrl': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await loadUserDataByUid(uid);
      OneSignalHelper.login(uid);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Web redirect orqali Google kirish natijasini qayta ishlash.
  Future<bool> handleGoogleRedirectResult() async {
    if (!kIsWeb) return false;

    try {
      final result = await FirebaseAuth.instance.getRedirectResult();
      final user = result.user;
      if (user == null) return false;

      _firebaseUser = user;
      _email = user.email ?? '';
      final uid = user.uid;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'fullName': user.displayName ?? 'Foydalanuvchi',
          'email': user.email ?? '',
          'phone': '',
          'role': 'student',
          'avatarUrl': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await loadUserDataByUid(uid);
      OneSignalHelper.login(uid);
      return true;
    } catch (e) {
      debugPrint('Google redirect result error: $e');
      return false;
    }
  }

  /// Reset password by sending a recovery email via Firebase Auth
  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  /// Sign out current active user session
  Future<void> logout() async {
    OneSignalHelper.logout();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await FirebaseAuth.instance.signOut();
    _firebaseUser = null;
    _name = 'Mehmon';
    _email = '';
    _role = 'student';
    _phone = '';
    _avatarUrl = '';
    notifyListeners();
  }

  // Kept for backwards compatibility with other screens
  void updateUserData(String newName, String newEmail) {
    _name = newName;
    _email = newEmail;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    if (_firebaseUser != null) {
      await loadUserDataByUid(_firebaseUser!.uid);
    }
  }
}
