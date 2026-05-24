import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Private constructor for Singleton pattern
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  // Firebase Dependencies
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Expose the current Firebase Auth user object directly
  User? get currentUser => _auth.currentUser;

  /// Missing Getter 1 (For main.dart): Checks if a session token is active
  bool get isSignedIn => _auth.currentUser != null;

  /// Missing Method 2 (For main.dart): Empty init hook if your router configuration demands it
  Future<void> init() async {
    // Left empty intentionally to satisfy main.dart configuration calls safely
  }

  /// 1. SIGN UP METHOD
  /// Creates an auth credential and initializes the user's Firestore profile document
  Future<UserCredential> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // Create authentication record
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      // Sync display name with Firebase Auth Core profile
      await credential.user!.updateDisplayName(fullName);

      // Trigger email verification
      await credential.user!.sendEmailVerification();

      // Create user profile inside your Cloud Firestore database
      await _db.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'displayName': fullName,
        'email': email,
        'recipeCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  /// 2. SEND EMAIL VERIFICATION
  /// Triggers a verification email hyperlink dispatch to the freshly registered user account
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Missing Method 3 (For forgot_password.dart): Triggers official Firebase transactional reset link
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Missing Method 4 (For profile_screen.dart): Fetches target map document from Cloud Firestore
  Future<Map<String, dynamic>?> currentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data();
  }

  /// Wrapper for signIn calling signInWithEmailOrUsername
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return signInWithEmailOrUsername(identifier: email, password: password);
  }

  /// 5. SIGN IN WITH EMAIL OR USERNAME
  /// Handles user login verification checks dynamically
  Future<UserCredential> signInWithEmailOrUsername({
    required String identifier,
    required String password,
  }) async {
    String email = identifier.trim();

    // If identifier doesn't look like an email, lookup user by username in Firestore
    if (!email.contains('@')) {
      final querySnapshot = await _db
          .collection('users')
          .where('displayName', isEqualTo: identifier)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user account discovered matching that username.',
        );
      }
      email = querySnapshot.docs.first.get('email');
    }

    // Process actual sign-in check
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Note: Verification check on login is relaxed per request.
    // Users can log in without verification. Verification is still done on sign up.

    return credential;
  }

  /// 6. UPDATE USER PROFILE
  /// Changes user security metrics and updates the database entry counters safely
  Future<void> updateProfile({
    String? displayName,
    String? email,
    String? password,
    String? avatar,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user session active.');

    Map<String, dynamic> updates = {'updatedAt': FieldValue.serverTimestamp()};

    if (password != null && password.isNotEmpty) {
      await user.updatePassword(password);
    }

    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
      updates['displayName'] = displayName;
    }

    if (email != null && email.isNotEmpty) {
      await user.verifyBeforeUpdateEmail(email);
      updates['email'] = email;
    }

    if (avatar != null && avatar.isNotEmpty) {
      updates['avatar'] = avatar;
    }

    if (updates.length > 1) {
      await _db.collection('users').doc(user.uid).update(updates);
    }
  }

  /// 7. SIGN OUT METHOD
  /// Completely clears active token instances off the user context environment
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
