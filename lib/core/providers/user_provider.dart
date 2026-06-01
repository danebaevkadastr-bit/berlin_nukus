import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../services/cloudinary_service.dart';
import '../../services/firebase_service.dart';
import '../../utils/image_picker_helper.dart';

class UserProvider extends ChangeNotifier {
  User? _firebaseUser;
  String _name = 'Mehmon';
  String _email = '';
  String _role = 'student';
  String _phone = '';
  bool _isLoading = false;

  UserProvider() {
    // Listen to Firebase Authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _email = user.email ?? '';
        loadUserDataByUid(user.uid);
      } else {
        _name = 'Mehmon';
        _email = '';
        _role = 'student';
        _phone = '';
        notifyListeners();
      }
    });
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

  /// Fetch user profile details from Cloud Firestore
  Future<void> loadUserDataByUid(String uid) async {
    _isLoading = true;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _name = data['fullName'] ?? data['name'] ?? 'User';
        _role = data['role'] ?? 'student';
        _phone = data['phone'] ?? '';
        _avatarUrl = data['avatarUrl'] ?? '';
      } else {
        _name = _firebaseUser?.displayName ?? 'Foydalanuvchi';
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        OneSignal.login(credential.user!.uid);
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
      OneSignal.login(uid);
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
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Foydalanuvchi bekor qildi
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user!;
      final uid = user.uid;

      // Firestore da profil mavjudligini tekshirish
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) {
        // Yangi foydalanuvchi — Firestore da profil yaratish
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

      // Lokal holatni yangilash
      await loadUserDataByUid(uid);

      // OneSignal ga foydalanuvchini ro'yxatdan o'tkazish
      OneSignal.login(uid);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password by sending a recovery email via Firebase Auth
  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  /// Sign out current active user session
  Future<void> logout() async {
    // OneSignal dan chiqish (boshqa foydalanuvchiga notification ketmasligi uchun)
    OneSignal.logout();
    // Google Sign-In dan ham chiqish
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
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
