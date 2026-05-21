import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        _name = data['fullName'] ?? data['name'] ?? 'Talaba';
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

  /// Sign in with Firebase Auth and handle fallback auto-registration for pre-existing mock accounts
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Auto-register pre-existing mock accounts in Firebase Auth on first login attempt to ensure
      // convenience credentials continue to work out-of-the-box on Firebase.
      final isMockAccount = (email == 'admin@mail.com' || email == 'teacher@mail.com' || email == 'student@mail.com') && password == '123456';
      
      if (isMockAccount) {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
            // Register this mock account in Firebase Auth
            final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
            final uid = userCredential.user!.uid;

            // Generate user fields depending on the mock role
            String mockName = 'Talaba (Student)';
            String mockRole = 'student';
            String mockPhone = '+998991112255';

            if (email == 'admin@mail.com') {
              mockName = 'Admin (Musa)';
              mockRole = 'admin';
              mockPhone = '+998991112233';
            } else if (email == 'teacher@mail.com') {
              mockName = 'O\'qituvchi (Teacher)';
              mockRole = 'teacher';
              mockPhone = '+998991112244';
            }

            // Save user document in Cloud Firestore
            await FirebaseFirestore.instance.collection('users').doc(uid).set({
              'uid': uid,
              'fullName': mockName,
              'email': email,
              'phone': mockPhone,
              'role': mockRole,
              'createdAt': FieldValue.serverTimestamp(),
            });

            // Trigger sign in after creation
            await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          } else {
            rethrow;
          }
        }
      } else {
        // Standard user authentication
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
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
