import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Business operation: sign up a new user with email and password.
///
/// Enforces validation rules before delegating to the auth repository.
/// The actual Firebase call happens in the data layer implementation.
class SignUpWithEmail {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  /// Executes the sign-up flow.
  ///
  /// Throws [ArgumentError] if any input fails validation.
  /// Throws [AuthException] if the auth provider rejects the sign-up
  /// (e.g. email already in use, network error).
  Future<User> call({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required DateTime dueDate,
  }) async {
    // ---------- VALIDATION ----------

    if (name.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty.');
    }

    if (name.trim().length < 2) {
      throw ArgumentError('Name must be at least 2 characters.');
    }

    if (!_isValidEmail(email)) {
      throw ArgumentError('Please enter a valid email address.');
    }

    if (password.length < 8) {
      throw ArgumentError('Password must be at least 8 characters.');
    }

    if (!_hasLetterAndNumber(password)) {
      throw ArgumentError(
        'Password must contain at least one letter and one number.',
      );
    }

    if (!_isValidPhone(phoneNumber)) {
      throw ArgumentError('Please enter a valid phone number.');
    }

    if (dueDate.isBefore(DateTime.now())) {
      throw ArgumentError('Due date must be in the future.');
    }

    final maxDueDate = DateTime.now().add(const Duration(days: 300));
    if (dueDate.isAfter(maxDueDate)) {
      throw ArgumentError('Due date cannot be more than 10 months away.');
    }

    // ---------- DELEGATE TO REPOSITORY ----------

    return repository.signUpWithEmail(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      phoneNumber: phoneNumber.trim(),
      dueDate: dueDate,
    );
  }

  // ---------- VALIDATION HELPERS ----------

  bool _isValidEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    return emailRegex.hasMatch(trimmed);
  }

  bool _hasLetterAndNumber(String password) {
    final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    return hasLetter && hasNumber;
  }

  bool _isValidPhone(String phone) {
    final trimmed = phone.trim();
    // Accept +countrycode format, or 9-15 digits, or with common separators
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{9,20}$');
    return phoneRegex.hasMatch(trimmed);
  }
}