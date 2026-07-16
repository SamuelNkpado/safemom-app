import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

/// Overall session status, driven by the auth-state stream.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Transient status of the current form action (sign in, sign up, reset).
enum AuthFormStatus { idle, submitting, success, failure }

/// Single immutable state for the whole auth feature. [status] tracks the
/// session; [formStatus] tracks the in-flight action so pages can show
/// spinners, errors, and success without a second bloc.
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.formStatus = AuthFormStatus.idle,
    this.user,
    this.errorMessage,
    this.infoMessage,
  });

  final AuthStatus status;
  final AuthFormStatus formStatus;
  final User? user;
  final String? errorMessage;
  final String? infoMessage;

  bool get isSubmitting => formStatus == AuthFormStatus.submitting;

  AuthState copyWith({
    AuthStatus? status,
    AuthFormStatus? formStatus,
    // Use sentinels so callers can explicitly clear these to null
    // (e.g. clearing the user on sign-out).
    Object? user = _sentinel,
    Object? errorMessage = _sentinel,
    Object? infoMessage = _sentinel,
  }) {
    return AuthState(
      status: status ?? this.status,
      formStatus: formStatus ?? this.formStatus,
      user: user == _sentinel ? this.user : user as User?,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      infoMessage:
          infoMessage == _sentinel ? this.infoMessage : infoMessage as String?,
    );
  }

  static const Object _sentinel = Object();

  @override
  List<Object?> get props => [status, formStatus, user, errorMessage, infoMessage];
}
