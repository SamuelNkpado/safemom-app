import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Business operation: sign in using the user's Google account.
///
/// No input validation is needed — the Google Sign-In flow itself
/// handles all credential validation. This use case simply delegates
/// to the repository and optionally applies post-sign-in business rules.
///
/// The repository implementation is responsible for:
/// - Opening the Google Sign-In dialog
/// - Handling the OAuth flow
/// - Creating a Firestore user profile on first sign-in
class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  /// Executes the Google sign-in flow.
  ///
  /// Throws [AuthException] if:
  /// - The user cancels the Google Sign-In dialog
  /// - The device has no network connection
  /// - The Google account is disabled or invalid
  Future<User> call() async {
    return repository.signInWithGoogle();
  }
}