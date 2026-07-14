import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

/// Concrete implementation of [AuthRepository] backed by Firebase.
///
/// This class:
/// - Delegates work to the Firebase datasource
/// - Converts Firebase-specific exceptions into our domain [AuthException]
/// - Ensures the domain layer never sees a Firebase type
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  // ---------- CURRENT USER ----------

  @override
  User? get currentUser {
    // We can't do an async fetch in a getter, so we return null when no
    // profile is cached. The auth state stream is the reliable source
    // of truth for the presentation layer.
    return null;
  }

  @override
  Stream<User?> get authStateChanges async* {
    await for (final firebaseUser in _datasource.authStateChanges) {
      if (firebaseUser == null) {
        yield null;
      } else {
        try {
          yield await _datasource.fetchCurrentUserProfile();
        } on fb.FirebaseException catch (e) {
          throw _translateException(e);
        }
      }
    }
  }

  // ---------- SIGN UP ----------

  @override
  Future<User> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required DateTime dueDate,
  }) async {
    try {
      return await _datasource.signUpWithEmail(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        dueDate: dueDate,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- SIGN IN (EMAIL) ----------

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _datasource.signInWithEmail(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- SIGN IN (GOOGLE) ----------

  @override
  Future<User> signInWithGoogle() async {
    try {
      return await _datasource.signInWithGoogle();
    } on fb.FirebaseAuthException catch (e) {
      throw _translateException(e);
    } catch (e) {
      // Google Sign-In can throw its own error types; map anything
      // else to a generic auth error rather than leaking the raw type.
      throw AuthException(
        'Google sign-in failed. Please try again.',
        code: 'google-signin-failed',
      );
    }
  }

  // ---------- EMAIL VERIFICATION & PASSWORD RESET ----------

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _datasource.sendEmailVerification();
    } on fb.FirebaseAuthException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _datasource.resetPassword(email);
    } on fb.FirebaseAuthException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- SIGN OUT ----------

  @override
  Future<void> signOut() async {
    try {
      await _datasource.signOut();
    } on fb.FirebaseAuthException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- ACCOUNT DELETION ----------

  @override
  Future<void> deleteAccount() async {
    try {
      await _datasource.deleteAccount();
    } on fb.FirebaseAuthException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- ERROR TRANSLATION ----------

  /// Convert Firebase error codes into user-friendly messages.
  ///
  /// Firebase codes are useful for debugging but the raw text is
  /// developer-facing. The presentation layer displays [AuthException.message]
  /// verbatim to the user, so it must sound natural.
  AuthException _translateException(fb.FirebaseException e) {
    final code = e.code;
    switch (code) {
      case 'email-already-in-use':
        return const AuthException(
          'An account already exists for this email. Try signing in instead.',
          code: 'email-already-in-use',
        );
      case 'invalid-email':
        return const AuthException(
          'That does not look like a valid email address.',
          code: 'invalid-email',
        );
      case 'weak-password':
        return const AuthException(
          'That password is too weak. Please choose a stronger one.',
          code: 'weak-password',
        );
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthException(
          'Email or password is incorrect. Please try again.',
          code: 'invalid-credentials',
        );
      case 'user-disabled':
        return const AuthException(
          'This account has been disabled. Contact support for help.',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthException(
          'Too many attempts. Please wait a moment before trying again.',
          code: 'too-many-requests',
        );
      case 'network-request-failed':
        return const AuthException(
          'No internet connection. Please check your network and try again.',
          code: 'network-error',
        );
      case 'operation-not-allowed':
        return const AuthException(
          'This sign-in method is not enabled. Please contact support.',
          code: 'method-disabled',
        );
      case 'requires-recent-login':
        return const AuthException(
          'For security, please sign in again before making this change.',
          code: 'requires-recent-login',
        );
      case 'profile-missing':
        return const AuthException(
          'Your account is set up but your profile is missing. '
              'Please contact support.',
          code: 'profile-missing',
        );
      default:
        return AuthException(
          e.message ?? 'Something went wrong. Please try again.',
          code: code,
        );
    }
  }
}