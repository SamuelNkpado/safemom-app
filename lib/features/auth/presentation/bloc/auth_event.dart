import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

/// Events the UI (or the auth stream) dispatches to [AuthBloc].
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Internal event fired when the auth-state stream emits a new user
/// (sign in, sign out, token refresh). Not dispatched from the UI.
class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final User? user;

  @override
  List<Object?> get props => [user];
}

/// Sign in an existing user with email + password.
class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Create a new account. Fired at the end of wizard step 2 (due date),
/// which is the point where all fields required by [SignUpWithEmail] exist.
class AuthSignUpSubmitted extends AuthEvent {
  const AuthSignUpSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.dueDate,
  });

  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final DateTime dueDate;

  @override
  List<Object?> get props => [name, email, password, phoneNumber, dueDate];
}

/// Sign in with the Google account picker.
class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

/// Send a password-reset link to [email].
class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Sign the current user out.
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Reset the transient form status back to idle (e.g. after showing an error).
class AuthFormReset extends AuthEvent {
  const AuthFormReset();
}
