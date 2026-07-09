import '../repositories/auth_repository.dart';

/// Business operation: send a password reset email to the given address.
///
/// The auth provider sends a reset link the user clicks to set a new
/// password. Nothing about the reset flow is handled inside the app —
/// the user completes it via the email link and then signs in normally.
class ResetPassword {
  final AuthRepository repository;

  ResetPassword(this.repository);

  /// Executes the password reset flow.
  ///
  /// Throws [ArgumentError] if the email is empty or malformed.
  /// Throws [AuthException] if the auth provider rejects the request
  /// (e.g. no account with that email, network error).
  ///
  /// Note: for privacy reasons the implementation may silently succeed
  /// even when the email is not registered. That's a decision made in
  /// the data layer, not here.
  Future<void> call({required String email}) async {
    // ---------- VALIDATION ----------

    if (email.trim().isEmpty) {
      throw ArgumentError('Please enter your email address.');
    }

    if (!_isValidEmail(email)) {
      throw ArgumentError('Please enter a valid email address.');
    }

    // ---------- DELEGATE TO REPOSITORY ----------

    return repository.resetPassword(email.trim().toLowerCase());
  }

  bool _isValidEmail(String email) {
    final trimmed = email.trim();
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    return emailRegex.hasMatch(trimmed);
  }
}