import '../entities/user.dart';

/// Contract for authentication operations.
///
/// The data layer will implement this using Firebase Authentication.
/// The domain layer only cares about the interface — not the implementation.
///
/// This abstraction allows us to swap Firebase for a different auth
/// provider in the future without changing any business logic.
abstract class AuthRepository {
  /// Currently signed-in user, or null if no session is active.
  User? get currentUser;

  /// Stream that emits the current user whenever auth state changes
  /// (sign in, sign out, token refresh).
  Stream<User?> get authStateChanges;

  /// Create a new account with email and password.
  ///
  /// Throws [AuthException] on failure.
  Future<User> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required DateTime dueDate,
  });

  /// Sign in an existing user with email and password.
  ///
  /// Throws [AuthException] on failure.
  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in using the user's Google account.
  ///
  /// If it's the user's first time, a profile is created with default
  /// fields the app can complete during onboarding.
  ///
  /// Throws [AuthException] on failure.
  Future<User> signInWithGoogle();

  /// Send a verification email to the currently signed-in user.
  Future<void> sendEmailVerification();

  /// Send a password reset link to the given email address.
  ///
  /// Throws [AuthException] if the email is not registered.
  Future<void> resetPassword(String email);

  /// Sign the current user out and clear all cached credentials.
  Future<void> signOut();

  /// Permanently delete the current user's account.
  ///
  /// Note: this only deletes the auth record. Firestore documents owned
  /// by the user are handled by a separate account-deletion use case.
  Future<void> deleteAccount();
}

/// Base exception for auth failures.
///
/// The implementation layer converts Firebase-specific error codes into
/// user-friendly messages via subclasses of this exception.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException($code): $message';
}