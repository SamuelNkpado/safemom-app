import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Coordinates authentication for the whole app.
///
/// It only ever calls use cases — never Firebase directly. The use cases
/// validate input (throwing [ArgumentError]) and the data layer throws
/// [AuthException] for provider failures, so both are caught and surfaced
/// as friendly messages in [AuthState.errorMessage].
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required ResetPassword resetPassword,
    required SignOut signOut,
  })  : _signInWithEmail = signInWithEmail,
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

    // Mirror the provider's auth state into the bloc.
    _userSub = authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final ResetPassword _resetPassword;
  final SignOut _signOut;

  late final StreamSubscription<dynamic> _userSub;

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        status: event.user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: event.user,
      ),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(formStatus: AuthFormStatus.submitting, errorMessage: null));
    try {
      await _signInWithEmail(email: event.email, password: event.password);
      emit(state.copyWith(formStatus: AuthFormStatus.success));
    } on ArgumentError catch (e) {
      emit(_fail(e.message.toString()));
    } on AuthException catch (e) {
      emit(_fail(e.message));
    }
  }

  Future<void> _onSignUpSubmitted(
    AuthSignUpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(formStatus: AuthFormStatus.submitting, errorMessage: null));
    try {
      await _signUpWithEmail(
        name: event.name,
        email: event.email,
        password: event.password,
        phoneNumber: event.phoneNumber,
        dueDate: event.dueDate,
      );
      emit(state.copyWith(formStatus: AuthFormStatus.success));
    } on ArgumentError catch (e) {
      emit(_fail(e.message.toString()));
    } on AuthException catch (e) {
      emit(_fail(e.message));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(formStatus: AuthFormStatus.submitting, errorMessage: null));
    try {
      await _signInWithGoogle();
      emit(state.copyWith(formStatus: AuthFormStatus.success));
    } on AuthException catch (e) {
      emit(_fail(e.message));
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(formStatus: AuthFormStatus.submitting, errorMessage: null));
    try {
      await _resetPassword(email: event.email);
      emit(
        state.copyWith(
          formStatus: AuthFormStatus.success,
          infoMessage: 'A reset link is on its way. Check your email.',
        ),
      );
    } on ArgumentError catch (e) {
      emit(_fail(e.message.toString()));
    } on AuthException catch (e) {
      emit(_fail(e.message));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _signOut();
  }

  void _onFormReset(AuthFormReset event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        formStatus: AuthFormStatus.idle,
        errorMessage: null,
        infoMessage: null,
      ),
    );
  }

  AuthState _fail(String message) => state.copyWith(
        formStatus: AuthFormStatus.failure,
        errorMessage: message,
      );

  @override
  Future<void> close() {
    _userSub.cancel();
    return super.close();
  }
}
