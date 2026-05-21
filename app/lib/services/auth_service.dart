import 'dart:async';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  bool isSignedIn = false;

  Future<void> init() async {
    // Initialize real services here (prefs, secure storage, backend clients)
    await Future<void>.delayed(const Duration(milliseconds: 250));
    // For now assume signed out.
    isSignedIn = false;
  }

  Future<void> signIn() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    isSignedIn = true;
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    isSignedIn = false;
  }
}
