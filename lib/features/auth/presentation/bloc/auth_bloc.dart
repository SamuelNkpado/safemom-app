import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Coordinates all auth flows on top of Kyle's use cases and repository.
///
/// The repository owns the auth-state stream; every other action is a
/// use case call. The bloc turns those async calls into UI-friendly
/// states (idle, submitting, success, failure).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required ResetPassword resetPassword,
    required SignOut signOut,
  })  : _authRepository = authRepository,
        _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _resetPassword = resetPassword,
        _signOut = signOut,
        super(const AuthState()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpSubmitted>(_onSignUpSubmitted);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthFormReset>(_onFormReset);

    _authSub = _authRepository.authStateChanges.listen(
          (user) => add(AuthUserChanged(user)),
    );
  }

  final AuthRepository _authRepository;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final ResetPassword _resetPassword;
  final SignOut _signOut;

  StreamSubscription<User?>? _authSub;

  Future<void> _onUserChanged(
      AuthUserChanged event,
      Emitter<AuthState> emit,
      ) async {
    if (event.user == null) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ));
      return;
    }
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: event.user,
    ));
  }

  Future<void> _onSignInRequested(
      AuthSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(
      formStatus: AuthFormStatus.submitting,
      errorMessage: null,
      infoMessage: null,
    ));
    try {
      await _signInWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(formStatus: AuthFormStatus.success));
    } on AuthException catch (error) {
      emit(state.copyWith(
        formStatus: AuthFormStatus.failure,
        errorMessage: error.message,
      ));
    }
  }

  Future<void> _onSignUpSubmitted(
      AuthSignUpSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(
      formStatus: AuthFormStatus.submitting,
      errorMessage: null,
      infoMessage: null,
    ));
    try {
      await _signUpWithEmail(
        name: event.name,
        email: event.email,
        password: event.password,
        phoneNumber: event.phoneNumber,
        dueDate: event.dueDate,
      );
      emit(state.copyWith(formStatus: AuthFormStatus.success));
    } on AuthException catch (error) {
      emit(state.copyWith(
        formStatus: AuthFormStatus.failure,
        errorMessage: error.message,
      ));
    }
  }

  Future<void> _onGoogleSignInRequested(
      AuthGoogleSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(
      formStatus: AuthFormStatus.submitting,
      errorMessage: null,
      infoMessage: null,
    ));
    try {
      await _signInWithGoogle();
      emit(state.copyWith(formStatus: AuthFormStatus.success));
    } on AuthException catch (error) {
      emit(state.copyWith(
        formStatus: AuthFormStatus.failure,
        errorMessage: error.message,
      ));
    }
  }

  Future<void> _onPasswordResetRequested(
      AuthPasswordResetRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(
      formStatus: AuthFormStatus.submitting,
      errorMessage: null,
      infoMessage: null,
    ));
    try {
      await _resetPassword(email: event.email);
      emit(state.copyWith(
        formStatus: AuthFormStatus.success,
        infoMessage:
        'Reset link sent. Please check your inbox.',
      ));
    } on AuthException catch (error) {
      emit(state.copyWith(
        formStatus: AuthFormStatus.failure,
        errorMessage: error.message,
      ));
    }
  }

  Future<void> _onSignOutRequested(
      AuthSignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    debugPrint('AUTHBLOC: sign-out handler entered');
    try {
      debugPrint('AUTHBLOC: calling _signOut()...');
      await _signOut();
      debugPrint('AUTHBLOC: _signOut() completed, emitting unauthenticated');
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        formStatus: AuthFormStatus.idle,
        errorMessage: null,
        infoMessage: null,
      ));
      debugPrint('AUTHBLOC: state emitted successfully');
    } on AuthException catch (error) {
      debugPrint('AUTHBLOC: AuthException caught: ${error.message}');
      emit(state.copyWith(
        formStatus: AuthFormStatus.failure,
        errorMessage: error.message,
      ));
    } catch (e, stack) {
      debugPrint('AUTHBLOC: UNEXPECTED ERROR: $e');
      debugPrint('AUTHBLOC: stack: $stack');
    }
  }

  void _onFormReset(AuthFormReset event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      formStatus: AuthFormStatus.idle,
      errorMessage: null,
      infoMessage: null,
    ));
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}