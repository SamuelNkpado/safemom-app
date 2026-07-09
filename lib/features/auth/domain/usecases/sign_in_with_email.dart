import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Business operation: sign in an existing user with email and password.
///
/// Lightweight validation only — we don't enforce password strength here
/// because that was checked at sign-up. The auth provider decides whether
/// the credentials are actually correct.
class SignInWithEmail {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  /// Executes the sign-in flow.
  ///
  /// Throws [ArgumentError] if inputs are obviously malformed.
  /// Throws [AuthException] if credentials are rejected (wrong password,
  /// unknown email, disabled account, network error).
  Future<User> call({
    required String email,
    required String password,
  }) async {
    // ---------- VALIDATION ----------

    if (email.trim().isEmpty) {
      throw ArgumentError('Please enter your email address.');
    }

    if (!_isValidEmail(email)) {
      throw ArgumentError('Please enter a valid email address.');
    }

    if (password.isEmpty) {
      throw ArgumentError('Please enter your password.');
    }

    // ---------- DELEGATE TO REPOSITORY ----------

    return repository.signInWithEmail(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  bool _isValidEmail(String email) {
    final trimmed = email.trim();
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    return emailRegex.hasMatch(trimmed);
  }
}