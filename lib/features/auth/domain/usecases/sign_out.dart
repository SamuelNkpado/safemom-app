import '../repositories/auth_repository.dart';

/// Business operation: sign the current user out.
///
/// Clears all cached auth credentials and delegates to the repository.
///
/// The implementation is responsible for:
/// - Clearing Firebase Auth session
/// - Signing out of Google (if signed in via Google)
/// - Clearing any local SharedPreferences tied to the previous user
///   (handled by a separate use case for preferences)
class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  /// Executes the sign-out flow.
  ///
  /// Idempotent — safe to call even if no user is currently signed in.
  /// Throws [AuthException] if sign-out fails at the provider level
  /// (rare — usually only on network errors during token revocation).
  Future<void> call() async {
    return repository.signOut();
  }
}